#!/usr/bin/env node

// Local GitHub-style markdown preview. No external API.
//
// Usage: md <file.md> [host:port]
//
// Parses markdown with pandoc (GFM) and serves it with vendored
// github-markdown.css. Browser live-reloads when the file changes.

const http = require('http')
const fs = require('fs')
const path = require('path')
const { execFile } = require('child_process')

const HERE = __dirname
const CSS = path.join(HERE, 'md.css')

const page = ({ title, css, body, mtime }) => `<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>${title}</title>
<style>${css}</style>
</head>
<body>
<article class="markdown-body" id="content">${body}</article>
<script>
let mtime = "${mtime}";
setInterval(async () => {
  try {
    const s = await (await fetch("/state")).text();
    if (s !== mtime) {
      mtime = s;
      document.getElementById("content").innerHTML = await (await fetch("/body")).text();
    }
  } catch (e) {}
}, 500);
</script>
</body>
</html>`

const render = (file) =>
  new Promise((resolve, reject) => {
    execFile(
      'pandoc',
      ['-f', 'gfm', '-t', 'html', '--wrap=none', file],
      (err, stdout) => {
        if (err) reject(err)
        else resolve(stdout)
      },
    )
  })

const mtime = (file) => {
  try {
    return String(fs.statSync(file).mtimeMs)
  } catch (e) {
    return '0'
  }
}

const escapeHtml = (s) =>
  s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')

const main = () => {
  const file = process.argv[2]
  if (!file) {
    console.error('usage: md <file.md> [host:port]')
    process.exit(1)
  }
  const abs = path.resolve(file)
  const [host, port] = (process.argv[3] || 'localhost:6419').split(':')

  const server = http.createServer(async (req, res) => {
    try {
      if (req.url === '/state') {
        res.writeHead(200, { 'Content-Type': 'text/plain' })
        res.end(mtime(abs))
        return
      }
      if (req.url === '/body') {
        res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' })
        res.end(await render(abs))
        return
      }
      const css = fs.readFileSync(CSS, 'utf8')
      res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' })
      res.end(
        page({
          title: escapeHtml(path.basename(abs)),
          css,
          body: await render(abs),
          mtime: mtime(abs),
        }),
      )
    } catch (e) {
      res.writeHead(500, { 'Content-Type': 'text/plain' })
      res.end(String(e))
    }
  })

  server.listen(Number(port), host, () => {
    console.log(`serving ${abs} at http://${host || 'localhost'}:${port}`)
  })
}

main()

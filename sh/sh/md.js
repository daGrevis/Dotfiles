#!/usr/bin/env node

// Local GitHub-style markdown preview. No external API.
//
// Usage: md <root-dir> [host:port]
//
// Serves every markdown file under the root dir, with the URL path mapping to
// the file path relative to it (e.g. /home/test.md -> <root>/home/test.md).
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
    const s = await (await fetch(location.pathname + "?state")).text();
    if (s !== mtime) {
      mtime = s;
      document.getElementById("content").innerHTML = await (await fetch(location.pathname + "?body")).text();
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
  const dir = process.argv[2]
  if (!dir) {
    console.error('usage: md <root-dir> [host:port]')
    process.exit(1)
  }
  const root = path.resolve(dir)
  const [host, port] = (process.argv[3] || 'localhost:6419').split(':')

  const server = http.createServer(async (req, res) => {
    try {
      const url = new URL(req.url, 'http://localhost')
      const abs = path.resolve(root, '.' + decodeURIComponent(url.pathname))
      if (
        !abs.startsWith(root + path.sep) ||
        path.extname(abs).toLowerCase() !== '.md' ||
        !fs.existsSync(abs) ||
        !fs.statSync(abs).isFile()
      ) {
        res.writeHead(404, { 'Content-Type': 'text/plain' })
        res.end('not found')
        return
      }
      if (url.searchParams.has('state')) {
        res.writeHead(200, { 'Content-Type': 'text/plain' })
        res.end(mtime(abs))
        return
      }
      if (url.searchParams.has('body')) {
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
    console.log(`serving ${root} at http://${host || 'localhost'}:${port}`)
  })
}

main()

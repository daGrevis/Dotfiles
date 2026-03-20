#!/usr/bin/env node

// Easy jumping between tmux/tmuxinator sessions via fzf.

const process = require('process')
const child_process = require('child_process')
const fsPromises = require('fs/promises')
const path = require('path')
const os = require('os')

// Resets ASDF_NODEJS_VERSION from system so that spawned sessions can use .tool-versions again.
process.env['ASDF_NODEJS_VERSION'] = ''

const TMUXINATOR_PATH = path.join(os.homedir(), '.config/tmuxinator')
const HISTORY_PATH = path.join(os.homedir(), '.mux-history')

const spawnSh = (command) =>
  new Promise((resolve, reject) => {
    const sh = child_process.spawn('sh', ['-c', command], {
      stdio: ['inherit', 'pipe', 'inherit'],
    })

    const response = { ok: false, stdout: '' }

    sh.stdout.on('data', (data) => {
      response.stdout += data.toString()
    })

    sh.on('close', (code) => {
      response.ok = code === 0

      resolve(response)
    })
  })

const getActiveSessions = async () => {
  const { ok, stdout } = await spawnSh('tmux ls')

  if (!ok) {
    return []
  }

  return stdout
    .split('\n')
    .slice(0, -1)
    .map((line) => line.split(':', 1)[0])
}

const getTmuxinatorSessions = async () => {
  let fileNames = []
  try {
    fileNames = await fsPromises.readdir(TMUXINATOR_PATH)
  } catch (e) {
    if (e.code === 'ENOENT') {
      return []
    }
    throw e
  }

  return fileNames.map((fileName) => fileName.replace(/\.yml$/, ''))
}

const getHistorySessions = async (activeSessions, tmuxinatorSessions) => {
  let fileContent = ''
  try {
    fileContent = await fsPromises.readFile(HISTORY_PATH, 'utf8')
  } catch (e) {
    return []
  }

  const historySessions = fileContent.split('\n').slice(0, -1)

  // Filter out "expired sessions".
  return historySessions.filter(
    (session) =>
      activeSessions.includes(session) || tmuxinatorSessions.includes(session),
  )
}

const updateHistory = async (nextSession, historySessions) => {
  const fileContent =
    historySessions
      .filter((session) => nextSession !== session)
      .concat(nextSession)
      .join('\n') + '\n'

  await fsPromises.writeFile(HISTORY_PATH, fileContent)
}

const getCurrentSession = async () => {
  const { ok, stdout } = await spawnSh("tmux display-message -p '#S'")

  if (!ok) {
    return
  }

  return stdout.trim()
}

const removeDuplicates = (list) => {
  return list.filter((item, index) => list.indexOf(item) === index)
}

const getListeningPorts = async () => {
  const { ok, stdout } = await spawnSh(
    'lsof -iTCP -sTCP:LISTEN -P -n 2>/dev/null',
  )
  if (!ok || !stdout) return {}

  const pidPorts = {}
  for (const line of stdout.split('\n')) {
    const parts = line.trim().split(/\s+/)
    if (parts.length >= 9 && parts[0] !== 'COMMAND') {
      const pid = parts[1]
      const portMatch = parts[8].match(/:(\d+)$/)
      if (portMatch) {
        if (!pidPorts[pid]) pidPorts[pid] = new Set()
        pidPorts[pid].add(portMatch[1])
      }
    }
  }
  return pidPorts
}

const getProcessTree = async () => {
  const { ok, stdout } = await spawnSh('ps -eo pid=,ppid=')
  if (!ok || !stdout) return {}

  const children = {}
  for (const line of stdout.split('\n')) {
    const match = line.trim().match(/^(\d+)\s+(\d+)$/)
    if (match) {
      const [, pid, ppid] = match
      if (!children[ppid]) children[ppid] = []
      children[ppid].push(pid)
    }
  }
  return children
}

const getAllDescendantPids = (pid, processTree) => {
  const pids = new Set()
  const stack = [pid]
  while (stack.length > 0) {
    const current = stack.pop()
    for (const child of processTree[current] || []) {
      pids.add(child)
      stack.push(child)
    }
  }
  return pids
}

const getSessionDescriptions = async () => {
  const { ok, stdout } = await spawnSh(
    "tmux list-sessions -F '#{session_name}\t#{@description}' 2>/dev/null",
  )
  if (!ok || !stdout) return {}

  const descriptions = {}
  for (const line of stdout.trim().split('\n')) {
    const [name, ...descParts] = line.split('\t')
    const desc = descParts.join('\t').trim()
    if (name && desc) {
      descriptions[name] = desc
    }
  }
  return descriptions
}

const getSessionPorts = async (session, processTree, listeningPorts) => {
  const { ok, stdout } = await spawnSh(
    `tmux list-panes -s -t '=${session}' -F '#{pane_pid}'`,
  )
  if (!ok || !stdout) return []

  const panePids = stdout.trim().split('\n').filter(Boolean)
  const ports = new Set()

  for (const panePid of panePids) {
    const descendants = getAllDescendantPids(panePid, processTree)
    descendants.add(panePid)
    for (const pid of descendants) {
      const pidPorts = listeningPorts[pid]
      if (pidPorts) {
        for (const port of pidPorts) {
          ports.add(port)
        }
      }
    }
  }

  return [...ports].sort((a, b) => Number(a) - Number(b))
}

const sessionSorter = (activeSessions, historySessions) => (a, b) => {
  const isActiveA = activeSessions.includes(a)
  const isActiveB = activeSessions.includes(b)

  if (isActiveA && !isActiveB) {
    return -1
  }
  if (!isActiveA && isActiveB) {
    return 1
  }

  const historyIndexA = historySessions.indexOf(a)
  const historyIndexB = historySessions.indexOf(b)

  if (historyIndexA > historyIndexB) {
    return -1
  }
  if (historyIndexA < historyIndexB) {
    return 1
  }

  if (a > b) {
    return -1
  }
  if (a < a) {
    return 1
  }

  return 0
}

const selectWithFzf = async (sessions) => {
  const { stdout, ok } = await spawnSh(
    `echo '${sessions.join('\n')}' | fzf --tac --print-query --ansi --no-scrollbar`,
  )

  const [query, match] = stdout.split('\n')
  const selection = match || query

  return selection
}

const getRunningInTmux = () => {
  const isRunningInTmux = process.env['TMUX'] !== undefined

  return isRunningInTmux
}

const switchToTmuxSession = async (session) => {
  const { ok } = await spawnSh(
    `tmux ${getRunningInTmux() ? 'switch' : 'attach'} -t '=${session}'`,
  )

  return ok
}

const startNewTmuxinatorSession = async (session) => {
  const { ok, stdout } = await spawnSh(
    `tmuxinator start --suppress-tmux-version-warning=SUPPRESS-TMUX-VERSION-WARNING '${session}'`,
  )

  return ok
}

const startNewTmuxSession = async (session) => {
  const { ok } = await spawnSh(`tmux new -c ~ -d -s '${session}'`)

  return ok
}

const main = async () => {
  const activeSessions = await getActiveSessions()
  const tmuxinatorSessions = await getTmuxinatorSessions()
  const historySessions = await getHistorySessions(
    activeSessions,
    tmuxinatorSessions,
  )
  const currentSession = await getCurrentSession()

  const [processTree, listeningPorts, sessionDescriptions, termWidth] =
    await Promise.all([
    getProcessTree(),
    getListeningPorts(),
    getSessionDescriptions(),
    spawnSh('stty size 2>/dev/null').then(({ ok, stdout }) => {
      const RIGHT_PAD = 3
      if (ok && stdout.trim()) {
        const cols = parseInt(stdout.trim().split(/\s+/)[1], 10)
        if (cols > 0) return cols - RIGHT_PAD
      }
      return 80 - RIGHT_PAD
    }),
  ])

  const sortedSessions = removeDuplicates([
    ...activeSessions,
    ...tmuxinatorSessions,
  ])
    .filter((session) => session !== currentSession)
    .sort(sessionSorter(activeSessions, historySessions))

  const sessionPortsMap = {}
  await Promise.all(
    activeSessions.map(async (session) => {
      sessionPortsMap[session] = await getSessionPorts(
        session,
        processTree,
        listeningPorts,
      )
    }),
  )

  const sessions = sortedSessions
    .map((session) => {
      const isActive = activeSessions.includes(session)
      const ports = sessionPortsMap[session] || []
      const desc = sessionDescriptions[session] || ''
      const prefix = isActive ? '[+]' : '[ ]'

      const descPart = desc ? ` \x1b[2m${desc}\x1b[0m` : ''
      const leftSide = `${prefix} ${session}${descPart}`
      const leftLen =
        prefix.length + 1 + session.length + (desc ? 1 + desc.length : 0)

      if (ports.length > 0) {
        const portsStr = ports.map((p) => ':' + p).join(',')
        const padding = ' '.repeat(
          Math.max(2, termWidth - leftLen - portsStr.length),
        )
        return `${leftSide}${padding}\x1b[33m${portsStr}\x1b[0m`
      }
      const padding = ' '.repeat(Math.max(0, termWidth - leftLen))
      return `${leftSide}${padding}`
    })
    .reverse()

  let nextSession = process.argv[2]

  if (!nextSession) {
    nextSession = await selectWithFzf(sessions)

    if (nextSession) {
      nextSession = nextSession.replace(/^\[[+ ]\] /, '').split(/\s/)[0]
    }
  }

  // No selection was made by user, do nothing.
  if (!nextSession) {
    return
  }

  // No need to switch, do nothing.
  if (currentSession === nextSession && getRunningInTmux()) {
    return
  }

  // Update history when selection is confirmed, just before switching to it.
  await updateHistory(nextSession, historySessions)

  // Try switching to tmux session.
  if (await switchToTmuxSession(nextSession)) {
    return
  }

  // If we couldn't switch, try starting a tmuxinator session.
  if (await startNewTmuxinatorSession(nextSession)) {
    return
  }

  // If we couldn't start a tmuxinator session, create a tmux session and switch to it.
  await startNewTmuxSession(nextSession)
  await switchToTmuxSession(nextSession)
}

main()

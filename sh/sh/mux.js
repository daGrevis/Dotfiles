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

// Like spawnSh, but without a shell in between, because each process start
// makes the popup slower. Ignores stderr, like 2>/dev/null.
const spawnFile = (file, args, input) =>
  new Promise((resolve) => {
    const child = child_process.spawn(file, args, {
      stdio: [input === undefined ? 'ignore' : 'pipe', 'pipe', 'ignore'],
    })

    const response = { ok: false, stdout: '' }

    child.stdout.on('data', (data) => {
      response.stdout += data.toString()
    })

    child.on('error', () => {
      resolve(response)
    })

    child.on('close', (code) => {
      response.ok = code === 0

      resolve(response)
    })

    if (input !== undefined) {
      child.stdin.end(input)
    }
  })

// One tmux call for everything, because each process start makes the popup slower.
const getTmuxState = async () => {
  const { stdout } = await spawnFile('tmux', [
    'list-panes',
    '-a',
    '-F',
    'pane\t#{session_name}\t#{pane_pid}\t#{pane_tty}\t#{@description}',
    ';',
    'display-message',
    '-p',
    'current\t#S',
  ])

  const activeSessions = []
  const sessionPanePids = {}
  const sessionDescriptions = {}
  const paneTtys = new Set()
  let currentSession

  for (const line of stdout.split('\n')) {
    const [kind, session, pid, tty, ...descParts] = line.split('\t')
    if (kind === 'current') {
      currentSession = session
    }
    if (kind !== 'pane') {
      continue
    }

    if (!sessionPanePids[session]) {
      activeSessions.push(session)
      sessionPanePids[session] = []
    }
    sessionPanePids[session].push(pid)
    paneTtys.add(tty.replace(/^\/dev\//, ''))

    const desc = descParts.join('\t').trim()
    if (desc) {
      sessionDescriptions[session] = desc
    }
  }

  return {
    activeSessions,
    currentSession,
    sessionPanePids,
    sessionDescriptions,
    paneTtys: [...paneTtys],
  }
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

const removeDuplicates = (list) => {
  return list.filter((item, index) => list.indexOf(item) === index)
}

// On macOS, netstat is much faster than lsof and also shows the pid.
const getListeningPortsNetstat = async () => {
  const { ok, stdout } = await spawnFile('netstat', ['-anv', '-p', 'tcp'])
  if (!ok || !stdout) return

  const lines = stdout.split('\n')
  const header = lines.find((line) => line.startsWith('Proto'))
  if (!header) return

  // "Local Address" and "Foreign Address" are two words in the header but one in a row.
  const pidIndex = header.trim().split(/\s+/).indexOf('pid') - 2
  if (pidIndex < 0) return

  const pidPorts = {}
  for (const line of lines) {
    const parts = line.trim().split(/\s+/)
    if (parts[5] === 'LISTEN') {
      const pid = parts[pidIndex]
      const portMatch = parts[3].match(/\.(\d+)$/)
      if (portMatch) {
        if (!pidPorts[pid]) pidPorts[pid] = new Set()
        pidPorts[pid].add(portMatch[1])
      }
    }
  }
  return pidPorts
}

const getListeningPorts = async () => {
  if (process.platform === 'darwin') {
    const pidPorts = await getListeningPortsNetstat()
    if (pidPorts) return pidPorts
  }

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

// Only the processes on the terminal of a pane, because ps for all processes is
// slow. A process that listens in a pane runs on the terminal of that pane.
const getProcessTree = async (paneTtys) => {
  if (paneTtys.length === 0) return {}

  const { ok, stdout } = await spawnFile('ps', [
    '-o',
    'pid=,ppid=',
    '-t',
    paneTtys.join(','),
  ])
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

const getSessionPorts = (panePids, processTree, listeningPorts) => {
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

const selectWithFzf = async (sessions, hasCurrent) => {
  const bind = hasCurrent ? ['--bind', 'load:up'] : []
  const { stdout, ok } = await spawnFile(
    'fzf',
    [...bind, '--print-query', '--ansi', '--no-scrollbar'],
    sessions.join('\n') + '\n',
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
    `tmux ${getRunningInTmux() ? 'switch-client' : 'attach'} -t '=${session}' 2>/dev/null`,
  )

  return ok
}

const startNewTmuxinatorSession = async (session) => {
  const { ok, stdout } = await spawnSh(
    `tmuxinator start --suppress-tmux-version-warning=SUPPRESS-TMUX-VERSION-WARNING '${session}' 2>/dev/null`,
  )

  return ok
}

const startNewTmuxSession = async (session) => {
  const { ok } = await spawnSh(`tmux new -c ~ -d -s '${session}' 2>/dev/null`)

  return ok
}

const main = async () => {
  const tmuxState = getTmuxState()
  const [
    { activeSessions, currentSession, sessionPanePids, sessionDescriptions },
    tmuxinatorSessions,
    processTree,
    listeningPorts,
  ] = await Promise.all([
    tmuxState,
    getTmuxinatorSessions(),
    tmuxState.then(({ paneTtys }) => getProcessTree(paneTtys)),
    getListeningPorts(),
  ])
  const RIGHT_PAD = 3
  const termWidth = (process.stdout.columns || 80) - RIGHT_PAD
  const historySessions = await getHistorySessions(
    activeSessions,
    tmuxinatorSessions,
  )

  const isCurrentActive =
    currentSession && activeSessions.includes(currentSession)

  const otherSessions = removeDuplicates([
    ...activeSessions,
    ...tmuxinatorSessions,
  ])
    .filter((session) => session !== currentSession)
    .sort(sessionSorter(activeSessions, historySessions))

  const sortedSessions = isCurrentActive
    ? [currentSession, ...otherSessions]
    : otherSessions

  const sessionPortsMap = {}
  for (const session of activeSessions) {
    sessionPortsMap[session] = getSessionPorts(
      sessionPanePids[session] || [],
      processTree,
      listeningPorts,
    )
  }

  const sessions = sortedSessions
    .map((session) => {
      const isActive = activeSessions.includes(session)
      const isCurrent = session === currentSession
      const ports = sessionPortsMap[session] || []
      const desc = sessionDescriptions[session] || ''
      const prefix = isCurrent ? '[*]' : isActive ? '[+]' : '[ ]'

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

  let nextSession = process.argv[2]

  if (!nextSession) {
    nextSession = await selectWithFzf(sessions, isCurrentActive)

    if (nextSession) {
      nextSession = nextSession.replace(/^\[[*+ ]\] /, '').split(/\s/)[0]
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

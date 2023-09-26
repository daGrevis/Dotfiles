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
      response.stdout = data.toString()
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
    `echo '${sessions.join('\n')}' | fzf --tac --print-query`,
  )

  const [query, match] = stdout.split('\n')
  const selection = match || query

  return selection
}

const switchToTmuxSession = async (session) => {
  const isRunningInTmux = process.env['TMUX'] !== undefined

  const { ok } = await spawnSh(
    `tmux ${isRunningInTmux ? 'switch' : 'attach'} -t '${session}'`,
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

  const sessions = removeDuplicates([...activeSessions, ...tmuxinatorSessions])
    .filter((session) => session !== currentSession)
    .sort(sessionSorter(activeSessions, historySessions))
    .map((session) => {
      const isActive = activeSessions.includes(session)

      return `${isActive ? '[+]' : '[ ]'} ${session}`
    })
    .reverse()

  let nextSession = process.argv[2]

  if (!nextSession) {
    nextSession = await selectWithFzf(sessions)

    if (nextSession) {
      nextSession = nextSession.replace(/^\[[+ ]\] /, '')
    }
  }

  // No selection was made by user, do nothing.
  if (!nextSession) {
    return
  }

  // No need to switch, do nothing.
  if (currentSession === nextSession) {
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

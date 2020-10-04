import { css, run } from 'uebersicht'

const APP_ICONS = require('./app-icons.json')

const YABAI_PATH = '/usr/local/bin/yabai'

const config = {
  width: 23,
  height: 23,
  windowGap: 10,
  underlineHeight: 2,
  borderHeight: 1,
  colorWhite: '#e5e5e5',
  colorBlack: '#252525',
  colorBlackAndTransparent: 'rgba(37, 37, 37, 0.4)',
  colorGray: '#6f6f72',
}

// const refreshFrequency = false
const refreshFrequency = 1000

const command = './status/bar.sh'

const getDisplayId = () => {
  // Not documented, but href contains display ID.
  const { pathname } = new URL(location.href)
  return Number(pathname.slice(1))
}

const state = {
  lastDisplay: null,
}

const render = (props) => {
  if (props.error) {
    console.log(props.error)
  }

  let displays = []
  let spaces = []
  let windows = []

  try {
    const data = JSON.parse(props.output)
    displays = data.displays
    spaces = data.spaces
    windows = data.windows
  } catch (e) {
    console.log(e)
    console.log(props.output)
  }

  const displayId = getDisplayId()

  let display = displays.find((display) => display.id === displayId)

  if (display) {
    state.lastDisplay = display
  } else {
    display = state.lastDisplay
  }

  if (!display) {
    console.log('Error: no display was found')
    return null
  }

  spaces = spaces.filter((space) => space.display === display.index)

  return <Layout {...{ displays, spaces, windows }} />
}

const Layout = (props) => (
  <div
    className={css`
      position: fixed;
      bottom: 0;
      left: 0;
      width: 100%;
      border-top: ${config.borderHeight}px solid
        ${config.colorBlackAndTransparent};
      height: ${config.height - config.borderHeight}px;
      background: ${config.colorBlack};
      background-clip: padding-box;
      font-family: -apple-system;
      font-size: 14px;
      user-select: none;
    `}
  >
    <div
      className={css`
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin: 0 ${config.windowGap}px;
      `}
    >
      <Left {...props} />
      <Right {...props} />
    </div>
  </div>
)

const Left = ({ spaces, windows }) => (
  <div
    className={css`
      display: flex;
    `}
  >
    {spaces.map((space) => (
      <Space
        key={space.index}
        space={space}
        spaceWindows={space.windows.map((windowId) =>
          windows.find((window) => window.id === windowId),
        )}
      />
    ))}
  </div>
)

const AppIcon = ({ spaceWindow }) => {
  const src = APP_ICONS[spaceWindow.app]

  const noSrcCss =
    !src &&
    css`
      width: ${config.width - 4}px;
      background-color: ${config.colorBlack};
    `

  return (
    <img
      src={src}
      className={css`
        ${!src && `background: ${config.colorWhite};`}
        margin-right: 8px;
        width: auto;
        height: ${config.height - 4}px;

        ${noSrcCss}
      `}
      onClick={() => {
        run(`${YABAI_PATH} -m window --focus ${spaceWindow.id}`)
      }}
    />
  )
}

const Right = ({ spaces, windows }) => {
  const focusedSpace = spaces.find((space) => space.focused)

  if (!focusedSpace) {
    return null
  }

  const spaceWindows = focusedSpace.windows.map((windowId) =>
    windows.find((window) => window.id === windowId),
  )

  spaceWindows.sort((a, b) => {
    if (a.app < b.app) {
      return -1
    }
    if (a.app > b.app) {
      return 1
    }
    return a.id > b.id ? 1 : -1
  })

  return (
    <div
      className={css`
        display: flex;
        margin-right: -8px;
      `}
    >
      {spaceWindows.map((spaceWindow) => (
        <AppIcon key={spaceWindow.id} spaceWindow={spaceWindow} />
      ))}
    </div>
  )
}

const Space = ({ space, spaceWindows }) => {
  const focusedCss =
    space.focused &&
    css`
      background-color: ${config.colorWhite};
      background-clip: padding-box;
      border-color: ${config.colorWhite};
      font-weight: bold;
      color: ${config.colorBlack};
    `
  const withWindowsCss =
    spaceWindows.filter(
      (window) => window && !window.sticky && window.app !== 'AltTab',
    ).length > 0 &&
    css`
      border-color: ${config.colorGray};
    `

  return (
    <div
      className={css`
        box-sizing: border-box;
        width: ${config.width}px;
        height: ${config.height - config.borderHeight}px;
        line-height: ${config.height -
        config.underlineHeight -
        config.borderHeight}px;
        background-color: ${config.colorBlack};
        background-clip: padding-box;
        border-bottom: ${config.underlineHeight}px solid ${config.colorBlack};
        margin-right: 8px;
        text-align: center;
        color: ${config.colorWhite};

        ${withWindowsCss}
        ${focusedCss}
      `}
      onClick={() => {
        run(`${YABAI_PATH} -m space --focus ${space.index}`)
      }}
    >
      {space.index}
    </div>
  )
}

export { refreshFrequency, command, render }

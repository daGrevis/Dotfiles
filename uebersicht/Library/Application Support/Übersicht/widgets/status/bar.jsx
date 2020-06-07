import { css, run } from 'uebersicht'

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

const refreshFrequency = false

const command = './status/bar.sh'

const getDisplayId = () => {
  // Not documented, but href contains display ID.
  const { pathname } = new URL(location.href)
  return Number(pathname.slice(1))
}

const render = (props) => {
  console.log('render')

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
  const display = displays.find((display) => display.id === displayId)

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

const Right = ({ spaces }) => {
  const focusedSpace = spaces.find((space) => space.focused)

  if (!focusedSpace) {
    return null
  }

  return (
    <div
      className={css`
        color: ${config.colorWhite};
      `}
    >
      <span
        className={css`
          font-weight: bold;
          padding-right: 2px;
        `}
      >
        {focusedSpace.type === 'float' ? 'F' : 'T'}
      </span>
      [{focusedSpace.windows.length}]
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
    spaceWindows.filter((window) => window && !window.sticky).length > 0 &&
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

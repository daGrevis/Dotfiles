local PassChooser = hs.loadSpoon('PassChooser')
PassChooser:bindHotkeys({
  show={{'cmd'}, 'p'},
})
PassChooser:init({
  clearAfter=10,
})

hs.alert.show('Hammerspoon loaded')

-- local function starts_with(str, start)
--    return str:sub(1, #start) == start
-- end

local function ends_with(str, ending)
   return ending == "" or str:sub(-#ending) == ending
end

local function open_app(app_name, new)
  new = new or false

  local s = 'open'
  if new then
    s = s .. ' -n'
  end
  s = s .. " -a '/Applications/" .. app_name .. ".app'"

  hs.execute(s)
end

local function airPods(deviceName)
  local s = [[
    activate application "SystemUIServer"
    tell application "System Events"
      tell process "SystemUIServer"
        set btMenu to (menu bar item 1 of menu bar 1 whose description contains "bluetooth")
        tell btMenu
          click
  ]]
  ..
          'tell (menu item "' .. deviceName .. '" of menu 1)\n'
  ..
  [[
            click
            if exists menu item "Connect" of menu 1 then
              click menu item "Connect" of menu 1
              return "Connecting AirPods..."
            else
              click menu item "Disconnect" of menu 1
              return "Disconecting AirPods..."
            end if
          end tell
        end tell
      end tell
    end tell
  ]]

  return hs.osascript.applescript(s)
end

local function toggleDark()
  local s = [[
    tell application "System Events"
      tell appearance preferences
          set dark mode to not dark mode
      end tell
    end tell
  ]]

  return hs.osascript.applescript(s)
end

local function focusFrontmost()
  local frontmostWindow = hs.window.frontmostWindow()
  frontmostWindow:focus()
end

hs.hotkey.bind({'cmd'}, '\\', function()
  local ok, output = airPods('daGrevis’ AirPods')
  if ok then
    hs.alert.show(output)
  else
    hs.alert.show("Couldn't connect to AirPods!")
  end
end)

-- Focus previously used window of the same app.
hs.hotkey.bind({'cmd'}, '`', function()
  local front_app = hs.application.frontmostApplication()

  local windows
  if front_app:name() == 'Alacritty' then
    local rest_apps = hs.fnutils.ifilter({hs.application.find('Alacritty')}, function(app)
      return app:pid() ~= front_app:pid()
    end)

    local apps = hs.fnutils.concat({front_app}, rest_apps)

    windows = hs.fnutils.imap(apps, function(app)
      return app:allWindows()[1]
    end)
  else
    windows = hs.fnutils.ifilter(front_app:visibleWindows(), function(window)
      return window:subrole() == 'AXStandardWindow'
    end)
  end

  if #windows > 1 then
    windows[2]:focus()
  end
end)

hs.hotkey.bind({'cmd'}, '/', function()
  hs.caffeinate.startScreensaver()
end)

hs.hotkey.bind({'cmd'}, '.', function()
  hs.pasteboard.setContents('')
  hs.alert.show('clipboard cleared')
end)

hs.hotkey.bind({'cmd', 'shift'}, 'return', function()
  open_app('Alacritty', true)
end)

hs.hotkey.bind({'cmd', 'shift'}, 'i', function()
  open_app('Firefox Developer Edition')
end)

hs.hotkey.bind({'cmd', 'shift'}, 's', function()
  open_app('Slack')
end)

hs.hotkey.bind({'cmd', 'shift'}, 'a', function()
  open_app('Spark')
end)

hs.hotkey.bind({'cmd', 'shift'}, 'd', function()
  hs.application.launchOrFocus('Finder')
end)

-- Relaunch
hs.hotkey.bind({'cmd', 'shift'}, 'r', function()
  hs.relaunch()
end)

-- Toggle console
hs.hotkey.bind({'cmd', 'shift'}, 'e', function()
  hs.toggleConsole()
  focusFrontmost()
end)

local function closeNotifications()
  local s = [[
    tell application "System Events"
      tell process "NotificationCenter"
        set numwins to (count windows)
        repeat with i from numwins to 1 by -1
          try
            click button "Close" of window i
          end try
          try
            click button "Cancel" of window i
          end try
          try
            click button "Not Now" of window i
          end try
          try
            click button "Mark as Read" of window i
          end try
        end repeat
      end tell
    end tell
  ]]

  return hs.osascript.applescript(s)
end

hs.hotkey.bind({'ctrl'}, 'space', function()
  closeNotifications()
end)

local config_path = os.getenv('HOME') .. '/.hammerspoon/'
hs.pathwatcher.new(config_path, function(paths)
  paths = hs.fnutils.ifilter(paths, function(path)
    if ends_with(path, '.git/index.lock') then
      return false
    end

    if ends_with(path, '.md') or ends_with(path, '.md~') then
      return false
    end

    return true
  end)

  if #paths > 0 then
    hs.reload()
  end
end):start()

hs.window.animationDuration = 0

local function setWindowFrame(fn, window)
  local w = window or hs.window.focusedWindow()

  local windowFrame = w:frame()
  local screenFrame = w:screen():frame()
  w:setFrame(fn(windowFrame, screenFrame))
end

-- Fullscreen
hs.hotkey.bind({'cmd', 'alt'}, 'f', function()
  setWindowFrame(function(windowFrame, screenFrame)
    windowFrame.x = screenFrame.x
    windowFrame.y = screenFrame.y
    windowFrame.w = screenFrame.w
    windowFrame.h = screenFrame.h
    return windowFrame
  end)
end)

-- Center
hs.hotkey.bind({'cmd', 'alt'}, 'c', function()
  setWindowFrame(function(windowFrame, screenFrame)
    windowFrame.x = screenFrame.w * .2
    windowFrame.y = screenFrame.h * .125
    windowFrame.w = screenFrame.w * .6
    windowFrame.h = screenFrame.h * .8
    return windowFrame
  end)
end)

hs.hotkey.bind({'cmd', 'alt'}, 'left', function()
  setWindowFrame(function(windowFrame, screenFrame)
    windowFrame.x = screenFrame.x
    windowFrame.w = screenFrame.w / 2
    return windowFrame
  end)
end)

hs.hotkey.bind({'cmd', 'alt'}, 'right', function()
  setWindowFrame(function(windowFrame, screenFrame)
    windowFrame.x = screenFrame.x + (screenFrame.w / 2)
    windowFrame.w = screenFrame.w / 2
    return windowFrame
  end)
end)

hs.hotkey.bind({'cmd', 'alt'}, 'down', function()
  setWindowFrame(function(windowFrame, screenFrame)
    windowFrame.y = screenFrame.y + (screenFrame.h / 2)
    windowFrame.h = screenFrame.h / 2
    return windowFrame
  end)
end)

hs.hotkey.bind({'cmd', 'alt'}, 'up', function()
  setWindowFrame(function(windowFrame, screenFrame)
    windowFrame.y = 0
    windowFrame.h = screenFrame.h / 2
    return windowFrame
  end)
end)

hs.hotkey.bind({'cmd'}, 'm', function()
  local mainScreen = hs.screen.mainScreen()
  local otherScreen = hs.fnutils.find(hs.screen.allScreens(), function(screen)
    return screen:id() ~= mainScreen:id()
  end)

  local focusedWindow = hs.window.focusedWindow()
  focusedWindow:moveToScreen(otherScreen)
  focusedWindow:focus()
end)

hs.grid.MARGINX = 0
hs.grid.MARGINY = 0
hs.grid.GRIDHEIGHT = 12
hs.grid.GRIDWIDTH = 12

-- Move windows.
hs.hotkey.bind({'cmd', 'ctrl'}, 'down', hs.grid.pushWindowDown)
hs.hotkey.bind({'cmd', 'ctrl'}, 'up', hs.grid.pushWindowUp)
hs.hotkey.bind({'cmd', 'ctrl'}, 'left', hs.grid.pushWindowLeft)
hs.hotkey.bind({'cmd', 'ctrl'}, 'right', hs.grid.pushWindowRight)

-- Resize windows.
hs.hotkey.bind({'cmd', 'ctrl', 'shift'}, 'down', hs.grid.resizeWindowShorter)
hs.hotkey.bind({'cmd', 'ctrl', 'shift'}, 'up', hs.grid.resizeWindowTaller)
hs.hotkey.bind({'cmd', 'ctrl', 'shift'}, 'left', hs.grid.resizeWindowThinner)
hs.hotkey.bind({'cmd', 'ctrl', 'shift'}, 'right', hs.grid.resizeWindowWider)

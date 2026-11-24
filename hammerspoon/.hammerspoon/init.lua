-- This allows to use "hs" command from the terminal.
require("hs.ipc")

hs.configdir = os.getenv('HOME') .. '/.hammerspoon'
package.path = hs.configdir .. '/?.lua;' .. hs.configdir .. '/?/init.lua;' .. hs.configdir .. '/Spoons/?.spoon/init.lua;' .. package.path

-- Plugins (aka Spoons) {{{

local PassChooser = hs.loadSpoon('PassChooser')
PassChooser:bindHotkeys({
  show={{'cmd'}, 'p'},
})
PassChooser:init({
  clearAfter=10,
})

-- }}}

-- Libraries {{{

local function openApp(app_name, new)
  new = new or false

  local s = 'open'
  if new then
    s = s .. ' -n'
  end
  s = s .. " -a '/Applications/" .. app_name .. ".app'"

  hs.execute(s)
end

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

  hs.osascript.applescript(s)
  -- notify.sh sends with the bundle id of kitty, or of Claude desktop for
  -- claude-notify.sh.
  hs.execute('/opt/homebrew/bin/alerter --remove "notify" --sender "net.kovidgoyal.kitty" 2>/dev/null', true)
  hs.execute('/opt/homebrew/bin/alerter --remove "notify" --sender "com.anthropic.claudefordesktop" 2>/dev/null', true)
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

local function focusFrontmost()
  local frontmostWindow = hs.window.frontmostWindow()
  frontmostWindow:focus()
end

local function setFrontmostWindowPosition(fn)
  local frontmostWindow = hs.window.frontmostWindow()
  local currentScreen = frontmostWindow:screen()
  local frame = currentScreen:frame()
  -- Offset from frame, which starts below the menu bar. Most apps move down out
  -- of the menu bar, some don't.
  local nextFrame = fn(frame.w, frame.h, frame.x, frame.y)
  nextFrame.x = nextFrame.x + frame.x
  nextFrame.y = nextFrame.y + frame.y
  frontmostWindow:setFrame(nextFrame)
end

-- }}}

-- Applications {{{

-- Finder.
hs.hotkey.bind({'cmd', 'shift'}, 'd', function()
  hs.execute('open -R ~/Downloads')
end)

-- kitty.
hs.hotkey.bind({'cmd', 'shift'}, 'return', function()
  -- The copy of home-manager, the same app that Spotlight opens.
  hs.execute("open -n '" .. os.getenv('HOME') .. "/Applications/Home Manager Apps/kitty.app'")
end)

-- Firefox.
hs.hotkey.bind({'cmd', 'shift'}, 'i', function()
  openApp('Firefox', true)
end)

-- Slack.
hs.hotkey.bind({'cmd', 'shift'}, 's', function()
  openApp('Slack')
end)

-- Spark.
hs.hotkey.bind({'cmd', 'shift'}, 'a', function()
  openApp('Spark')
end)

-- }}}

-- Utils {{{

-- Close notifications.
hs.hotkey.bind({'cmd'}, '/', function()
  closeNotifications()
end)

-- Clear clipboard.
hs.hotkey.bind({'cmd'}, '.', function()
  hs.pasteboard.setContents('')
  hs.alert.show('Clipboard cleared')
end)

-- Connect AirPods.
hs.hotkey.bind({'cmd'}, '\\', function()
  local ok, output = airPods('daGrevis’ AirPods')
  if ok then
    hs.alert.show(output)
  else
    hs.alert.show("Couldn't connect to AirPods!")
  end
end)

-- }}}

-- Window Management {{{

-- Focus previously used window of the same app.
local function focusPreviouslyUsedWindow(fn)
  local front_app = hs.application.frontmostApplication()

  local windows
  -- kitty opens with "open -n", so each window is an app of its own.
  if front_app:name() == 'kitty' then
    local rest_apps = hs.fnutils.ifilter({hs.application.find(front_app:name())}, function(app)
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
end

-- For some reason, need to bind backtick/grave key in different ways to make sure it always works for the keyboards I'm using.
local backticks = {'`', 0x32, 10}

for _, backtick in ipairs(backticks) do
  hs.hotkey.bind({'cmd'}, backtick, function()
    focusPreviouslyUsedWindow()
  end)
end

-- Toggle fullscreen.
hs.hotkey.bind({'cmd', 'ctrl'}, 'f', function()
  local frontmostWindow = hs.window.frontmostWindow()
  frontmostWindow:maximize()
end)

-- Maximize kitty windows that don't fit on their screen. They
-- have no decorations, so macOS doesn't know that a window is maximized and keeps the
-- old size when a screen goes away. macOS still moves the window, and that move
-- triggers this. Global, so that it isn't garbage collected.
terminalWindowFilter = hs.window.filter.new(false)
  :setAppFilter('kitty', {allowRoles='AXStandardWindow'})
  :subscribe(hs.window.filter.windowMoved, function(window)
    local screenFrame = window:screen():frame()
    local windowFrame = window:frame()
    if windowFrame.w > screenFrame.w or windowFrame.h > screenFrame.h then
      window:maximize()
    end
  end)

-- Move window to other screen.
hs.hotkey.bind({'cmd', 'ctrl'}, 'tab', function()
  local frontmostWindow = hs.window.frontmostWindow()
  local currentScreen = frontmostWindow:screen()
  local allScreens = hs.screen.allScreens()
  local nextScreen = hs.fnutils.find(allScreens, function(screen)
    return screen:id() ~= currentScreen:id()
  end)
  if nextScreen then
    frontmostWindow:moveToScreen(nextScreen)
    frontmostWindow:maximize()
  end
end)

-- Center window.
hs.hotkey.bind({'cmd', 'ctrl'}, 'c', function()
  local frontmostWindow = hs.window.frontmostWindow()
  frontmostWindow:setSize({w=1280, h=800})
  frontmostWindow:centerOnScreen()
end)

-- Fill left-half of screen.
hs.hotkey.bind({'cmd', 'alt'}, 'left', function()
  setFrontmostWindowPosition(function(w, h, x, y)
    return {w=w / 2, h=h, x=0, y=0}
  end)
end)

-- Fill right-half of screen.
hs.hotkey.bind({'cmd', 'alt'}, 'right', function()
  setFrontmostWindowPosition(function(w, h, x, y)
    return {w=w / 2, h=h, x=w / 2, y=0}
  end)
end)

-- Fill top-half of screen.
hs.hotkey.bind({'cmd', 'alt'}, 'up', function()
  setFrontmostWindowPosition(function(w, h, x, y)
    return {w=w, h=h / 2, x=0, y=0}
  end)
end)

-- Fill bottom-half of screen.
hs.hotkey.bind({'cmd', 'alt'}, 'down', function()
  setFrontmostWindowPosition(function(w, h, x, y)
    return {w=w, h=h / 2, x=0, y=h / 2}
  end)
end)

-- Minimize window.
hs.hotkey.bind({'cmd'}, 'h', function()
  local frontmostWindow = hs.window.frontmostWindow()
  frontmostWindow:minimize()
end)

-- Minimize everything aka go to the desktop. Press again to bring it all back.
local minimizedWindows = {}
local windowToRefocus = nil

hs.hotkey.bind({'cmd', 'ctrl'}, 'h', function()
  if #minimizedWindows > 0 then
    -- Reverse order, so that the last minimized window ends up on top.
    for i = #minimizedWindows, 1, -1 do
      local window = minimizedWindows[i]
      if window:isMinimized() then
        window:unminimize()
      end
    end

    minimizedWindows = {}

    if windowToRefocus then
      windowToRefocus:focus()
      windowToRefocus = nil
    end

    return
  end

  local frontmostWindow = hs.window.frontmostWindow()
  local currentScreeen = frontmostWindow:screen()

  local allWindows = hs.window.allWindows()

  for _, window in pairs(allWindows) do
    if currentScreeen == window:screen() and not window:isMinimized() then
      window:minimize()
      table.insert(minimizedWindows, window)
    end
  end

  windowToRefocus = frontmostWindow
end)

-- Forget the minimized windows when a window comes back or opens in some other
-- way, so that the next press minimizes everything again. Global, so that it
-- isn't garbage collected.
minimizedWindowsResetFilter = hs.window.filter.new(false)
  :setDefaultFilter({allowRoles='AXStandardWindow'})
  :subscribe({hs.window.filter.windowUnminimized, hs.window.filter.windowCreated}, function()
    minimizedWindows = {}
    windowToRefocus = nil
  end)

-- }}}

-- }}}

-- Other {{{

hs.window.animationDuration = 0

hs.console.darkMode(true)

-- }}}

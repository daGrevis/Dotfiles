local YABAI_PATH = '/usr/local/bin/yabai'

hs.alert.show('Hammerspoon loaded')

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

local function open_app(app_name, new)
  new = new or false

  local s = 'open'
  if new then
    s = s .. ' -n'
  end
  s = s .. " -a '/Applications/" .. app_name .. ".app'"

  hs.execute(s)
end

local function _yabai(message)
  return hs.execute(YABAI_PATH .. ' -m ' .. message)
end

local function yabai(message)
  local _, status = _yabai(message)
  return status or false
end

local function yabaiQuery(message)
  local output = _yabai('query ' .. message)
  return hs.json.decode(output)
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

  return hs.osascript.applescript(s)
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

-- }}}

-- Applications {{{

-- Finder.
hs.hotkey.bind({'cmd', 'shift'}, 'd', function()
  hs.execute('open -R ~/Downloads')
end)

-- Alacritty.
hs.hotkey.bind({'cmd', 'shift'}, 'return', function()
  open_app('Alacritty', true)
end)

-- Firefox DE.
hs.hotkey.bind({'cmd', 'shift'}, 'i', function()
  open_app('Firefox Developer Edition', true)
end)

-- Slack.
hs.hotkey.bind({'cmd', 'shift'}, 's', function()
  open_app('Slack')
end)

-- Spark.
hs.hotkey.bind({'cmd', 'shift'}, 'a', function()
  open_app('Spark')
end)

-- }}}

-- Utils {{{

-- Start screensaver.
hs.hotkey.bind({'cmd'}, '/', function()
  hs.caffeinate.startScreensaver()
end)

-- Clear clipboard.
hs.hotkey.bind({'cmd'}, '.', function()
  hs.pasteboard.setContents('')
  hs.alert.show('Clipboard cleared')
end)

-- Close notifications.
hs.hotkey.bind({'ctrl'}, 'space', function()
  closeNotifications()
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

-- Focus space without delay.
for i = 0, 9 do
  local key = tostring(i)
  hs.hotkey.bind({'ctrl'}, key, function()
    yabai('space --focus ' .. key)
  end)
end

-- Focus the previous space.
hs.hotkey.bind({'ctrl'}, '[', function()
  return yabai('space --focus prev') or yabai('space --focus 9')
end)

-- Focus the next space.
hs.hotkey.bind({'ctrl'}, ']', function()
  return yabai('space --focus next') or yabai('space --focus 1')
end)

-- Toggle between float and bsp layout.
hs.hotkey.bind({'cmd', 'ctrl'}, 'e', function()
  local space = yabaiQuery('--spaces --space')
  yabai('space --layout ' .. (space.type == 'float' and 'bsp' or 'float'))
end)

-- Toggle fullscreen.
hs.hotkey.bind({'cmd', 'ctrl'}, 'f', function()
  local space = yabaiQuery('--spaces --space')
  if space.type == 'float' then
    yabai('window --grid 1:1:0:0:1:1')
  else
    yabai('window --toggle zoom-fullscreen')
  end
end)

-- Center window.
hs.hotkey.bind({'cmd', 'ctrl'}, 'c', function()
  yabai('window --grid 4:4:1:1:2:2')
end)

-- Fill left-half of screen.
hs.hotkey.bind({'cmd', 'alt'}, 'left', function()
  yabai('window --grid 1:2:0:0:1:1')
end)

-- Fill right-half of screen.
hs.hotkey.bind({'cmd', 'alt'}, 'right', function()
  yabai('window --grid 1:2:1:0:1:1')
end)

-- Fill top-half of screen.
hs.hotkey.bind({'cmd', 'alt'}, 'up', function()
  yabai('window --grid 2:1:0:0:1:1')
end)

-- Fill bottom-half of screen.
hs.hotkey.bind({'cmd', 'alt'}, 'down', function()
  yabai('window --grid 2:1:0:1:1:1')
end)

-- Move window to left.
hs.hotkey.bind({'cmd', 'ctrl'}, 'left', function()
  yabai('window --move rel:-50:0')
end)

-- Move window to right.
hs.hotkey.bind({'cmd', 'ctrl'}, 'right', function()
  yabai('window --move rel:50:0')
end)

-- Move window to top.
hs.hotkey.bind({'cmd', 'ctrl'}, 'up', function()
  yabai('window --move rel:0:-50')
end)

-- Move window to bottom.
hs.hotkey.bind({'cmd', 'ctrl'}, 'down', function()
  yabai('window --move rel:0:50')
end)

-- Increase size of window to left.
hs.hotkey.bind({'cmd', 'ctrl', 'shift'}, 'left', function()
  yabai('window --resize left:-50:0')
end)

-- Increase size of window to right.
hs.hotkey.bind({'cmd', 'ctrl', 'shift'}, 'right', function()
  yabai('window --resize right:50:0')
end)

-- Increase size of window to top.
hs.hotkey.bind({'cmd', 'ctrl', 'shift'}, 'up', function()
  yabai('window --resize top:0:-50')
end)

-- Increase size of window to bottom.
hs.hotkey.bind({'cmd', 'ctrl', 'shift'}, 'down', function()
  yabai('window --resize bottom:0:50')
end)

-- Decrease size of window to left.
hs.hotkey.bind({'cmd', 'ctrl', 'alt'}, 'left', function()
  yabai('window --resize left:50:0')
end)

-- Decrease size of window to right.
hs.hotkey.bind({'cmd', 'ctrl', 'alt'}, 'right', function()
  yabai('window --resize right:-50:0')
end)

-- Decrease size of window to top.
hs.hotkey.bind({'cmd', 'ctrl', 'alt'}, 'up', function()
  yabai('window --resize top:0:50')
end)

-- Decrease size of window to bottom.
hs.hotkey.bind({'cmd', 'ctrl', 'alt'}, 'down', function()
  yabai('window --resize bottom:0:-50')
end)

-- }}}

-- Config & Development {{{

-- Auto-restart on config changes.
local config_path = os.getenv('HOME') .. '/.hammerspoon/init.lua'
hs.pathwatcher.new(config_path, function()
  hs.reload()
end):start()

-- Restart.
hs.hotkey.bind({'cmd', 'shift'}, 'r', function()
  hs.relaunch()
end)

-- Toggle console.
hs.hotkey.bind({'cmd', 'shift'}, 'e', function()
  hs.toggleConsole()
  focusFrontmost()
end)

-- }}}

-- Other {{{

hs.window.animationDuration = 0

hs.console.darkMode(true)

-- }}}

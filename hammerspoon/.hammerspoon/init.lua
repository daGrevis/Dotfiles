local YABAI_PATH = '/usr/local/bin/yabai'

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
  open_app('Firefox Developer Edition', true)
end)

hs.hotkey.bind({'cmd', 'shift'}, 's', function()
  open_app('Slack')
end)

hs.hotkey.bind({'cmd', 'shift'}, 'a', function()
  open_app('Spark')
end)

hs.hotkey.bind({'cmd', 'shift'}, 'd', function()
  hs.execute('open -R ~/Downloads')
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

-- Focus on space without delay.
for i = 0, 9 do
  local key = tostring(i)
  hs.hotkey.bind({'ctrl'}, key, function()
    yabai('space --focus ' .. key)
  end)
end

-- Focus on prev space.
hs.hotkey.bind({'ctrl'}, '[', function()
  return yabai('space --focus prev') or yabai('space --focus 9')
end)

-- Focus on next space.
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
    yabai('window --grid "1:1:0:0:1:1"')
  else
    yabai('window --toggle zoom-fullscreen')
  end
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

hs.console.darkMode(true)

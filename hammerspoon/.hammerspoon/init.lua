local passchooser = require "passchooser/passchooser"

passchooser.bind()

hs.loadSpoon('ControlEscape'):start()

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function open_app(app_name, new)
  new = new or true

  local s = "open"
  if new then
    s = s .. " -n"
  end
  s = s .. " -a '/Applications/" .. app_name .. ".app'"

  hs.execute(s)
end

function open_iterm2()
  s = [[
    if application "iTerm" is running then
      tell application "iTerm"
        create window with default profile
      end tell
    else
      activate application "iTerm"
    end if
  ]]
  hs.osascript.applescript(s)
end

function kwmc(s)
  hs.execute("/usr/local/bin/kwmc " .. s)
end

hs.hotkey.bind({"cmd"}, "`", function()
  local front_app = hs.application.frontmostApplication()
  local visible_windows = front_app:visibleWindows()
  local standard_windows = hs.fnutils.ifilter(visible_windows, function(w)
    return w:subrole() == 'AXStandardWindow'
  end)

  if tablelength(standard_windows) > 1 then
    standard_windows[2]:focus()
  end
end)

local modeIndex = 0
hs.hotkey.bind({"cmd", "shift"}, "s", function()
  modeIndex = modeIndex + 1

  local index = modeIndex % 3

  if index == 0 then
    kwmc("space -t monocle")
    hs.alert.show("monocle")
  end

  if index == 1 then
    hs.alert.show("float")
    kwmc("space -t float")
  end

  if index == 2 then
    hs.alert.show("bsp")
    kwmc("space -t bsp")
  end
end)

hs.hotkey.bind({"cmd"}, "e", function()
  kwmc("tree rotate 180")
end)

hs.hotkey.bind({"cmd", "shift"}, "e", function()
  kwmc("tree rotate 90")
end)

hs.hotkey.bind({"cmd", "shift"}, "h", function()
  kwmc("window -c expand 0.05 west")
end)
hs.hotkey.bind({"cmd", "shift"}, "j", function()
  kwmc("window -c expand 0.05 south")
end)
hs.hotkey.bind({"cmd", "shift"}, "k", function()
  kwmc("window -c expand 0.05 north")
end)
hs.hotkey.bind({"cmd", "shift"}, "l", function()
  kwmc("window -c expand 0.05 east")
end)

hs.hotkey.bind({"cmd", "alt"}, "f", function()
  kwmc("window -z fullscreen")
end)

hs.hotkey.bind({"cmd"}, "/", function()
  hs.caffeinate.startScreensaver()
end)

hs.hotkey.bind({"cmd"}, ".", function()
  hs.pasteboard.setContents('')
  hs.alert.show("clipboard cleared")
end)

hs.hotkey.bind({"cmd", "shift"}, "return", function()
  open_iterm2()
end)

hs.hotkey.bind({"cmd", "shift"}, "i", function()
  open_app("Google Chrome")
end)

config_path = os.getenv("HOME") .. "/.hammerspoon/"
config_path_watcher = hs.pathwatcher.new(config_path, function()
  hs.reload()
end
):start()

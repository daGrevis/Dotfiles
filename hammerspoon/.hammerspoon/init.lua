local passchooser = require "passchooser/passchooser"

passchooser.bind()

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
    tell application "iTerm2"
    create window with default profile
    end tell
  ]]
  hs.osascript.applescript(s)
end

function kwmc(s)
  hs.execute("/usr/local/bin/kwmc " .. s)
end

send_escape = false
last_mods = {}

control_key_timer = hs.timer.delayed.new(0.15, function()
  send_escape = false
end
)

last_mods = {}

flags_changed_watcher = hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, function(ev)
  local new_mods = ev:getFlags()

  if last_mods["ctrl"] == new_mods["ctrl"] then
    return false
  end
  if not last_mods["ctrl"] then
    last_mods = new_mods
    send_escape = true
    control_key_timer:start()
  else
    if send_escape then
      hs.eventtap.keyStroke({}, "ESCAPE")
    end
    last_mods = new_mods
    control_key_timer:stop()
  end

  return false
end
):start()

key_down_watcher = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(ev)
  send_escape = false
  return false
end
):start()

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

hs.hotkey.bind({"cmd"}, "b", function()
  kwmc("space -t bsp")
end)

hs.hotkey.bind({"cmd"}, "s", function()
  kwmc("space -t monocle")
end)

hs.hotkey.bind({"cmd"}, "d", function()
  kwmc("space -t float")
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

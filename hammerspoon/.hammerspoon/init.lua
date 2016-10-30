function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function open_app(name)
  hs.execute("open -a '/Applications/" .. name .. ".app'")
end

function kwmc(s)
  hs.execute("/usr/local/bin/kwmc " .. s)
end

ctrl_table = {
  sends_escape = true,
  last_mods = {}
}

control_key_timer = hs.timer.delayed.new(0.2, function()
  ctrl_table["send_escape"] = false
  -- log.i("timer fired")
end
)

last_mods = {}

flags_changed_watcher = hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, function(ev)
  local new_mods = ev:getFlags()

  if last_mods["ctrl"] == new_mods["ctrl"] then
    return false
  end
  if not last_mods["ctrl"] then
    -- log.i("control pressed")
    last_mods = new_mods
    ctrl_table["send_escape"] = true
    -- log.i("starting timer")
    control_key_timer:start()
  else
    -- log.i("contrtol released")
    -- log.i(ctrl_table["send_escape"])
    if ctrl_table["send_escape"] then
      -- log.i("triggering escape")
      hs.eventtap.keyStroke({}, "ESCAPE")
    end
    last_mods = new_mods
    control_key_timer:stop()
    return true
  end

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

hs.hotkey.bind({"cmd", "shift"}, "e", function()
  -- Restarts WM.
  kwmc("quit")
end)

hs.hotkey.bind({"cmd"}, "a", function()
  kwmc("space -t bsp")
end)

hs.hotkey.bind({"cmd"}, "s", function()
  kwmc("space -t monocle")
end)

hs.hotkey.bind({"cmd"}, "d", function()
  kwmc("space -t float")
end)

hs.hotkey.bind({"cmd"}, "r", function()
  kwmc("tree rotate 90")
end)

hs.hotkey.bind({"cmd"}, "e", function()
  kwmc("tree rotate 180")
end)

hs.hotkey.bind({"cmd", "alt"}, "f", function()
  kwmc("window -z fullscreen")
end)

hs.hotkey.bind({"cmd", "shift"}, "t", function()
  open_app("iTerm")
end)

hs.hotkey.bind({"cmd", "shift"}, "i", function()
  open_app("Google Chrome")
end)

hs.hotkey.bind({"cmd", "shift"}, "l", function()
  hs.caffeinate.startScreensaver()
end)

config_path = os.getenv("HOME") .. "/.hammerspoon/"
config_path_watcher = hs.pathwatcher.new(config_path, function()
  hs.reload()
end
):start()

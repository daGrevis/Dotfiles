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
function chunkc(s)
  hs.execute("/usr/local/bin/chunkc " .. s)
end

-- Focus previously used window of the same app.
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

-- Change between layout modes: monocle, float or bsp.
local modeIndex = 0
hs.hotkey.bind({"cmd", "shift"}, "s", function()
  modeIndex = modeIndex + 1

  local index = modeIndex % 3

  if index == 0 then
    hs.alert.show("mode: monocle")
    chunkc("tiling::desktop --layout monocle")
  end

  if index == 1 then
    hs.alert.show("mode: float")
    chunkc("tiling::desktop --layout float")
  end

  if index == 2 then
    hs.alert.show("mode: bsp")
    chunkc("tiling::desktop --layout bsp")
  end
end)

-- Focus windows.
-- TODO: Fix C-l
-- hs.hotkey.bind({"cmd"}, "h", function()
--   chunkc("tiling::window --focus west")
-- end)
-- hs.hotkey.bind({"cmd"}, "j", function()
--   chunkc("tiling::window --focus south")
-- end)
-- hs.hotkey.bind({"cmd"}, "k", function()
--   chunkc("tiling::window --focus north")
-- end)
-- hs.hotkey.bind({"cmd"}, "l", function()
--   chunkc("tiling::window --focus east")
-- end)

-- Resize windows.
hs.hotkey.bind({"cmd", "shift"}, "h", function()
  chunkc("tiling::window --use-temporary-ratio 0.05 --adjust-window-edge west")
end)
hs.hotkey.bind({"cmd", "shift"}, "j", function()
  chunkc("tiling::window --use-temporary-ratio 0.05 --adjust-window-edge south")
end)
hs.hotkey.bind({"cmd", "shift"}, "k", function()
  chunkc("tiling::window --use-temporary-ratio 0.05 --adjust-window-edge north")
end)
hs.hotkey.bind({"cmd", "shift"}, "l", function()
  chunkc("tiling::window --use-temporary-ratio 0.05 --adjust-window-edge east")
end)

-- Rotate desktops.
hs.hotkey.bind({"cmd"}, "e", function()
  chunkc("tiling::desktop --rotate 180")
end)
hs.hotkey.bind({"cmd", "shift"}, "e", function()
  chunkc("tiling::desktop --rotate 90")
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

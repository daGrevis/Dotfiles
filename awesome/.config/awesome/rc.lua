pcall(require, "luarocks.loader")

local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")

if awesome.startup_errors then
  naughty.notify({
    preset = naughty.config.presets.critical,
    title = "Oops, there were errors during startup!",
    text = awesome.startup_errors
  })
end

do
  local in_error = false
  awesome.connect_signal("debug::error", function(err)
    if in_error then return end
    in_error = true

    naughty.notify({
      preset = naughty.config.presets.critical,
      title = "Oops, an error happened!",
      text = tostring(err)
    })
    in_error = false
  end)
end

modkey = "Mod1"
terminal = "alacritty"

mono_1 = "#abb2bf"
syntax_bg = "#282c34"
pmenu = "#333841"

beautiful.init({
  font = "VictorMono Nerd Font 12",
  bg_normal = syntax_bg,
  fg_normal = mono_1,
  bg_focus = pmenu,
  fg_focus = mono_1,
  useless_gap = 0,
  border_width = 0,
  tasklist_plain_task_name = true,
})

gears.wallpaper.set(syntax_bg)

menubar.utils.terminal = terminal
menubar.show_categories = false

awful.layout.layouts = {
  awful.layout.suit.max,
}

local tasklist_buttons = gears.table.join(
  awful.button(
    {},
    1,
    function(c)
      c:emit_signal(
        "request::activate",
        "tasklist",
        {raise = true}
      )
    end
  )
)

awful.screen.connect_for_each_screen(function(s)
  awful.tag({"1"}, s, awful.layout.layouts[1])

  s.prompt = awful.widget.prompt()

  s.tasklist = awful.widget.tasklist {
    screen = s,
    filter = awful.widget.tasklist.filter.currenttags,
    buttons = tasklist_buttons,
    layout = {
      layout = wibox.layout.fixed.horizontal,
    },
    widget_template = {
      {
        {
          {
            id = "text_role",
            widget = wibox.widget.textbox,
          },
          layout = wibox.layout.fixed.horizontal,
        },
        left = 10,
        right = 10,
        widget = wibox.container.margin,
      },
      id = "background_role",
      widget = wibox.container.background,
    }
  }
  s.tasklist.update_callback = function()
  end

  s.wibar = awful.wibar({
    position = "top",
    screen = s,
    height = 20
  })

  s.wibar:setup {
    layout = wibox.layout.align.horizontal,
    s.tasklist,
    s.prompt
  }
end)

global_keys = gears.table.join(
  awful.key(
    {modkey, "Shift"},
    "Return",
    function()
      awful.spawn(terminal)
    end
  ),

  awful.key(
    {modkey, "Control"},
    "r",
    function()
      awesome.restart()
    end
  ),

  awful.key(
    {modkey},
    "space",
    function()
      menubar.show()
    end
  )
)

root.keys(global_keys)

client_keys = gears.table.join(
  awful.key(
    {modkey},
    "q",
    function(c)
      c:kill()
    end
  ),

  awful.key(
    {modkey},
    "`",
    function()
      awful.client.focus.history.previous()
      if client.focus then
        client.focus:raise()
      end
    end
  )
)

client.connect_signal("unmanage", function()
  local c = awful.client.focus.history.get(s, 0)
  if c == nil then return end
  c:emit_signal(
    "request::activate",
    "tasklist",
    {raise = true}
  )
end)

awful.rules.rules = {
  {
    rule = {},
    properties = {
      focus = awful.client.focus.filter,
      raise = true,
      keys = client_keys,
      screen = awful.screen.preferred,
      placement = awful.placement.no_overlap + awful.placement.no_offscreen
    }
  }
}

awful.spawn.easy_async("pidof " .. terminal, function(stdout, stderr, reason, exit_code)
  local has_terminal_running = exit_code == 0
  if not has_terminal_running then
    awful.spawn(terminal)
  end
end)
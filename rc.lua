local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
require("eminent") -- Must be after awful.
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local vicious = require("vicious")

function debug(what)
    naughty.notify({preset = naughty.config.presets.critical,
                    title = "Spanish inquisition",
                    text = what})
end

if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end

beautiful.init(awful.util.getdir("config") .. "/themes/default/theme.lua")

modkey = "Mod4"
terminal = "urxvt"
editor = os.getenv("EDITOR") or "vi"
editor_cmd = terminal .. " -e " .. editor
browser = "chromium"
browser_incognito = "chromium --incognito"
bittorrent_client = "transmission-gtk"
irc_client = "sh ~/Scripts/hexchat_once.sh"

function spawn_in_terminal(command)
    awful.util.spawn(terminal .. " -e " .. command)
end

local layouts =
{
    awful.layout.suit.max,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.max.fullscreen
}

if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end

tags = {}
for s = 1, screen.count() do
    tags[s] = awful.tag({"I", "II", "III", "IV", "V",
                         "VI", "VII", "VIII", "IX"}, s, layouts[1])
end

-- Widgets.

textclock_widget = awful.widget.textclock("%d/%m/%y, %H:%M:%S", 1)

mem_widget = wibox.widget.textbox()
vicious.register(mem_widget, vicious.widgets.mem, "$1% ($2/$3 MB)", 1)

cpu_widget = wibox.widget.textbox()
vicious.register(cpu_widget, vicious.widgets.cpu, "$1% $2% $3% $4%", 1)

net_widget = wibox.widget.textbox()
vicious.register(net_widget,
                 vicious.widgets.net, "${enp3s0 down_kb}/${enp3s0 up_kb} kB/s")

separator_widget = wibox.widget.textbox()
separator_widget:set_text("  ")


-- Builds topbar.

my_wibox = {}
my_layoutbox = {}
my_taglist = {}

for s = 1, screen.count() do
    my_layoutbox[s] = awful.widget.layoutbox(s)
    my_taglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all,
                                         my_taglist.buttons)

    my_wibox[s] = awful.wibox({ position = "top", screen = s })

    local left_layout = wibox.layout.fixed.horizontal()

    left_layout:add(my_taglist[s])

    local right_layout = wibox.layout.fixed.horizontal()

    right_layout:add(separator_widget)

    right_layout:add(textclock_widget)

    right_layout:add(separator_widget)

    right_layout:add(mem_widget)

    right_layout:add(separator_widget)

    right_layout:add(cpu_widget)

    right_layout:add(separator_widget)

    right_layout:add(net_widget)

    right_layout:add(separator_widget)

    if s == 1 then right_layout:add(wibox.widget.systray()) end

    right_layout:add(separator_widget)

    right_layout:add(my_layoutbox[s])

    local layout = wibox.layout.align.horizontal()

    layout:set_left(left_layout)
    layout:set_right(right_layout)

    my_wibox[s]:set_widget(layout)
end

keys = awful.util.table.join(
    awful.key({ modkey, }, "j",
        function()
            awful.client.focus.byidx(1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey, }, "k",
        function()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey, "Shift" }, "j", function()
        awful.client.swap.byidx(1)
    end),
    awful.key({ modkey, "Shift" }, "k", function()
        awful.client.swap.byidx(-1)
    end),
    awful.key({ modkey, "Control" }, "j", function()
        awful.screen.focus_relative(1)
    end),
    awful.key({ modkey, "Control" }, "k", function()
        awful.screen.focus_relative(-1)
    end),
    awful.key({ modkey, }, "Tab",
        function()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    awful.key({ modkey, "Shift" }, "Return", function()
        awful.util.spawn(terminal)
    end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift" }, "q", awesome.quit),

    awful.key({ modkey, }, "l", function()
        awful.tag.incmwfact(0.05)
    end),
    awful.key({ modkey, }, "h", function()
        awful.tag.incmwfact(-0.05)
    end),
    awful.key({ modkey, "Shift" }, "h", function()
        awful.tag.incnmaster(1)
    end),
    awful.key({ modkey, "Shift" }, "l", function()
        awful.tag.incnmaster(-1)
    end),
    awful.key({ modkey, }, "space", function()
        awful.layout.inc(layouts,  1)
    end),
    awful.key({ modkey, "Shift" }, "space", function()
        awful.layout.inc(layouts, -1)
    end),

    awful.key({modkey, "Shift"}, "m", function()
        spawn_in_terminal("alsamixer")
    end),
    awful.key({modkey, "Shift"}, "i", function()
        awful.util.spawn(browser)
    end),
    awful.key({modkey, "Control"}, "i", function()
        awful.util.spawn(browser_incognito)
    end),
    awful.key({modkey, "Shift"}, "b", function()
        awful.util.spawn(bittorrent_client)
    end),
    awful.key({modkey, "Shift"}, "x", function()
        awful.util.spawn_with_shell(irc_client)
    end),
    awful.key({modkey, "Shift"}, "v", function()
        awful.util.spawn("gvim")
    end),
    awful.key({modkey}, "p", function()
        awful.util.spawn(
            "dmenu_run -i " ..
            "-nb '" ..  beautiful.bg_normal ..
            "' -nf '" .. beautiful.fg_normal ..
            "' -sb '" .. beautiful.bg_focus ..
            "' -sf '" .. beautiful.fg_focus ..
            "' -fn 'Tamsyn-10'")
    end),
    awful.key({modkey, "Shift"}, "l", function()
        awful.util.spawn("slock")
    end)
)

client_keys = awful.util.table.join(
    awful.key({ modkey, }, "f", function(c)
        c.fullscreen = not c.fullscreen
    end),
    awful.key({ modkey, "Shift" }, "c", function(c)
        c:kill()
    end)
)

client_buttons = awful.util.table.join(
    awful.button({ }, 1, function (c)
        awful.screen.focus(mouse.screen)

        client.focus = c;
        c:raise()
    end))

for i = 1, 9 do
    keys = awful.util.table.join(keys,
        awful.key({ modkey }, "#" .. i + 9,
                  function()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        awful.key({ modkey, }, "o", awful.client.movetoscreen))
end

root.keys(keys)

awful.rules.rules = {
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = client_keys,
                     buttons = client_buttons } },
    { rule = { class = "gimp" },
      properties = { floating = true } }
}

client.connect_signal("focus", function(c)
    c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
    c.border_color = beautiful.border_normal
end)

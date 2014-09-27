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

function is_integer(x)
    return tonumber(x) ~= nil
end

beautiful.init(awful.util.getdir("config") .. "/themes/default/theme.lua")

function debug(what)
    if type(what) == "nil" then
        what = "nil"
    end
    if type(what) == "boolean" then
        if what == true then
            what = "true"
        else
            what = "false"
        end
    end
    naughty.notify({title = "Debug",
                    text = what,
                    bg = beautiful.color_red,
                    fg = beautiful.color_black0,
                    border_width = 0})
end

function get_hostname()
    return io.popen("uname -n"):read()
end

function get_network_interface()
    return io.popen("ip route get 8.8.8.8 | awk '{ print $5; exit }'"):read()
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

modkey = "Mod4"
terminal = "xfce4-terminal"
editor = os.getenv("EDITOR") or "vi"
bittorrent_client = "transmission-gtk"
irc_client = "sh ~/Scripts/hexchat_once.sh"

function spawn_in_terminal(command)
    awful.util.spawn(terminal .. " -e " .. command)
end

local layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
}

tags = {}
for s = 1, screen.count() do
    if beautiful.wallpaper then
        gears.wallpaper.centered(beautiful.wallpaper, s)
    end

    tags[s] = awful.tag({"1", "2", "3", "4", "5",
                         "6", "7", "8", "9"}, s, layouts[1])
end

menu_items = {
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

menu = awful.menu({
    items = {
        { "awesome", menu_items, beautiful.awesome_icon },
        { "open terminal", terminal }
    }
})

launcher = awful.widget.launcher({
    image = beautiful.awesome_icon,
    menu = menu
})

-- Widgets.

textclock_widget = awful.widget.textclock("%y/%m/%d (%A), %H:%M:%S", 1)

mem_widget = wibox.widget.textbox()
vicious.register(mem_widget, vicious.widgets.mem, "$1% ($2/$3 MB)", 1)

cpu_widget = wibox.widget.textbox()
vicious.register(cpu_widget, vicious.widgets.cpu, function(_, t)
    return table.concat(t, "% ") .. "%"
end)

net_widget = wibox.widget.textbox()
vicious.register(net_widget, vicious.widgets.net, function(widget, args)
                                network_interface = get_network_interface()
                                down_kb = args[string.format("{%s down_kb}", network_interface)] or 0
                                up_kb = args[string.format("{%s up_kb}", network_interface)] or 0
                                return string.format("%s/%s kB/s", down_kb, up_kb)
                            end)

function get_weather(widget, args)
    local s = ""
    local tempc = args["{tempc}"]
    local windmph = args["{windmph}"]
    if not is_integer(tempc) and not is_integer(windmph) then
        s = "N/A"
        return s
    end
    if is_integer(tempc) then
        s = string.format("%sC", tempc)
    end
    if is_integer(windmph) then
        local windmps = windmph / 2.237
        if is_integer(tempc) then
            s = string.format("%s, %d mps", s, windmps)
        else
            s = string.format("%d mps", windmps)
        end
    end
    return s
end
weather_widget = wibox.widget.textbox()
weather_timer = timer({ timeout = 10 })
weather_timer:connect_signal("timeout", function()
    vicious.unregister(weather_widget, true)
    vicious.activate(weather_widget)
end)
vicious.register(weather_widget, vicious.widgets.weather, function(widget, args)
    local s = get_weather(widget, args)
    if s == "N/A" then
        weather_timer.start(weather_timer)
        return s
    end
    weather_timer.stop(weather_timer)
    return s
end, 1200, "EVRA")

bat_widget = wibox.widget.textbox()
function set_bat(bat_widget)
    local s = ""
    local output = io.popen("acpi"):read()
    if not output then
        s = "N/A"
        bat_widget:set_text(s)
        return
    end
    local percentage = string.match(output, ".-(%d+)%%")
    local time_left = string.match(output, ".-(%d+:%d+)")
    local is_charging = string.find(output, "Charging") ~= nil
    local is_full = string.find(output, "Full") ~= nil
    s = string.format("%s%%", percentage, time_left)
    if time_left then
        s = s .. string.format("/%s", time_left)
    end
    if is_charging or is_full then
        s = s .. " ↯"
    end
    bat_widget:set_text(s)
end
set_bat(bat_widget)
bat_timer = timer({ timeout = 10 })
bat_timer:connect_signal("timeout", function()
    set_bat(bat_widget)
end)
bat_timer.start(bat_timer)

volume_widget = wibox.widget.textbox()
vicious.register(volume_widget, vicious.widgets.volume, "$1% $2", 1, "Master")

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

    left_layout:add(launcher)

    left_layout:add(my_taglist[s])

    local right_layout = wibox.layout.fixed.horizontal()

    if screen.count() == 1 or s == 2 then

        right_layout:add(textclock_widget)

        right_layout:add(separator_widget)

        right_layout:add(mem_widget)

        right_layout:add(separator_widget)

        right_layout:add(cpu_widget)

        right_layout:add(separator_widget)

        right_layout:add(net_widget)

        right_layout:add(separator_widget)

        if get_hostname() ~= "rx-wks-44" then

            right_layout:add(volume_widget)

            right_layout:add(separator_widget)

            right_layout:add(bat_widget)

            right_layout:add(separator_widget)

        end

        right_layout:add(weather_widget)

        right_layout:add(separator_widget)

        right_layout:add(wibox.widget.systray())

        right_layout:add(separator_widget)

    end

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
        awful.screen.focus_relative(1)
    end),
    awful.key({ modkey, "Shift" }, "k", function()
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
    awful.key({ modkey, "Control" }, "q", awesome.quit),
    awful.key({modkey, "Control"}, "l", function()
        awful.util.spawn("./Scripts/lock.sh")
    end),

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

    awful.key({modkey, "Shift"}, "i", function()
        awful.util.spawn("firefox")
    end),
    awful.key({modkey, "Control"}, "i", function()
        awful.util.spawn("firefox -private")
    end),
    awful.key({modkey, "Shift"}, "b", function()
        awful.util.spawn(bittorrent_client)
    end),
    awful.key({modkey, "Shift"}, "x", function()
        awful.util.spawn_with_shell(irc_client)
    end),
    awful.key({modkey, "Shift"}, "z", function()
        awful.util.spawn("hipchat")
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
            "' -fn 'Meslo LG M DZ-8'")
    end),
    awful.key({modkey, "Control"}, "p", function()
        awful.util.spawn(
            "passmenu -i " ..
            "-nb '" ..  beautiful.bg_normal ..
            "' -nf '" .. beautiful.fg_normal ..
            "' -sb '" .. beautiful.bg_focus ..
            "' -sf '" .. beautiful.fg_focus ..
            "' -fn 'Meslo LG M DZ-8'")
    end),
    awful.key({}, "Print", function()
        awful.util.spawn("scrot '%Y-%m-%d_%X__$wx$h.jpg' -q 90 -e 'mv $f ~/Screenshots/'")
    end),
    awful.key({modkey, "Shift"}, "e", function()
        awful.util.spawn("mousepad")
    end),
    awful.key({modkey, "Shift"}, "r", function()
        spawn_in_terminal("ranger")
    end),
    awful.key({modkey, "Shift"}, "m", function()
        spawn_in_terminal("alsamixer")
    end),
    awful.key({modkey, "Shift"}, "n", function()
        awful.util.spawn("firefox --new-window https://play.spotify.com/playlist")
    end),
    awful.key({modkey, "Shift"}, "'", function()
        awful.util.spawn("firefox --new-window http://devdocs.io/")
    end),
    awful.key({modkey, "Shift"}, "d", function()
        spawn_in_terminal("glances")
    end),
    awful.key({}, "XF86AudioMute", function()
        spawn_in_terminal("amixer -q set Master toggle")
    end),
    awful.key({}, "XF86AudioRaiseVolume", function()
        spawn_in_terminal("amixer -q set Master 1dB+")
    end),
    awful.key({}, "XF86AudioLowerVolume", function()
        spawn_in_terminal("amixer -q set Master 1dB-")
    end)
)

client_keys = awful.util.table.join(
    awful.key({ modkey, }, "f", function(c)
        c.fullscreen = not c.fullscreen
    end),
    awful.key({ modkey, "Shift" }, "c", function(c)
        c:kill()
    end),
    awful.key({ modkey, }, "m", function (c)
        c.maximized_horizontal = not c.maximized_horizontal
        c.maximized_vertical = not c.maximized_vertical
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
      properties = { floating = true } },
    { rule = { class = "Gvim" }, properties = { size_hints_honor = false } },
}

client.connect_signal("focus", function(c)
    c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
    c.border_color = beautiful.border_normal
end)

local hook = function(c)
    if c.maximized_horizontal == true and c.maximized_vertical == true then
        c.border_width = 0
    else
        c.border_width = beautiful.border_width
    end
end
client.connect_signal("property::maximized_horizontal", hook) client.connect_signal("property::maximized_vertical", hook)

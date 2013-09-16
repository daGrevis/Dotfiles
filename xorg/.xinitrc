#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

# Ugly hack to fix time.
{ sudo ntpd -qg; sudo hwclock -w; } &

# Sets 2nd monitor usable.
xrandr --output VGA-1 --auto --left-of DVI-I-1

# Sets cursor.
xsetroot -cursor_name left_ptr

# Keyboard layout.
setxkbmap -layout lv

# Loads `.Xresources`.
xrdb ~/.Xresources

# Loads `.Xmodmap`.
xmodmap ~/.Xmodmap

# Loads screensaver.
xscreensaver -no-splash &

# Battery indicator.
batti &

# Loads bar.
xmobar &

# Loads trayer.
trayer --height 20 --transparent true --alpha 0 --tint 0x000000 --edge top --align right --widthtype pixel --width 200 &

# Sets background.
feh --bg-fill ~/Pictures/drops.jpg &

# Clipboard manager.
parcellite &

# Calendar, contacts, tasks, notes etc..
osmo &

# Starts Chromium in background.
chromium --disable-sync-preferences --no-startup-window &

# Starts Thunar in background.
thunar --daemon &

# Starts Dropbox in background.
dropboxd &

# Loads WM.
exec xmonad

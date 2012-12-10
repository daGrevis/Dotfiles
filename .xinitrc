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
#xrandr --output VGA-1 --auto --left-of DVI-I-1

# Keyboard layout.
setxkbmap -layout lv

# Loads conf for terminal.
xrdb -merge ~/.Xresources

# Loads screensaver.
xscreensaver -no-splash &

# Remaps Caps Lock to Escape key.
xmodmap -e 'clear Lock' -e 'keycode 0x42 = Escape'

# Battery indicator.
#batti &

# Loads WM.
exec awesome

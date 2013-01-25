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

# Sets cursor.
xsetroot -cursor_name left_ptr

# Keyboard layout.
setxkbmap -layout lv

# Loads conf for terminal.
xrdb -merge ~/.Xresources

# Loads screensaver.
xscreensaver -no-splash &

# Remaps Caps Lock to Escape key.
xmodmap -e 'clear Lock' -e 'keycode 0x42 = Escape'

# Battery indicator.
batti &

# Loads bar.
xmobar &

# Loads trayer.
trayer --height 16 --transparent true --alpha 0 --tint 0x000000 --edge top --align right --widthtype pixel --width 200 &

feh --bg-scale Pictures/Arch_Linux_Darkwave_by_BalanceST_1920x1080.jpg &

# Starts Dropbox.
dropbox start &

# Loads WM.
exec xmonad

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

xrdb -merge ~/.Xresources

xsetroot -cursor_name left_ptr
setxkbmap -layout lv

xrandr --output VGA-1 --auto --left-of DVI-I-1

xscreensaver -no-splash &

trayer --edge top --align right  --expand true --width 16 --height 16 --transparent true --tint 0x000000 --margin 10 &

xmobar &

feh --bg-scale ~/Pictures/wallpaper.jpg

xmonad

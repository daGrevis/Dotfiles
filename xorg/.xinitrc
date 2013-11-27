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
xrandr --output HDMI3 --auto --output HDMI2 --auto --right-of HDMI3

# Sets cursor.
xsetroot -cursor_name left_ptr

# Keyboard layout.
setxkbmap -layout lv

# Makes Caps another Ctrl.
setxkbmap -option ctrl:nocaps

# Loads `.Xresources`.
xrdb ~/.Xresources

# Loads screensaver.
xscreensaver -no-splash &

# Battery indicator.
batti &

# Loads bar.
xmobar &

# Loads trayer.
trayer --height 20 --transparent true --alpha 0 --tint 0x000000 --edge top --align right --widthtype pixel --width 250 &

# Sets background.
feh --bg-scale ~/Pictures/ink_arch_by_deckon-d3hxm5b.jpg &

# Starts Chromium in background.
chromium --disable-sync-preferences --no-startup-window &

# Starts Thunar in background.
thunar --daemon &

# Clipboard manager.
clipit --daemon &

# Starts Dropbox in background.
dropboxd &

# Adjust brighntess based on current location and other factors.
redshift -l 57:24 &

gpg-agent --daemon &

# Loads WM.
exec xmonad

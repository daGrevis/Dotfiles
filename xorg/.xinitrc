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

if [ $(hostname) = "haze" ]; then
    ESCAPE_KEYCODE=9
    CAPS_KEYCODE=66
    LCONTROL_KEYCODE=37
fi;

# Make caps as control and escape at the same time. Based on super-caps by cmatheson.
xmodmap -e "clear Lock"
xmodmap -e "keycode $CAPS_KEYCODE = Control_L"
xmodmap -e "add Control = Control_L"
xmodmap -e "keysym Escape = Caps_Lock"
xmodmap -e "add Lock = Caps_Lock"
xmodmap -e "keycode 999 = Escape"
xcape -e "Control_L=Escape"
# Maps escape and left control to no-op.
xmodmap -e "keycode $ESCAPE_KEYCODE ="
xmodmap -e "keycode $LCONTROL_KEYCODE ="

# Loads `.Xresources`.
xrdb ~/.Xresources

# Loads screensaver.
xscreensaver -no-splash &

# Battery indicator.
batti &

# Loads bar.
xmobar &

# Loads trayer.
trayer --height 20 --transparent true --alpha 0 --tint 0x000000 --edge top --align right --widthtype pixel --width 200 &

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

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

# Sets 2nd monitor usable.
xrandr --output HDMI3 --auto --output HDMI2 --auto --right-of HDMI3

# Sets cursor.
xsetroot -cursor_name left_ptr

# Keyboard layout.
setxkbmap -layout lv

ESCAPE_KEYCODE=9
CAPS_KEYCODE=66
LCONTROL_KEYCODE=37

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
# xmobar &

# Loads trayer.
# trayer --height 20 --transparent true --alpha 0 --tint 0x000000 --edge top --align right --widthtype pixel --width 200 &

# Starts Thunar in background.
thunar --daemon &

# Clipboard manager.
clipit --daemon &

# Starts Dropbox in background.
dropboxd &

# Adjust brighntess based on current location and other factors.
redshift -l 57:24 &

# Starts GnuPG-agent.
gpg-agent --daemon &

# Loads WM.
exec awesome

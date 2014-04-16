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

HOME_HOSTNAME="haze"
WORK_HOSTNAME="rx-wks-44"

if [[ $(hostname) == $WORK_HOSTNAME ]]; then
    # Sets 2nd monitor usable.
    xrandr --output HDMI3 --auto --rotate left --output HDMI2 --auto --right-of HDMI3
fi

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

xautolock -time 10 -locker lock &

# To get my aliases working with awesome wm.
source ~/.zshrc

# Loads WM.
exec awesome

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

if [[ "$(hostname)" == $WORK_HOSTNAME ]]; then
    # Sets 2nd monitor usable.
    xrandr --output HDMI2 --auto --rotate left --output HDMI3 --auto --right-of HDMI2
fi

./Scripts/keyboard_settings.sh

# Loads `.Xresources`.
xrdb ~/.Xresources

# Starts Thunar in background.
thunar --daemon &

# Clipboard manager.
clipit --daemon &

# Adjust brighntess based on current location and other factors.
redshift -l 57:24 &

# Starts GnuPG-agent.
gpg-agent --daemon &

xautolock -time 10 -locker lock &

# To get my aliases working with awesome wm.
source ~/.zshrc

# Loads WM.
exec awesome
# exec startxfce4

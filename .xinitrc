#! /bin/bash

if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/*; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

PATH=$PATH:~/Scripts

HOME_HOSTNAME="haze"
WORK_HOSTNAME="rx-wks-44"

if [[ "$(hostname)" == $WORK_HOSTNAME ]]; then
    # Sets 2nd monitor usable.
    xrandr --output HDMI2 --auto --rotate left --output HDMI3 --auto --right-of HDMI2
fi

./Scripts/keyboard_settings.sh

# Adjust brighntess based on current location and other factors.
redshift -l 57:24 &

xautolock -time 10 -locker lock &

# Loads WM.
export PANEL_FIFO="/tmp/panel-fifo"
export PANEL_HEIGHT=18
export PANEL_FONT_FAMILY="Andale Mono-9"
sxhkd &
exec bspwm

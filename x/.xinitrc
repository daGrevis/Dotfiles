#! /bin/zsh

if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/*; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

PATH=$PATH:~/Utils

export PANEL_FIFO="/tmp/panel-fifo"
export PANEL_HEIGHT=18
export PANEL_FONT_FAMILY="Andale Mono"
export PANEL_FONT_SIZE="9"

if [[ "$(hostname)" == $WORK_HOSTNAME ]]; then
    # Sets 2nd monitor usable.
    xrandr --output HDMI3 --primary --output HDMI2 --right-of HDMI3
fi

./Utils/keyboard_settings.sh

# Sets brightness to something sane.
h=$(date "+%k")
if ((h < 9)); then
    xbacklight -set 20 -time 0
elif ((h < 18 )); then
    xbacklight -set 80 -time 0
else
    xbacklight -set 60 -time 0
fi

# Adjusts warmth based on current location and other factors.
redshift -l 57:24 &

if [[ "$(hostname)" == $WORK_HOSTNAME ]]; then
    xautolock -time 20 -locker lock &
fi

# Notification daemon.
dunst &

set_wallpaper.sh

xbanish &

# Loads WM.
sxhkd &
exec bspwm

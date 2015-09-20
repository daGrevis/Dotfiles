#! /bin/zsh

if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/*; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

PATH=$PATH:~/Utils

if [[ "$(hostname)" == $WORK_HOSTNAME ]]; then
    # Sets 2nd monitor usable.
    xrandr --output HDMI3 --primary --output HDMI2 --right-of HDMI3
fi

# Sets brightness to something sane.
h=$(date "+%k")
if ((h < 9)); then
    xbacklight -set 20 -time 0
elif ((h < 18 )); then
    xbacklight -set 80 -time 0
else
    xbacklight -set 60 -time 0
fi

exec bspwm

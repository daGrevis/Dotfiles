#! /bin/zsh

if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/*; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

PATH=$PATH:~/Utils

eval $(ssh-agent)

if [[ "$(hostname)" == $WORK_HOSTNAME ]]; then
    # Sets 2nd monitor usable.
    xrandr --output HDMI3 --primary --output HDMI2 --right-of HDMI3
fi

adjust_brightness.sh

DISPLAY=:0 dropbox &

wicd-client --tray &

exec bspwm

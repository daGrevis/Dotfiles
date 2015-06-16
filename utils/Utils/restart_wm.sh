#!/bin/bash

killall panel bar
~/Utils/panel &
~/Utils/bar2 &

killall sxhkd
sxhkd &

killall dunst
dunst &

# TODO: Make it actually work.
# aux dunst
# until $? != 0; do
#     notify-executing.sh "wm restarted" &
#     sleep 1
# done

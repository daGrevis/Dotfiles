#!/bin/bash

killall sxhkd
sxhkd &

keyboard_settings.sh

killall xbanish
xbanish &

set_wallpaper.sh &

killall redshift
redshift -l "$LOCATION_LAT:$LOCATION_LNG" &

killall compton
compton &

killall bar_top.sh
bar_top.sh &

killall bar_bottom.sh
bar_bottom.sh &

killall dunst
dunst &

killall stalonetray
(sleep 2 && stalonetray) &

kill -9 $(pgrep -f Utils/cron.py)
start_cron.sh

#!/bin/bash

killall sxhkd
sxhkd &

./Utils/keyboard_settings.sh

killall xbanish
xbanish &

set_wallpaper.sh &

killall redshift
redshift -l "$LOCATION_LAT:$LOCATION_LNG" &

killall compton
compton &

killall bar_top.sh
~/Utils/bar_top.sh &

killall bar_bottom.sh
~/Utils/bar_bottom.sh &

killall dunst
dunst &

killall stalonetray
(sleep 2 && stalonetray) &

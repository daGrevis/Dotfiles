#!/bin/bash

stop_wm.sh

sxhkd &

bar_top.sh &

bar_bottom.sh &

keyboard_settings.sh

set_wallpaper.sh &

redshift -l "$LOCATION_LAT:$LOCATION_LNG" &

compton &

dunst &

stalonetray &

start_cron.sh

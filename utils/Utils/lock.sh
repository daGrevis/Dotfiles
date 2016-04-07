#!/bin/bash

# I don't want notification in screensaver.
scrot /tmp/screenshot.jpg

notify-send -u low 'Locking Screen'

convert -colorspace gray /tmp/screenshot.jpg -scale 25% -scale 400% /tmp/screensaver.png

i3lock -n -e -u -i "/tmp/screensaver.png"; echo $(date +"%s") > ~/tmp/session_ts

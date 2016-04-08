#!/bin/bash

# I don't want notification in screensaver.
scrot tmp/screenshot.jpg

notify-send -u low 'Locking Screen'

convert "tmp/screenshot.jpg" -level "0%,100%,0.6" -filter "Gaussian" -resize "20%" -define "filter:sigma=1.5" -resize "500.5%" -fill "black" "tmp/screensaver.png"

i3lock -n -e -u -i "tmp/screensaver.png"; echo $(date +"%s") > ~/tmp/session_ts

#!/bin/bash

# I don't want notification in screensaver.
scrot /tmp/screenshot.jpg

notify-send 'Locking screen' 'Right now'

convert -colorspace gray /tmp/screenshot.jpg -scale 25% -scale 400% /tmp/screensaver.png

i3lock -u -i /tmp/screensaver.png

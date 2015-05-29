#!/bin/bash

notify-send 'Locking screen' 'Right now'

scrot -q 100 /tmp/screenshot.png
convert /tmp/screenshot.png -scale 25% -scale 400% /tmp/screenshot-pixelated.png

i3lock -u -i /tmp/screenshot-pixelated.png

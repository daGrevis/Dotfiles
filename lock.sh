#!/bin/bash

scrot -q 100 /tmp/screenshot.png
convert /tmp/screenshot.png -blur 0x07 /tmp/screenshotblur.png
i3lock -u -i /tmp/screenshotblur.png

#!/bin/bash

killall bar_top.sh
~/Utils/bar_top.sh &

killall bar_bottom.sh
~/Utils/bar_bottom.sh &

killall sxhkd
sxhkd &

killall dunst
dunst &

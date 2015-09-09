#!/bin/bash

killall panel bar
~/Utils/panel &
~/Utils/bar2 &

killall sxhkd
sxhkd &

killall dunst
dunst &

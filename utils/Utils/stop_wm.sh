#!/bin/bash

killall sxhkd

killall redshift

killall compton

killall bar_top.sh

killall bar_bottom.sh

pkill -f widget_worker.py

killall dunst

killall stalonetray

~/Utils/stop_cron.sh

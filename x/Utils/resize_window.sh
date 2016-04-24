#!/bin/bash

xdotool windowsize $(printf 0x%x $(bspc query -n focused -N)) $@

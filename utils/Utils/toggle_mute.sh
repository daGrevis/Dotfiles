#!/bin/bash

amixer get Master | grep "\[on\]" > /dev/null
IS_MUTED=$?

if [ "$IS_MUTED" -eq 1 ]; then
    amixer sset Master unmute
    amixer sset Headphone unmute
    amixer sset Speaker unmute
else
    amixer sset Master mute
fi

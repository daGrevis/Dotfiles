#!/bin/bash
# Argument wrapper around dmenu2.

source ~/Utils/colors.sh

echo "$@" | dmenu -h 24 -b -i \
    -fn "Fira Mono-9" \
    -nb $COLOR_01 -nf $COLOR_05 \
    -sb $COLOR_02 -sf $COLOR_06

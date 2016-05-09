#!/bin/bash

# https://www.reddit.com/r/bspwm/comments/4hbu8r/combine_all_resize_keybindings_into_one_including/
wid=$(xdotool getactivewindow)
wininfo=$(xwininfo -id "$wid")
width=$(echo "$wininfo" | awk '/Width/ {print $2}')
height=$(echo "$wininfo" | awk '/Height/ {print $2}')
offsetx=60
offsety=60
case $1 in
    left)
        bspc node @east -r -$offsetx || bspc node @west -r -$offsetx

        if [[ $width == "$(xwininfo -id "$wid" | \
                awk '/Width/ {print $2}')" ]]; then
            xdotool windowsize $(printf 0x%x $(bspc query -n focused -N)) $(($width + $offsetx)) 0
            xdo move -x -$offsetx
        fi
        ;;
    down)
        bspc node @south -r +$offsety || bspc node @north -r +$offsety

        if [[ $height == "$(xwininfo -id "$wid" | \
                awk '/Height/ {print $2}')" ]]; then
            xdotool windowsize $(printf 0x%x $(bspc query -n focused -N)) 0 $(($height + $offsety)) 0
        fi
        ;;
    up)
        bspc node @north -r -$offsety || bspc node @south -r -$offsety

        if [[ $height == "$(xwininfo -id "$wid" | \
                awk '/Height/ {print $2}')" ]]; then
            xdotool windowsize $(printf 0x%x $(bspc query -n focused -N)) 0 $(($height + $offsety)) 0
            xdo move -y -$offsetx
        fi
        ;;
    right)
        bspc node @west -r +$offsetx || bspc node @east -r +$offsetx

        if [[ $width == "$(xwininfo -id "$wid" | \
                awk '/Width/ {print $2}')" ]]; then
            xdotool windowsize $(printf 0x%x $(bspc query -n focused -N)) $(($width + $offsetx)) 0
        fi
        ;;
    *)
        xdotool windowsize $(printf 0x%x $(bspc query -n focused -N)) $@
        ;;
esac

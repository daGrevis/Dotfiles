#!/bin/sh

if [ "$(pgrep -cx 'bar_top.sh')" -gt 1 ] ; then
    printf "%s\n" "bar_top.sh is already running" >&2
    exit 1
fi

trap 'trap - TERM; kill 0' INT TERM QUIT EXIT

pipe=~/tmp/bar_top.fifo

[ -e "$pipe" ] && rm "$pipe"
mkfifo "$pipe"

bspc control --subscribe > "$pipe" &

. ~/Utils/bar_colors.sh

reader() {
    while read -r line ; do
        printf "%s\n" "%{l}hello, world"
    done
}


cat "$pipe" | reader | lemonbar -g "x24" -f "Fira Mono-9" -f "Fira Mono-9:style=Bold" -f "fontello-12" -F "$COLOR_FOREGROUND" -B "$COLOR_BACKGROUND" &

wait

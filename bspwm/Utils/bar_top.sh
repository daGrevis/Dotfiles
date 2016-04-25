#!/bin/sh

if [ "$(pgrep -cx "bar_top.sh")" -gt 1 ] ; then
    printf "%s\n" "bar_top.sh is already running" >&2
    exit 1
fi

logfile=~/tmp/bar_top.log
pipe=~/tmp/bar_top.fifo

rm -f $logfile
touch $logfile

rm -f $pipe
mkfifo $pipe

bspc subscribe report > "$pipe" &

. ~/Utils/bar_colors.sh

while true; do
    echo "" > "$pipe"
    sleep .5
done &

reader() {
    while read -r line ; do
        output="$(PYTHONPATH=~/Python/lemony:~/Python/sweetcache-redis:~/Python/sweetcache python ~/Utils/bar_top.py)"
        printf "%s\n" "$output"
    done
}

reader < $pipe | lemonbar -g "x24" -f "Fira Mono-9" -f "Fira Mono-9:style=Bold" -f "fontello-12" -u 3 -F "$COLOR_FOREGROUND" -B "$COLOR_BACKGROUND" &

wait

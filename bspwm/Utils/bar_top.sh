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

bspc control --subscribe > "$pipe" &

. ~/Utils/bar_colors.sh

while true; do
    echo "" > "$pipe"
    sleep 1
done &

reader() {
    while read -r line ; do
        (
        flock -n 9 || exit 1
            output="$(PYTHONPATH=~/Python/lemony:~/Python/sweetcache-redis:~/Python/sweetcache python ~/Utils/bar_top.py "$line")"
            printf "%s\n" "$output"
        ) 9> ~/tmp/bar_top.lock
    done
}

reader < $pipe | lemonbar -g "x24" -f "Fira Mono-9" -f "Fira Mono-9:style=Bold" -f "fontello-12" -u 2 -F "$COLOR_FOREGROUND" -B "$COLOR_BACKGROUND" &

wait

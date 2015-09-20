#!/bin/sh

if [ "$(pgrep -cx "bar_bottom.sh")" -gt 1 ] ; then
    printf "%s\n" "bar_bottom.sh is already running" >&2
    exit 1
fi

logfile=~/tmp/bar_bottom.log
pipe=~/tmp/bar_bottom.fifo

rm -f $logfile
touch $logfile

rm -f $pipe
mkfifo $pipe

bspc control --subscribe all > "$pipe" &

. ~/Utils/bar_colors.sh

reader() {
    while read -r line ; do
        (
        flock -n 9 || exit 1
            output="$(PYTHONPATH=~/Python/lemony:~/Python/sweetcache-redis:~/Python/sweetcache python ~/Utils/bar_bottom.py "$line")"
            printf "%s\n" "$output"
        ) 9> ~/tmp/bar_bottom.lock
    done
}

reader < $pipe | lemonbar -b -g "x24" -f "Fira Mono-9" -f "Fira Mono-9:style=Bold" -f "fontello-12" -u 2 -F "$COLOR_FOREGROUND" -B "$COLOR_BACKGROUND" &

wait

#!/bin/sh

# Puts 1 into the @ports tmux option of each window that has a pane with a
# process that listens on a TCP port, the same ports that mux shows for a
# session, and unsets it for every other window. .tmux.conf draws a yellow
# circle on the tab of a window that has it.
#
# A pane runs a shell, and the process that listens is the shell's child or
# grandchild, so each listening process goes up its ancestors until one of them
# is the process of a pane.
#
# Meant for a #() in .tmux.conf, which tmux runs every status-interval while a
# client shows the status bar. Takes that client, to redraw its status bar when
# a window changed.
#
# Prints nothing, because .tmux.conf draws the option and not the output. See
# @job_ports there.

client=$1

windows=$(
    {
        lsof -iTCP -sTCP:LISTEN -P -n -t 2> /dev/null | sed 's/^/listen /'
        ps -eo pid=,ppid= | sed 's/^/process /'
        tmux list-panes -a -F 'pane #{pane_pid} #{window_id}' 2> /dev/null
    } | awk '
        $1 == "listen" { listening[$2] = 1 }
        $1 == "process" { parent[$2] = $3 }
        $1 == "pane" { window[$2] = $3 }
        END {
            for (pid in listening) {
                for (p = pid; p > 1; p = parent[p]) {
                    if (p in window) {
                        print window[p]
                        break
                    }
                }
            }
        }
    '
)

# tmux runs this every few seconds, and the ports rarely change, so tmux only
# hears about a window that changed.
changed=""
# A window in more than one session shows up once for each.
for line in $(tmux list-windows -a -F '#{window_id}:#{@ports}' 2> /dev/null | sort -u); do
    id=${line%%:*}
    ports=${line#*:}
    if printf '%s\n' "$windows" | grep -qxF "$id"; then
        [ -n "$ports" ] && continue
        tmux set-option -w -t "$id" @ports 1 2> /dev/null
    else
        [ -z "$ports" ] && continue
        tmux set-option -wu -t "$id" @ports 2> /dev/null
    fi
    changed=1
done
[ -n "$changed" ] && tmux refresh-client -S -t "$client" 2> /dev/null

exit 0

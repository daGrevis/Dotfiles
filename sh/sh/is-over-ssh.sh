#!/bin/sh

# Prints "1" when the process with the pid in the first argument runs in an
# SSH login, that is, when an sshd is one of its ancestors, and "0" when it
# does not, which tmux reads as false. .tmux.conf gives it the pid of a tmux
# client, to show "[ssh]" in the status bar of that client.
#
# Without a pid, it checks the tmux client of this terminal, because the
# ancestors of a shell in tmux are the ones of the tmux server. When more than
# one client shows the pane, tmux picks the one that was used last, which is
# the one that typed the command. Outside tmux, it checks itself, because its
# ancestors are the ones of the shell that runs it.
#
# It looks at the ancestors and not at the SSH_* variables, because macOS has
# no /proc to read them from, and ps shows them with other flags on Linux than
# on macOS. ps -o ppid= -o comm= is the same on both. The name of sshd is
# "sshd-session" on Linux and a path such as "/usr/sbin/sshd" on macOS, so the
# match is loose.

pid=$1
if [ -z "$pid" ]; then
    if [ -n "$TMUX" ]; then
        pid=$(tmux display-message -p '#{client_pid}')
    else
        pid=$$
    fi
fi
while [ "$pid" -gt 1 ] 2> /dev/null; do
    # shellcheck disable=SC2046
    set -- $(ps -o ppid= -o comm= -p "$pid")
    case "$2" in
        *sshd*)
            echo 1
            exit
            ;;
    esac
    pid=$1
done
echo 0

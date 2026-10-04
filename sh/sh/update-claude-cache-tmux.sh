#!/bin/sh

# Puts how stale the prompt cache of a claude is into the @claude_cache tmux
# option of its pane, as a bar, which .tmux.conf renders in the status bar, and
# redraws it. 0 means that a request just wrote or read the cache, 100 that its
# TTL ran out and the next prompt pays the full price for the whole
# conversation again. A read starts the TTL over, so the bar drops back to 0
# with every request, the ones between tool calls too.
#
# The bar is a share of the TTL and not a time, because the TTL is 1h, or 5m
# once the account is in overage, and the colours of bar.sh then mean the same
# for both.
#
# Meant for a #() in .tmux.conf, which tmux runs only while a client shows the
# pane: every status-interval, and at once when somebody comes back to it or
# claude reports a new expiry. So the bar moves while somebody looks at it and
# costs nothing while nobody does. A pane that nobody looks at keeps an old
# bar, which nobody sees either.
#
# Claude's statusLine cannot do this. Claude runs it when it has news, and only
# a timer of its own would move the bar while claude waits for a prompt, which
# runs whether anybody looks or not. Claude's hooks do not know what is on the
# screen.
#
# Takes the client that shows the pane, the pane, and what
# update-claude-status-tmux.sh put into @claude_cache_expiry: when the cache
# runs out, as epoch seconds, and its TTL in seconds. Without those two, unsets
# @claude_cache, so that the status bar leaves the part out.
#
# Prints nothing, because .tmux.conf draws the option and not the output. See
# @job_claude_cache there.

client=$1
pane=$2
expires_at=$3
ttl=$4

# Rounded down, so that 100 only shows once the cache is gone.
cache=""
if [ -n "$ttl" ]; then
    percentage=$((($(date +%s) - expires_at + ttl) * 100 / ttl))
    [ "$percentage" -lt 0 ] && percentage=0
    [ "$percentage" -gt 100 ] && percentage=100
    cache=$("$HOME/sh/bar.sh" --tmux "$percentage")
fi

# tmux runs this every few seconds, and the bar moves by one only every 36
# seconds of a 1h TTL, so tmux only hears about a bar that changed.
[ "$cache" = "$(tmux show-options -pqv -t "$pane" @claude_cache 2> /dev/null)" ] && exit 0
if [ -n "$cache" ]; then
    tmux set-option -p -t "$pane" @claude_cache "$cache" 2> /dev/null
else
    tmux set-option -pu -t "$pane" @claude_cache 2> /dev/null
fi
tmux refresh-client -S -t "$client" 2> /dev/null

exit 0

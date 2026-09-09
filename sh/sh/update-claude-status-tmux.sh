#!/bin/sh

# Puts which model Claude runs, how much it reasons and how full its context
# window is into the @claude_model, @claude_effort and @claude_context tmux
# options, which .tmux.conf renders in the status bar, and redraws them. Meant
# for Claude's statusLine: Claude sends all of them on every redraw, so they
# follow the conversation.
#
# Model, effort and context belong to one conversation, so the options are set
# on the pane claude runs in and several claudes each report their own.
#
# Claude's hooks cannot do this. They get no token counts, and the transcript
# does not say how large the window is, which is 200k for one model and 1M for
# another.
#
# Unsets an option when there is nothing to report, so that the status bar
# leaves that part out instead of drawing an empty one.
#
# The values are bare ("opus-5", not "(model opus-5)"), because .tmux.conf says
# which one is which by layout and by label.

status=$(cat)

# The id, not the display name, because it says which exact model answers, e.g.
# "opus-5[1m]" over "Opus 5 (1M context)". Every id starts with "claude-", which
# says nothing here and is dropped.
model=$(printf '%s' "$status" | jq -r '.model.id // empty | sub("^claude-";"")' 2> /dev/null)

# Only models that take an effort setting report one, so this is often absent.
effort=$(printf '%s' "$status" | jq -r '.effort.level // empty' 2> /dev/null)

# A bar, like the limit usage has, so that how full the window is reads at a
# glance. The bar carries the "%" of the value, because .tmux.conf cannot write
# one itself. See the comment on status-right.
#
# A conversation that has no answer yet reports no count, and that one reads as
# 0, so that the bar is there from the moment claude starts instead of turning
# up with the first answer.
percentage=$(printf '%s' "$status" | jq -r '.context_window.used_percentage // 0 | round' 2> /dev/null)
[ -n "$percentage" ] || percentage=0
context=$("$HOME/sh/bar.sh" --tmux "$percentage")

# The status line redraws many times per answer, so tmux only hears about a
# value that changed. Returns 0 when it did.
update() {
    [ "$2" = "$(tmux show-options -pqv "$1" 2> /dev/null)" ] && return 1
    if [ -n "$2" ]; then
        tmux set-option -p "$1" "$2" 2> /dev/null
    else
        tmux set-option -pu "$1" 2> /dev/null
    fi
}

changed=""
update @claude_model "$model" && changed=1
update @claude_effort "$effort" && changed=1
update @claude_context "$context" && changed=1
[ -n "$changed" ] && tmux refresh-client -S 2> /dev/null

# Claude draws its own status line from what a statusLine command prints, so
# this one prints nothing and never fails.
exit 0

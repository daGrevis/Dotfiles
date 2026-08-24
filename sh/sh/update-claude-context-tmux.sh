#!/bin/sh

# Puts how full Claude's context window is into the @claude_context tmux
# option, which .tmux.conf renders in the status bar, and redraws it. Meant for
# Claude's statusLine: Claude sends the numbers on every redraw, so the
# percentage follows the conversation.
#
# The context belongs to one conversation, so the option is set on the pane
# claude runs in and several claudes each report their own.
#
# Claude's hooks cannot do this. They get no token counts, and the transcript
# does not say how large the window is, which is 200k for one model and 1M for
# another.
#
# Unsets the option when there is nothing to report, so that the status bar
# leaves that part out instead of drawing an empty one.

status=$(cat)

context=""
percentage=$(printf '%s' "$status" | jq -r '.context_window.used_percentage // empty' 2> /dev/null)
[ -n "$percentage" ] && context="(context $percentage%)"

# The status line redraws many times per answer, so tmux only hears about a
# value that changed.
if [ "$context" != "$(tmux show-options -pqv @claude_context 2> /dev/null)" ]; then
    if [ -n "$context" ]; then
        tmux set-option -p @claude_context "$context" 2> /dev/null
    else
        tmux set-option -pu @claude_context 2> /dev/null
    fi
    tmux refresh-client -S 2> /dev/null
fi

# Claude draws its own status line from what a statusLine command prints, so
# this one prints nothing and never fails.
exit 0

#!/bin/sh

# Puts claude-usage output into the @claude_usage tmux option, which .tmux.conf
# renders in the status bar, and redraws it. Meant for Claude's SessionStart and
# Stop hooks: the numbers are stale until claude opens and only change when
# Claude answers.
#
# The limits belong to the account, so the option is global. The model, effort
# and context window belong to one conversation and are reported per pane by
# update-claude-status-tmux.sh.
#
# Unsets the option when the account has no such limits, so that the status bar
# leaves out that part instead of drawing an empty one. A failed request (exit
# 2, usually a rate limited endpoint) leaves the last numbers up, because they
# are still roughly right and blinking out on every 429 is worse.

usage=$("$HOME/sh/claude-usage.sh" --tmux)
case $? in
    0) tmux set-option -g @claude_usage "$usage" 2> /dev/null ;;
    1) tmux set-option -gu @claude_usage 2> /dev/null ;;
esac

tmux refresh-client -S 2> /dev/null

# Never fail the hook itself.
exit 0

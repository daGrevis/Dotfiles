#!/bin/sh

# Puts claude-usage output into the @claude_usage tmux option, which .tmux.conf
# renders in the status bar, and redraws it. Meant for Claude's SessionStart and
# Stop hooks: the numbers are stale until claude opens and only change when
# Claude answers.
#
# Unsets the option when there is no usage to report, so that the status bar
# leaves out the whole widget instead of drawing an empty one.

if usage=$("$HOME/sh/claude-usage.sh"); then
    tmux set-option -g @claude_usage "$usage" 2> /dev/null
else
    tmux set-option -gu @claude_usage 2> /dev/null
fi

tmux refresh-client -S 2> /dev/null

# Never fail the hook itself.
exit 0

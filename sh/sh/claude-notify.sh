#!/usr/bin/env bash
# Claude Code Stop/Notification hook — notifies when Claude needs attention.
# Shows response duration when Claude finishes.
# Shows "Waiting for input..." only for permission prompts.
# Paired with a UserPromptSubmit hook that writes a timestamp to /tmp/.claude-prompt-start.
# Receives JSON on stdin with hook_event_name and transcript_path.

input=$(cat)
event=$(echo "$input" | jq -r '.hook_event_name // empty')
sid=$(echo "$input" | jq -r '.session_id // empty')

session=""
if [ -n "$TMUX" ]; then
  session=$(tmux display-message -p '#{session_name}')
fi

title="Claude Code"
if [ -n "$session" ]; then
  title="Claude Code ($session)"
fi

notification_type=$(echo "$input" | jq -r '.notification_type // empty')

# For permission prompts, show "Waiting for input..." and exit early.
if [ "$event" = "Notification" ] && [ "$notification_type" = "permission_prompt" ]; then
  nohup ~/sh/notify.sh "$title" "Waiting for input..." > /dev/null 2>&1 &
  exit 0
fi

# Ignore all other Notification events — Stop hook already handles completion.
if [ "$event" = "Notification" ]; then
  exit 0
fi

# For Stop events, show duration.
message="Done"

start_file="/tmp/.claude-prompt-start-${sid:-default}"
if [ -f "$start_file" ]; then
  start=$(cat "$start_file")
  now=$(date +%s)
  elapsed=$((now - start))
  mins=$((elapsed / 60))
  secs=$((elapsed % 60))
  if [ "$mins" -gt 0 ]; then
    message="${mins}m ${secs}s"
  else
    message="${secs}s"
  fi
fi

nohup ~/sh/notify.sh "$title" "$message" > /dev/null 2>&1 &

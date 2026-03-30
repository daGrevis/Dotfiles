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

# Ignore non-permission Notification events — Stop hook handles completion.
if [ "$event" = "Notification" ] && [ "$notification_type" != "permission_prompt" ]; then
  exit 0
fi

# Compute elapsed time from the last prompt/permission event.
start_file="/tmp/.claude-prompt-start-${sid:-default}"
now=$(date +%s)
message="Done"
if [ -f "$start_file" ]; then
  start=$(cat "$start_file")
  elapsed=$((now - start))
  mins=$((elapsed / 60))
  secs=$((elapsed % 60))
  if [ "$mins" -gt 0 ]; then
    message="${mins}m ${secs}s"
  else
    message="${secs}s"
  fi
fi

if [ "$notification_type" = "permission_prompt" ]; then
  # Reset start time so the next segment measures from now (after user approves).
  echo "$now" > "$start_file"
  nohup ~/sh/notify.sh "$title" "Waiting for input... ($message)" > /dev/null 2>&1 &
else
  # Stop event — clean up the start file.
  rm -f "$start_file"
  nohup ~/sh/notify.sh "$title" "$message" > /dev/null 2>&1 &
fi

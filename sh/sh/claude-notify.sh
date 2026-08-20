#!/usr/bin/env bash
# Claude Code Stop/Notification hook — notifies when Claude needs attention.
# Shows response duration when Claude finishes.
# Shows "Waiting for input..." only for permission prompts.
# Paired with a UserPromptSubmit hook that writes a timestamp to /tmp/.claude-prompt-start.
# Receives JSON on stdin with hook_event_name and transcript_path.
#
# User-input pauses must not count toward the reported duration (the CLI's
# "Cooked for" resets when the user responds, not when Claude asks). Two cases:
#  - Permission prompts: no hook fires on approval, so a permission_prompt drops
#    a pause marker and the first PostToolUse afterwards (the approved tool ran
#    => user is back) restamps the start.
#  - Input tools (AskUserQuestion, ExitPlanMode): these block on the user and
#    don't emit a permission_prompt; their PostToolUse fires on answer, so we
#    restamp the start by tool name.

input=$(cat)
event=$(echo "$input" | jq -r '.hook_event_name // empty')
sid=$(echo "$input" | jq -r '.session_id // empty')

start_file="/tmp/.claude-prompt-start-${sid:-default}"
pause_file="/tmp/.claude-prompt-pause-${sid:-default}"

# Subagent/Task completions fire the same Stop hook, just with
# hook_event_name rewritten to SubagentStop — skip so only the top-level
# agent's finish beeps, not every subagent.
if [ "$event" = "SubagentStop" ]; then
  exit 0
fi

# Claude resumed after waiting on the user: restamp the start so the away time
# isn't counted. Triggers on a pending permission pause, or on an input tool
# (AskUserQuestion/ExitPlanMode) completing. Mid-turn tools with no pause pending
# don't match, so they don't reset the clock.
if [ "$event" = "PostToolUse" ]; then
  tool=$(echo "$input" | jq -r '.tool_name // empty')
  if [ -f "$pause_file" ] || [ "$tool" = "AskUserQuestion" ] || [ "$tool" = "ExitPlanMode" ]; then
    date +%s > "$start_file"
    rm -f "$pause_file"
  fi
  exit 0
fi

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

# Compute elapsed time from the last prompt/approval event.
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
  # Drop a pause marker; the next PostToolUse (after the user approves) restamps
  # the start. Restamping here would wrongly count the user's away time.
  echo "$now" > "$pause_file"
  nohup ~/sh/notify.sh "$title" "Waiting for input... ($message)" > /dev/null 2>&1 &
else
  # Stop event — clean up the start and pause files.
  rm -f "$start_file" "$pause_file"
  nohup ~/sh/notify.sh "$title" "$message" > /dev/null 2>&1 &
fi

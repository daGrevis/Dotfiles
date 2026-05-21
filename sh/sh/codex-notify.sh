#!/usr/bin/env bash

set -euo pipefail

title() {
  local session=""
  if [ -n "${TMUX:-}" ]; then
    session=$(tmux display-message -p '#{session_name}' 2>/dev/null || true)
  fi

  if [ -n "$session" ]; then
    printf 'Codex (%s)\n' "$session"
  else
    printf 'Codex\n'
  fi
}

notify_async() {
  nohup "$HOME/sh/notify.sh" "$(title)" "$1" >/dev/null 2>&1 &
}

format_elapsed() {
  local start_ts="$1"
  local now
  local elapsed
  local mins
  local secs

  now=$(date +%s)
  elapsed=$((now - start_ts))
  mins=$((elapsed / 60))
  secs=$((elapsed % 60))

  if [ "$mins" -gt 0 ]; then
    printf '%sm %ss' "$mins" "$secs"
  else
    printf '%ss' "$secs"
  fi
}

find_session_file() {
  local stamp_file="$1"
  local expected_cwd="$2"
  local candidate=""

  while [ -z "$candidate" ]; do
    while IFS= read -r file; do
      if sed -n '1p' "$file" | jq -e --arg cwd "$expected_cwd" '
        .type == "session_meta" and (.payload.cwd // "") == $cwd
      ' >/dev/null 2>&1; then
        candidate="$file"
        break
      fi
    done < <(find "$HOME/.codex/sessions" -type f -name 'rollout-*.jsonl' -newer "$stamp_file" 2>/dev/null | sort)

    [ -n "$candidate" ] && break
    sleep 1
  done

  printf '%s\n' "$candidate"
}

process_lines() {
  local session_file="$1"
  local state_dir="$2"
  local line type payload_type call_id args_json justification elapsed
  local task_started_file="${state_dir}/task-started"
  local seen_calls_file="${state_dir}/seen-calls"

  touch "$seen_calls_file"

  while IFS= read -r line; do
    [ -z "$line" ] && continue

    type=$(printf '%s\n' "$line" | jq -r '.type // empty' 2>/dev/null || true)
    [ -z "$type" ] && continue

    payload_type=$(printf '%s\n' "$line" | jq -r '.payload.type // empty' 2>/dev/null || true)

    if [ "$type" = "event_msg" ] && [ "$payload_type" = "task_started" ]; then
      date +%s >"$task_started_file"
      continue
    fi

    if [ "$type" = "response_item" ] && [ "$payload_type" = "function_call" ]; then
      args_json=$(printf '%s\n' "$line" | jq -r '.payload.arguments // empty' 2>/dev/null || true)
      if [ -n "$args_json" ] && printf '%s' "$args_json" | jq -e 'fromjson | .sandbox_permissions == "require_escalated"' >/dev/null 2>&1; then
        call_id=$(printf '%s\n' "$line" | jq -r '.payload.call_id // empty' 2>/dev/null || true)
        if [ -n "$call_id" ] && ! grep -qxF "$call_id" "$seen_calls_file" 2>/dev/null; then
          printf '%s\n' "$call_id" >>"$seen_calls_file"
          justification=$(printf '%s' "$args_json" | jq -r 'fromjson | .justification // empty' 2>/dev/null || true)
          if [ -n "$justification" ]; then
            notify_async "Waiting for input... ${justification}"
          else
            notify_async "Waiting for input..."
          fi
        fi
      fi
      continue
    fi

    if [ "$type" = "event_msg" ] && [ "$payload_type" = "task_complete" ]; then
      if [ -f "$task_started_file" ]; then
        elapsed=$(format_elapsed "$(cat "$task_started_file")")
        notify_async "Waiting for next prompt... (${elapsed})"
      else
        notify_async "Waiting for next prompt..."
      fi
    fi
  done < <(
    local last_line=0
    local total_lines new_lines

    while true; do
      total_lines=$(wc -l <"$session_file")
      if [ "$total_lines" -gt "$last_line" ]; then
        new_lines=$((last_line + 1))
        sed -n "${new_lines},${total_lines}p" "$session_file"
        last_line="$total_lines"
      fi
      sleep 1
    done
  )
}

run_wrapper() {
  local stamp_file
  local state_dir
  local watcher_pid
  local exit_code

  stamp_file=$(mktemp /tmp/.codex-notify-start.XXXXXX)
  state_dir=$(mktemp -d /tmp/.codex-notify-state.XXXXXX)

  touch "$stamp_file"
  "$0" watch "$stamp_file" "$PWD" "$state_dir" >/dev/null 2>&1 &
  watcher_pid=$!

  set +e
  command codex "$@"
  exit_code=$?
  set -e

  kill "$watcher_pid" >/dev/null 2>&1 || true
  wait "$watcher_pid" 2>/dev/null || true
  rm -f "$stamp_file"
  rm -rf "$state_dir"

  return "$exit_code"
}

watch_session() {
  local stamp_file="$1"
  local expected_cwd="$2"
  local state_dir="$3"
  local session_file

  session_file=$(find_session_file "$stamp_file" "$expected_cwd")
  process_lines "$session_file" "$state_dir"
}

case "${1:-run}" in
  run)
    shift
    run_wrapper "$@"
    ;;
  watch)
    shift
    watch_session "$@"
    ;;
  *)
    printf 'Usage: %s [run [codex-args...]] | watch <stamp-file> <cwd> <state-dir>\n' "$0" >&2
    exit 1
    ;;
esac

#!/usr/bin/env bash
# Send a desktop notification. Clicking it focuses Alacritty and switches to the
# tmux session/window/pane where notify was called.
#
# On macOS, uses alerter which prints the user's action to stdout. On click
# (@CONTENTCLICKED), we focus Alacritty and switch tmux to the captured target.
# If Alacritty is closed, it opens via the .app bundle (correct dock icon) with
# -e to attach directly to the right tmux session. Auto-dismiss kills the alerter
# process by PID (alerter --remove hangs indefinitely, so we avoid it).
#
# Skips the notification if the user is already looking at the target pane,
# but always plays the bell and sound.
#
# Full paths to tmux/alacritty are baked into the click handler because it runs
# in a background subshell without the nix PATH. The .app symlink is resolved
# via readlink because macOS picks the wrong nix store copy otherwise.
# $TMUX_PANE is used instead of display-message -p to get the stable pane
# identity, since the latter follows the user's current view.
#
# On Linux, uses notify-send with --action/--wait for click-to-focus (same
# pattern as alerter on macOS). xdotool replaces osascript for detecting the
# focused window and activating Alacritty. Falls back to plain notify-send
# when not in tmux.
# The bell (\a) triggers the dock icon bounce on macOS (Alacritty doesn't support
# the red dot badge — see https://github.com/alacritty/alacritty/issues/4472).
# The bounce only works if you've switched away from Alacritty to another app.
# On Linux, the bell triggers the urgency hint.
#
# Called from utils.sh as a thin wrapper and from Claude Code Stop hook.

title="${1:-Notification}"
message="${2:-Done}"

# Shared tmux variables (used by both macOS and Linux paths).
if [ -n "$TMUX" ]; then
  target=$(tmux display-message -t "$TMUX_PANE" -p '#{session_name}:#{window_index}.#{pane_index}')
  current_target=$(tmux display-message -p '#{session_name}:#{window_index}.#{pane_index}')
  socket=$(echo "$TMUX" | cut -d, -f1)
  client=$(tmux display-message -p '#{client_tty}')
  tmux_bin=$(which tmux)
fi

if [ "$(uname)" = "Darwin" ]; then
  alacritty_app=$(readlink -f ~/.nix-profile/Applications/Alacritty.app)
  alerter_bin=$(which alerter)
  if [ -n "$TMUX" ]; then
    frontmost=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true')
    if [ "$target" != "$current_target" ] || [ "$frontmost" != "alacritty" ]; then
      alerter_pid_file="/tmp/.notify-alerter-pid-${TMUX_PANE#%}"
      (
        alerter --title "$title" --message "$message" \
          --sender "org.alacritty" \
          --group "notify" \
          > "$alerter_pid_file.result" &
        echo $! > "$alerter_pid_file"
        wait $!
        result=$(cat "$alerter_pid_file.result" 2>/dev/null)
        rm -f "$alerter_pid_file" "$alerter_pid_file.result"
        "$tmux_bin" -S "$socket" set-hook -p -t "$TMUX_PANE" -u pane-focus-in 2>/dev/null
        if [ "$result" = "@CONTENTCLICKED" ] || [ "$result" = "@ACTIONCLICKED" ]; then
          if pgrep -x alacritty > /dev/null; then
            open -a "$alacritty_app"
            "$tmux_bin" -S "$socket" switch-client -c "$client" -t "$target" 2>/dev/null
          else
            open -a "$alacritty_app" --args -e "$tmux_bin" -S "$socket" attach-session -t "$target"
          fi
        fi
      ) </dev/null >/dev/null 2>&1 &
      "$tmux_bin" -S "$socket" set-hook -p -t "$TMUX_PANE" pane-focus-in \
        "run-shell -b '{ pid=\$(cat ${alerter_pid_file} 2>/dev/null) && kill \$pid 2>/dev/null; rm -f ${alerter_pid_file} ${alerter_pid_file}.result; ${tmux_bin} -S ${socket} set-hook -p -t ${TMUX_PANE} -u pane-focus-in; } >/dev/null 2>&1'"
    fi
  else
    (alerter --title "$title" --message "$message" \
      --sender "org.alacritty" \
        --group "notify" \
      > /dev/null &
    )
  fi
else
  if [ -n "$TMUX" ]; then
    focused=$(xdotool getactivewindow getwindowclassname 2>/dev/null)
    if [ "$target" != "$current_target" ] || [[ "${focused,,}" != "alacritty" ]]; then
      notify_id_file="/tmp/.notify-id-${TMUX_PANE#%}"
      gdbus_bin=$(which gdbus 2>/dev/null)
      (
        {
          read -r first_line
          if [[ "$first_line" =~ ^[0-9]+$ ]]; then
            echo "$first_line" > "$notify_id_file"
            read -r result
          else
            result="$first_line"
          fi
        } < <(notify-send "$title" "$message" --action=click=Open --wait --print-id 2>/dev/null)
        rm -f "$notify_id_file"
        "$tmux_bin" -S "$socket" set-hook -p -t "$TMUX_PANE" -u pane-focus-in 2>/dev/null
        if [ "$result" = "click" ]; then
          xdotool search --class Alacritty windowactivate 2>/dev/null
          "$tmux_bin" -S "$socket" switch-client -c "$client" -t "$target" 2>/dev/null
        fi
      ) &
      if [ -n "$gdbus_bin" ]; then
        "$tmux_bin" -S "$socket" set-hook -p -t "$TMUX_PANE" pane-focus-in \
          "run-shell '{ nid=\$(cat ${notify_id_file} 2>/dev/null) && ${gdbus_bin} call --session --dest org.freedesktop.Notifications --object-path /org/freedesktop/Notifications --method org.freedesktop.Notifications.CloseNotification \$nid; rm -f ${notify_id_file}; ${tmux_bin} -S ${socket} set-hook -p -t ${TMUX_PANE} -u pane-focus-in; } >/dev/null 2>&1'"
      fi
    fi
  else
    notify-send "$title" "$message" 2>/dev/null
  fi
fi

printf '\a'

# Play a random sound from $NOTIFY_SOUNDS directory (if set and non-empty).
if [ -n "$NOTIFY_SOUNDS" ] && [ -d "$NOTIFY_SOUNDS" ]; then
  sound=$(find "$NOTIFY_SOUNDS" -maxdepth 1 -name '*.mp3' 2>/dev/null | awk 'BEGIN{srand()}{a[NR]=$0}END{print a[int(rand()*NR)+1]}')
  if [ -n "$sound" ]; then
    nohup ffplay -nodisp -autoexit -loglevel quiet "$sound" </dev/null >/dev/null 2>&1 &
  fi
fi

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
# The notification is for a user at this machine, so it is also skipped when no
# attached tmux client runs here: every client came in over SSH, or there is no
# client at all. The sound is then skipped too, because nobody is at the desk
# to hear it. The notification, but not the sound, is also skipped when the
# user looks at the target pane from a client over SSH. is-over-ssh.sh checks
# each tmux client, because the pane has the SSH_* variables of the client that
# created it, and not of the one that the user types in.
#
# Full paths to tmux/alacritty are baked into the click handler because it runs
# in a background subshell without the nix PATH. The .app symlink is resolved
# via readlink because macOS picks the wrong nix store copy otherwise.
# $TMUX_PANE is used instead of display-message -p to get the stable pane
# identity, since the latter follows the user's current view.
#
# On Linux, uses notify-send with --action/--wait for click-to-focus (same
# pattern as alerter on macOS). Two actions are registered: "default" is the
# spec's body-click action (invisible, fires when clicking anywhere on the
# notification) and "click" renders the visible Open entry. xdotool replaces
# osascript for detecting the focused window and activating Alacritty. Falls
# back to plain notify-send when not in tmux.
#
# On both systems, each notification keeps its id (the pid of alerter on macOS)
# in a file of its own, and the pane-focus-in hook closes all of them. A
# notification that closes by itself removes only its file and not the hook,
# because the pane can have a newer one. The hook removes itself. .tmux.conf
# also runs the hook when a client comes to the pane that another client
# already shows, see the set-hook lines there.
#
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
  # The user's actual current view, taken from the most-recently-active attached
  # client server-wide. Must NOT use `display-message -p` here: this script runs
  # as a background process that inherited $TMUX from Claude's pane, so a bare
  # display-message resolves to that session's active window/pane regardless of
  # where the user really is. If they switched to another tmux session while
  # Claude's tab is still active, current_target would wrongly equal target and
  # the notification would be suppressed. Empty when no client is attached.
  read -r current_pid current_target < <(tmux list-clients -F '#{client_activity} #{client_pid} #{session_name}:#{window_index}.#{pane_index}' | sort -rn | head -n1 | cut -d' ' -f2-)
  # A client at this machine that has the focus and shows the target pane is
  # the view of the user, also when a client over SSH has newer activity. That
  # client is often a phone that the user put down: a key or a focus report
  # from it after the prompt makes it the newest client.
  away=1
  while read -r pid flags pane; do
    if [ "$(~/sh/is-over-ssh.sh "$pid")" = 0 ]; then
      away=
      if [[ "$flags" == *focused* ]] && [ "$pane" = "$target" ]; then
        current_pid=$pid
        current_target=$pane
      fi
    fi
  done < <(tmux list-clients -F '#{client_pid} #{client_flags} #{session_name}:#{window_index}.#{pane_index}')
  skip_gui=$away
  if [ "$target" = "$current_target" ] && [ "$(~/sh/is-over-ssh.sh "$current_pid")" = 1 ]; then
    skip_gui=1
  fi
  socket=$(echo "$TMUX" | cut -d, -f1)
  client=$(tmux display-message -p '#{client_tty}')
  tmux_bin=$(which tmux)
elif [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
  # Outside tmux, the SSH_* variables are the ones of this login, as in
  # prompt.sh.
  away=1
  skip_gui=1
fi

if [ "$(uname)" = "Darwin" ]; then
  alacritty_app=$(readlink -f ~/.nix-profile/Applications/Alacritty.app)
  alerter_bin=$(which alerter)
  if [ -n "$TMUX" ]; then
    frontmost=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true')
    if [ -z "$skip_gui" ] && { [ "$target" != "$current_target" ] || [ "$frontmost" != "alacritty" ]; }; then
      alerter_pid_file="/tmp/.notify-alerter-pid-${TMUX_PANE#%}"
      (
        pid_file=$(mktemp "$alerter_pid_file.XXXXXX")
        result_file=$(mktemp /tmp/.notify-alerter-result.XXXXXX)
        alerter --title "$title" --message "$message" \
          --sender "org.alacritty" \
          --group "notify" \
          > "$result_file" &
        echo $! > "$pid_file"
        wait $!
        result=$(cat "$result_file" 2>/dev/null)
        rm -f "$pid_file" "$result_file"
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
        "run-shell -b '{ for f in ${alerter_pid_file}.*; do pid=\$(cat \$f 2>/dev/null) && kill \$pid 2>/dev/null; rm -f \$f; done; ${tmux_bin} -S ${socket} set-hook -p -t ${TMUX_PANE} -u pane-focus-in; } >/dev/null 2>&1'"
    fi
  elif [ -z "$skip_gui" ]; then
    (alerter --title "$title" --message "$message" \
      --sender "org.alacritty" \
        --group "notify" \
      > /dev/null &
    )
  fi
else
  if [ -n "$TMUX" ]; then
    focused=$(xdotool getactivewindow getwindowclassname 2>/dev/null)
    if [ -z "$skip_gui" ] && { [ "$target" != "$current_target" ] || [[ "${focused,,}" != "alacritty" ]]; }; then
      notify_id_file="/tmp/.notify-id-${TMUX_PANE#%}"
      dbus_bin=$(which dbus-send 2>/dev/null)
      (
        {
          read -r first_line
          if [[ "$first_line" =~ ^[0-9]+$ ]]; then
            echo "$first_line" > "$notify_id_file.$first_line"
            read -r result
          else
            result="$first_line"
          fi
        } < <(notify-send "$title" "$message" -t 0 --action=default=Open --action=click=Open --wait --print-id 2>/dev/null)
        rm -f "$notify_id_file.$first_line"
        if [ "$result" = "default" ] || [ "$result" = "click" ]; then
          xdotool search --class Alacritty windowactivate 2>/dev/null
          "$tmux_bin" -S "$socket" switch-client -c "$client" -t "$target" 2>/dev/null
        fi
      ) &
      if [ -n "$dbus_bin" ]; then
        "$tmux_bin" -S "$socket" set-hook -p -t "$TMUX_PANE" pane-focus-in \
          "run-shell '{ for f in ${notify_id_file}.*; do nid=\$(cat \$f 2>/dev/null) && ${dbus_bin} --session --dest=org.freedesktop.Notifications --type=method_call /org/freedesktop/Notifications org.freedesktop.Notifications.CloseNotification uint32:\$nid; rm -f \$f; done; ${tmux_bin} -S ${socket} set-hook -p -t ${TMUX_PANE} -u pane-focus-in; } >/dev/null 2>&1'"
      fi
    fi
  elif [ -z "$skip_gui" ]; then
    notify-send "$title" "$message" -t 0 2>/dev/null
  fi
fi

printf '\a'

# Play a random sound from $NOTIFY_SOUNDS directory (if set and non-empty).
if [ -z "$away" ] && [ -n "$NOTIFY_SOUNDS" ] && [ -d "$NOTIFY_SOUNDS" ]; then
  sound=$(find "$NOTIFY_SOUNDS" -maxdepth 1 -name '*.mp3' 2>/dev/null | awk 'BEGIN{srand()}{a[NR]=$0}END{print a[int(rand()*NR)+1]}')
  if [ -n "$sound" ]; then
    nohup ffplay -nodisp -autoexit -loglevel quiet "$sound" </dev/null >/dev/null 2>&1 &
  fi
fi

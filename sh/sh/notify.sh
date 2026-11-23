#!/usr/bin/env bash
# Send a desktop notification. Clicking it focuses the terminal (kitty or
# alacritty) and switches to the tmux session/window/pane where notify was
# called.
#
# The terminal is the one of the newest tmux client at this machine, from the
# name of the terminal of the client: xterm-kitty is kitty, and every other
# name is alacritty. Outside tmux, the name is $TERM. The notification has the
# icon of that terminal, and the click focuses it. The notification is skipped
# only when one of the two terminals has the focus, see below.
#
# The third argument is the bundle id of an app. On macOS, the notification
# then has the icon of that app, and the click still focuses the terminal.
# macOS takes the icon only from the app of the bundle id that alerter sends
# with, and not from --app-icon. alerter uses the older notification API, and
# usernoted denies it for an app that uses the newer one, for example
# com.anthropic.claudefordesktop or Slack: "Legacy client ... connecting to
# modern client". The notification does not show, and alerter hangs. The flag
# 0x10000000 of the app in com.apple.ncprefs marks the newer API, and the app
# sets it again when it opens. So before each notification, notify.sh clears
# the flag of the app and restarts usernoted, which reads it at start.
#
# On macOS, uses alerter which prints the user's action to stdout. On click
# (@CONTENTCLICKED), we focus the terminal and switch tmux to the captured target.
# If the terminal is closed, it opens via the .app bundle (correct dock icon) with
# tmux as its program to attach directly to the right tmux session. Auto-dismiss kills the alerter
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
# Full paths to tmux and the terminal are baked into the click handler because it runs
# in a background subshell without the nix PATH. The .app is the copy that
# home-manager makes in ~/Applications/Home Manager Apps, the same app that
# Spotlight and Hammerspoon open. A running terminal is focused by its bundle
# id, because the copy of kitty runs the binary in the nix store, and macOS
# can then take the copy for another app and open a new one.
# $TMUX_PANE is used instead of display-message -p to get the stable pane
# identity, since the latter follows the user's current view.
#
# On Linux, uses notify-send with --action/--wait for click-to-focus (same
# pattern as alerter on macOS). Two actions are registered: "default" is the
# spec's body-click action (invisible, fires when clicking anywhere on the
# notification) and "click" renders the visible Open entry. xdotool replaces
# osascript for detecting the focused window and activating the terminal. Falls
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
# the red dot badge, see https://github.com/alacritty/alacritty/issues/4472, and
# kitty asks for attention on a bell, see window_alert_on_bell in the kitty docs).
# The bounce only works if you've switched away from the terminal to another app.
# On Linux, the bell triggers the urgency hint.
#
# Called from utils.sh as a thin wrapper and from Claude Code Stop hook.

title="${1:-Notification}"
message="${2:-Done}"
sender="${3:-}"
terminal=$TERM

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
  #
  # A click switches the newest client at this machine. A bare
  # `display-message -p '#{client_tty}'` gives the newest client of the session
  # of the pane, which is a client over SSH when the client at this machine
  # shows another session. The click then switched the client over SSH.
  away=1
  client=
  while read -r pid tty termname flags pane; do
    if [ "$(~/sh/is-over-ssh.sh "$pid")" = 0 ]; then
      away=
      [ -n "$client" ] || { client=$tty; terminal=$termname; }
      if [[ "$flags" == *focused* ]] && [ "$pane" = "$target" ]; then
        current_pid=$pid
        current_target=$pane
      fi
    fi
  done < <(tmux list-clients -F '#{client_activity} #{client_pid} #{client_tty} #{client_termname} #{client_flags} #{session_name}:#{window_index}.#{pane_index}' | sort -rn | cut -d' ' -f2-)
  skip_gui=$away
  if [ "$target" = "$current_target" ] && [ "$(~/sh/is-over-ssh.sh "$current_pid")" = 1 ]; then
    skip_gui=1
  fi
  socket=$(echo "$TMUX" | cut -d, -f1)
  tmux_bin=$(which tmux)
elif [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
  # Outside tmux, the SSH_* variables are the ones of this login, as in
  # prompt.sh.
  away=1
  skip_gui=1
fi

if [ "$(uname)" = "Darwin" ]; then
  # The bundle id, because the name of the kitty process is that of the nix
  # wrapper, .kitty-wrapped. alacritty needs -e before the program to run.
  if [ "$terminal" = xterm-kitty ]; then
    terminal_app=~/"Applications/Home Manager Apps/kitty.app"
    terminal_id=net.kovidgoyal.kitty
    terminal_args=()
  else
    terminal_app=~/"Applications/Home Manager Apps/Alacritty.app"
    terminal_id=org.alacritty
    terminal_args=(-e)
  fi
  # Clears the flag of the newer API for the app of the sender, see the top.
  if [ -n "$sender" ]; then
    ncprefs=$(mktemp)
    defaults export com.apple.ncprefs "$ncprefs"
    if python3 - "$ncprefs" "$sender" <<'EOF'
import plistlib, sys
path, sender = sys.argv[1:]
prefs = plistlib.load(open(path, 'rb'))
found = False
for app in prefs.get('apps', []):
    if app.get('bundle-id') == sender and app.get('flags', 0) & 0x10000000:
        app['flags'] &= ~0x10000000
        found = True
plistlib.dump(prefs, open(path, 'wb'), fmt=plistlib.FMT_BINARY)
sys.exit(0 if found else 1)
EOF
    then
      defaults import com.apple.ncprefs "$ncprefs"
      killall usernoted
      sleep 1
    fi
    rm -f "$ncprefs"
  fi
  sender=${sender:-$terminal_id}
  alerter_bin=$(which alerter)
  if [ -n "$TMUX" ]; then
    frontmost=$(osascript -e 'tell application "System Events" to get bundle identifier of first application process whose frontmost is true')
    if [ -z "$skip_gui" ] && { [ "$target" != "$current_target" ] || { [ "$frontmost" != net.kovidgoyal.kitty ] && [ "$frontmost" != org.alacritty ]; }; }; then
      alerter_pid_file="/tmp/.notify-alerter-pid-${TMUX_PANE#%}"
      (
        pid_file=$(mktemp "$alerter_pid_file.XXXXXX")
        result_file=$(mktemp /tmp/.notify-alerter-result.XXXXXX)
        alerter --title "$title" --message "$message" \
          --sender "$sender" \
          --group "notify" \
          > "$result_file" &
        echo $! > "$pid_file"
        wait $!
        result=$(cat "$result_file" 2>/dev/null)
        rm -f "$pid_file" "$result_file"
        if [ "$result" = "@CONTENTCLICKED" ] || [ "$result" = "@ACTIONCLICKED" ]; then
          if [ "$(osascript -e "application id \"$terminal_id\" is running")" = true ]; then
            open -b "$terminal_id"
            "$tmux_bin" -S "$socket" switch-client -c "$client" -t "$target" 2>/dev/null
          else
            open -a "$terminal_app" --args "${terminal_args[@]}" "$tmux_bin" -S "$socket" attach-session -t "$target"
          fi
        fi
      ) </dev/null >/dev/null 2>&1 &
      "$tmux_bin" -S "$socket" set-hook -p -t "$TMUX_PANE" pane-focus-in \
        "run-shell -b '{ for f in ${alerter_pid_file}.*; do pid=\$(cat \$f 2>/dev/null) && kill \$pid 2>/dev/null; rm -f \$f; done; ${tmux_bin} -S ${socket} set-hook -p -t ${TMUX_PANE} -u pane-focus-in; } >/dev/null 2>&1'"
    fi
  elif [ -z "$skip_gui" ]; then
    (alerter --title "$title" --message "$message" \
      --sender "$sender" \
        --group "notify" \
      > /dev/null &
    )
  fi
else
  if [ -n "$TMUX" ]; then
    # A pane that a client over SSH created has no DISPLAY, because tmux takes
    # it from that client. xdotool then fails, the empty class does not match,
    # and the notification shows while the user looks at the pane. Nothing
    # closes it then, because the pane does not get the focus again. The
    # tmux server started under X, so its DISPLAY is the one of this machine.
    if [ -z "$DISPLAY" ]; then
      display=$(tmux show-environment -g DISPLAY 2>/dev/null)
      [[ "$display" != DISPLAY=* ]] || export DISPLAY="${display#DISPLAY=}"
    fi
    if [ "$terminal" = xterm-kitty ]; then
      terminal_class=kitty
    else
      terminal_class=Alacritty
    fi
    focused=$(xdotool getactivewindow getwindowclassname 2>/dev/null)
    if [ -z "$skip_gui" ] && { [ "$target" != "$current_target" ] || { [[ "${focused,,}" != kitty ]] && [[ "${focused,,}" != alacritty ]]; }; }; then
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
          xdotool search --class "$terminal_class" windowactivate 2>/dev/null
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

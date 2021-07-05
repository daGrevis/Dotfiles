#!/usr/bin/env bash

MUX_MRU=~/.mux-mru

# Easy jumping between tmux/tmuxinator sessions via fzf.
mux() {
  if ! tmux_sessions=$(tmux ls 2> /dev/null); then
    tmux_sessions=''
  fi

  tmux_sessions=$(printf '%s' "$tmux_sessions" | cut -d : -f 1)

  if ! tmuxinator_sessions=$(find ~/.config/tmuxinator/ -type f -exec basename -s '.yml' {} \; 2> /dev/null) ; then
    tmuxinator_sessions=''
  fi

  # Concat tmux and tmuxinator sessions without empty lines.
  sessions=$(printf '%s\n%s' "$tmuxinator_sessions" "$tmux_sessions" | sed '/^$/d')

  # Remove duplicates.
  sessions=$(printf '%s' "$sessions" | awk '!x[$0]++')

  if [ "$1" != '' ]; then
    # Use the 1st argument as the session selection, avoid fzf selection completely.
    session_selection="$1"
  else
    if [ -f "$MUX_MRU" ]; then
      # If we have $MUX_MRU file, remove sessions from it that no longer exist, but keep the order.
      sessions=$(printf '%s' "$sessions" | awk 'NR==FNR{a[$0];next} ($0 in a)' - "$MUX_MRU")

      # Add sessions to the end and remove duplicates once again to append new sessions not existing in $MUX_MRU if any.
      sessions=$(printf '%s\n%s' "$sessions" "$sessions" | awk '!x[$0]++')
    fi

    if [ -z "$TMUX" ]; then
      fzf_sessions="$sessions"
    else
      # Need to check for $TMUX because display-message will return even when not running inside of tmux.
      current_session=$(tmux display-message -p '#S')

      # Filter out current session because it doesn't make sense to switch to it again.
      fzf_sessions=$(printf '%s' "$sessions" | grep -v "$current_session")
    fi

    fzf_output=$(printf '%s' "$fzf_sessions" | fzf --tac --print-query | tail -n 1)

    session_selection=$(printf '%s' "$fzf_output" | tail -n 1)
  fi

  # If no selection is made, do nothing.
  if [ "$session_selection" = '' ]; then
    return
  fi

  # Remove the selection if it already exists and add it to the end.
  sessions=$(printf '%s' "$sessions" | grep -v "$session_selection")
  sessions=$(printf '%s\n%s' "$sessions" "$session_selection")

  printf '%s' "$sessions" > "$MUX_MRU"

  if [ -z "$TMUX" ]; then
    # If we are NOT running inside of tmux already, try to attach to an existing session.
    if tmux attach -t "$session_selection" 1> /dev/null 2> /dev/null; then
      return
    fi

    # If we couldn't attach to an existing session, try to start a tmuxinator session with this name.
    if tmuxinator start --suppress-tmux-version-warning=SUPPRESS-TMUX-VERSION-WARNING "$session_selection" 1> /dev/null 2> /dev/null; then
      return
    fi

    # If we couldn't start a tmuxinator session, fallback to creating an empty session.
    tmux new -c ~ -s "$session_selection"
  else
    # If we are running inside of tmux, try to switch to a different session.
    if tmux switch -t "$session_selection" 1> /dev/null 2> /dev/null; then
      return
    fi

    # If we couldn't switch to a different session, try to start a tmuxinator session with this name. Tmuxinator itself will handle us already being inside of tmux.
    if tmuxinator start --suppress-tmux-version-warning=SUPPRESS-TMUX-VERSION-WARNING "$session_selection" 1> /dev/null 2> /dev/null; then
      return
    fi

    # If we couldn't start a tmuxinator session, fallback to creating an empty session and switching.
    tmux new -c ~ -d -s "$session_selection" && tmux switch -t "$session_selection"
  fi
}

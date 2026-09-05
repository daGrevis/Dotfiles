#!/usr/bin/env bash

# https://www.passwordstore.org/

PASS_PATH=~/.password-store

_pass-fzf() {
  # Select password with fzf. Call with:
  # - no arguments to select from all password
  # - top-level directory to limit selection (eg `home`)
  # - path to GPG file without extension (eg `home/github`)

  local pw=$1
  local has_dir pws

  if [ "$pw" != "" ] && [ -f "$PASS_PATH/$pw.gpg" ]; then
    echo "$pw"
    return
  fi

  has_dir=0
  if [ "$pw" != "" ] && [ -d "$PASS_PATH/$pw" ]; then
    has_dir=1
  fi

  if [ "$pw" != "" ] && [ $has_dir = 0 ]; then
    echo 'Error: Directory not found' >&2
    return 1
  fi

  if [ "$pw" = "" ] || [ $has_dir = 1 ]; then
    pws=$(cd "$PASS_PATH" && find "./$pw" -type f -name '*.gpg' | sed -n 's/^\.\///p' | sed -n 's/\.gpg$//p')
    pw=$(echo "$pws" | fzf --print-query | tail -n1)
  fi

  if [ "$pw" = "" ]; then
    return 1
  fi

  echo "$pw"
}

pws() {
  local pw
  pw=$(_pass-fzf "$1") || return
  pass show "$pw" | nvim -R -n -i NONE -
}

pwe() {
  local pw
  pw=$(_pass-fzf "$1") || return
  EDITOR='nvim -n -i NONE' pass edit "$pw"
}

pwi() {
  EDITOR='nvim -n -i NONE' pass edit "$1"
}

pwc() {
  local entry pw
  entry=$(_pass-fzf "$1") || return
  pw=$(pass show "$entry" | head -n 1)
  echo -n "$pw" | clip
}

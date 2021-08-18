#!/usr/bin/env bash

# https://www.passwordstore.org/

PASS_PATH=~/.password-store

_pass-fzf() {
  # Select password with fzf. Call with:
  # - no arguments to select from all password
  # - top-level directory to limit selection (eg `home`)
  # - path to GPG file without extension (eg `home/github`)

  pw=$1

  if [ "$pw" != "" ] && [ -f "$PASS_PATH/$pw.gpg" ]; then
    echo "$pw"
    return
  fi

  has_dir=0
  if [ "$pw" != "" ] && [ -d "$PASS_PATH/$pw" ]; then
    has_dir=1
  fi

  if [ "$pw" != "" ] && [ $has_dir = 0 ]; then
    echo 'Error: Directory not found'
    return 1
  fi

  if [ "$pw" = "" ] || [ $has_dir ]; then
    pws=$(cd "$PASS_PATH" && find "./$pw" -type f -name '*.gpg' | sed -n 's/^\.\///p' | sed -n 's/\.gpg$//p')
    pw=$(echo "$pws" | fzf --print-query | tail -n1)
  fi

  if [ $has_dir = 1 ]; then
    echo "$1/$pw"
  else
    echo "$pw"
  fi
}

pws() {
  pass show "$(_pass-fzf "$1")"
}

pwe() {
  pass edit "$(_pass-fzf "$1")"
}

pwi() {
  pass edit "$1"
}

pwc() {
  pw=$(pass show "$(_pass-fzf "$1")" | head -n 1)
  echo -n "$pw" | clip
}

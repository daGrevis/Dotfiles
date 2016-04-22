#!/bin/bash

shopt -s nullglob globstar

password_files=( ~/.password-store/**/*.gpg )
password_files=( "${password_files[@]##*/.password-store/}" )
password_files=( "${password_files[@]%.gpg}" )

dmenu_input=$(printf '%s\n' "${password_files[@]}")
name=$(themenu.sh "$dmenu_input")

pass --clip "$name"
rc=$?

if [[ "$name" != "" ]] && [[ $rc -eq 0 ]]; then
    notify-send -u low "Password Copied" "$name"
fi;

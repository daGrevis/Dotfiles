#!/bin/bash

shopt -s nullglob globstar

export FAVFILE=~/passmenu.fav

password_files=( ~/.password-store/**/*.gpg )
password_files=( "${password_files[@]##*/.password-store/}" )
password_files=( "${password_files[@]%.gpg}" )

dmenu_input=$(
    fav.py ls --only-phrases;
    printf '%s\n' "${password_files[@]}"
)
# Filter out unique lines without sorting.
dmenu_input=$(echo "$dmenu_input" | awk '!x[$0]++')

phrase=$(themenu.sh "$dmenu_input")

pass --clip "$phrase"
rc=$?

if [[ "$phrase" != "" ]] && [[ $rc -eq 0 ]]; then
    fav.py insert "$phrase"
    notify-send -u low "Password Copied" "$phrase"
fi;

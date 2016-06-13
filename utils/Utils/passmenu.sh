#!/bin/bash

shopt -s nullglob globstar

export FAVFILE=~/passmenu.fav

password_files=(~/.password-store/**/*.gpg)
password_files=("${password_files[@]##*/.password-store/}")
password_files=("${password_files[@]%.gpg}")

resources=$(
    fav ls --only-names;
    printf '%s\n' "${password_files[@]}"
)
# Filter out duplicated resources without sorting
resources=$(echo "$resources" | awk '!x[$0]++')

selection=$(themenu.sh "$resources")

pass --clip "$selection"
rc=$?

if [[ "$selection" != "" ]] && [[ $rc -eq 0 ]]; then
    fav insert "$selection"
    notify-send -u low "Password Copied" "$selection"
fi;

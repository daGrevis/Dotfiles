#!/bin/zsh

. ~/Utils/colors.sh

password_files=( ~/.password-store/**/*.gpg )
password_files=( "${password_files[@]##*/.password-store/}" )
password_files=( "${password_files[@]%.gpg}" )

loc=$(printf '%s\n' "${password_files[@]}" | dmenu -fn "$PANEL_FONT_FAMILY-$PANEL_FONT_SIZE" -p ">" -nb $COLOR_01 -nf $COLOR_07 -sb $COLOR_0D "$@")

pass -c "$loc" > /dev/null
rc=$?

if [[ "$loc" != "" ]] && [[ $rc -eq 0 ]]; then
    notify-send -u low "Password copied" "$loc"
fi;
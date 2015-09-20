#!/bin/zsh

. ~/Utils/colors.sh

password_files=( ~/.password-store/**/*.gpg )
password_files=( "${password_files[@]##*/.password-store/}" )
password_files=( "${password_files[@]%.gpg}" )

loc=$(printf '%s\n' "${password_files[@]}" | dmenu -b -i -fn "Fira Mono-9" -nb $COLOR_01 -nf $COLOR_07 -sb $COLOR_0D -sf $COLOR_01 "$@")

pass -c "$loc" > /dev/null
rc=$?

if [[ "$loc" != "" ]] && [[ $rc -eq 0 ]]; then
    notify-send -u low "Password copied" "$loc"
fi;

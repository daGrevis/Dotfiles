#!/usr/bin/env bash

v() {
    if [ -f Session.vim ] && [ $# -eq 0 ]; then
        nvim -S
    else
        nvim -p "$@"
    fi
}
alias vim=v

alias serve-http='python3 -m http.server'

unalias l
l() {
    # https://github.com/ogham/exa
    command -v exa &> /dev/null
    if [ "$?" != "0" ]; then
        ls -lahtr "$@"
    else
        exa -lag -s modified "$@"
    fi
}

mkcd() {
    mkdir -p "$@" && cd "$@"
}

f() {
    find . -name "$@"
}

ff() {
    find . -name "*$@*"
}

t() {
    tree -a -I ".git" "$@"
}

df() {
    command -v colordiff &> /dev/null
    if [ "$?" != "0" ]; then
        diff -u "$@" | less
    else
        colordiff -u "$@" | less
    fi
}

generate-password() {
    xkcdpass -d "-"
}

format-json() {
    cat "$@" | python -m json.tool
}

ip-addresses() {
    ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}'

    curl ipecho.net/plain
    echo
}

view-markdown() {
    grip "$1" 7777 -b
}

aux() {
    ps aux | head -n 1
    ps aux | grep -i $@
}

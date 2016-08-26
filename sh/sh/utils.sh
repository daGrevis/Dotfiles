#!/usr/bin/env bash

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

alias vim=nvim
alias v=nvim

mkcd() {
    mkdir -p "$@" && cd "$@"
}

f() {
    find . -name "$@"
}

ff() {
    find . -name '*$@*'
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

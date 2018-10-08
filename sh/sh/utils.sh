#!/usr/bin/env bash

v() {
    if [ -f Session.vim ] && [ $# -eq 0 ]; then
        nvim -S
    else
        nvim -p "$@"
    fi
}
alias vim=v
alias vv='nvim -u NORC'

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

dff() {
    command -v colordiff &> /dev/null
    if [ "$?" != "0" ]; then
        diff -u "$@" | less
    else
        colordiff -u "$@" | less
    fi
}

pjson() {
    python -c 'import fileinput, json; print(json.dumps(json.loads("".join(fileinput.input())), indent=2))'
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

alias ka='killall'
alias k9='kill -9'

open-preview() {
    open -a /Applications/Preview.app $@
}

open-chrome() {
    open -a /Applications/Google\ Chrome.app $@
}

s() {
    source .env && echo '.env sourced!'
}

p() {
    command -v prettyping &> /dev/null
    if [ "$?" != "0" ]; then
        ping google.com
    else
        prettyping --nolegend google.com
    fi
}

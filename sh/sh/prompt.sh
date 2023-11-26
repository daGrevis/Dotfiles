#!/usr/bin/env bash

# Needed for function expansion to work in PROMPT.
setopt PROMPT_SUBST

return_status() {
    if [ "$?" != '0' ]; then
        echo -n '%B%F{red}!%f%b'
    else
        echo -n '%B%F{green}>%f%b'
    fi
}

extra_status() {
    has_output=0

    if [ "$(whoami)" = 'root' ]; then
        has_output=1
        echo -n '%B%F{red}[root]%f%b'
    fi

    if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
        has_output=1
        echo -n '%B%F{yellow}[ssh]%f%b'
    fi

    if [ $has_output -eq 1 ]; then
        echo -n ' '
    fi
}

git_prompt_info() {
    local is_dirty=0
    local is_repo=1

    if git diff-files --quiet 2> /dev/null; then
        is_dirty=0
    else
        local rc="$?"
        if [ "$rc" = 128 ]; then
            is_repo=0
        else
            is_dirty=1
        fi
    fi

    if [ "$is_repo" -eq 0 ]; then
        echo -n ''
        return 1
    fi

    local branch
    branch=$(git symbolic-ref --quiet --short HEAD 2> /dev/null)

    local location
    if [ "$branch" ]; then
        location=$branch
    else
        local rev
        rev=$(git rev-parse HEAD)
        local rev_short=${rev:0:7}

        location=$rev_short
    fi

    local dirty=''
    if [ $is_dirty -eq 1 ]; then
        dirty='±'
    fi

    echo -n "%B%F{blue}git[%f%F{white}$location%f%F{yellow}$dirty%f%F{blue}]%f%b "
}

preexec() {
    timer=$(print -P '%D{%s%3.}')
}

precmd() {
    statuscode="$?"
    statusprompt=''
    if [ "$statuscode" != '0' ]; then
        statusprompt="%B%F{red}$statuscode%f%b "
    fi

    timeprompt=''
    if [ "$timer" ]; then
        now=$(print -P '%D{%s%3.}')
        local d_ms=$((now - timer))
        local d_s=$((d_ms / 1000))
        local ms=$((d_ms % 1000))
        local s=$((d_s % 60))
        local m=$(((d_s / 60) % 60))
        local h=$((d_s / 3600))

        if ((h > 0)); then
            timeprompt="${h}h ${m}m ${s}s" # 1h 2m 3s
        elif ((m > 0)); then
            timeprompt="${m}m ${s}s" # 1m 2s
        elif ((s > 0)); then
            timeprompt="${s}.$(printf %03d $ms)s" # 1.234s
        elif ((ms > 0)); then
            timeprompt="${ms}ms" # 123ms
        fi

        if [ "$timeprompt" ]; then
            timeprompt="%B%F{black}${timeprompt} %f%b"
        fi;

        unset timer
    fi

    export RPROMPT="${statusprompt}${timeprompt}"
}

# shellcheck disable=SC2016
export PROMPT='$(return_status) $(extra_status)%F{cyan}%c%f $(git_prompt_info)'

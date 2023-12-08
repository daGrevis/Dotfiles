#!/usr/bin/env bash

# Needed for function expansion to work in PROMPT.
setopt PROMPT_SUBST

char_prompt() {
    local exit_code="$1"

    if [ "$exit_code" != '0' ]; then
        echo -n '%B%F{red}!%f%b'
    else
        echo -n '%B%F{green}>%f%b'
    fi
}

properties_prompt() {
    has_output=0

    if [ "$USER" = 'root' ]; then
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

git_prompt() {
    local is_dirty=0
    local is_repo=1

    if git diff-files --quiet 2> /dev/null; then
        is_dirty=0
    else
        local exit_code="$?"
        if [ "$exit_code" = 128 ]; then
            is_repo=0
        else
            is_dirty=1
        fi
    fi

    if [ "$is_repo" -eq 0 ]; then
        echo -n ''
        return
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

exit_code_prompt() {
    local exit_code="$1"

    if [ "$exit_code" != '0' ]; then
        echo -n "%B%F{red}$exit_code%f%b "
        return
    fi

    echo -n ''
}

timing_prompt() {
    if [ "$timer" ]; then
        now=$(print -P '%D{%s%3.}')
        local d_ms=$((now - timer))
        local d_s=$((d_ms / 1000))
        local ms=$((d_ms % 1000))
        local s=$((d_s % 60))
        local m=$(((d_s / 60) % 60))
        local h=$((d_s / 3600))

        local duration=''
        if ((h > 0)); then
            duration="${h}h ${m}m ${s}s" # 1h 2m 3s
        elif ((m > 0)); then
            duration="${m}m ${s}s" # 1m 2s
        elif ((s > 0)); then
            duration="${s}.$(printf %03d $ms)s" # 1.234s
        elif ((ms > 0)); then
            duration="${ms}ms" # 123ms
        fi

        if [ "$duration" ]; then
            echo -n "%B%F{black}${duration} %f%b"
            return
        fi;

        unset timer
    fi

    echo -n ''
}

preexec() {
    timer=$(print -P '%D{%s%3.}')
}

precmd() {
    exit_code="$?"

    PROMPT="$(char_prompt $exit_code) $(properties_prompt)%F{cyan}%c%f $(git_prompt)"
    export PROMPT

    RPROMPT="$(exit_code_prompt $exit_code)$(timing_prompt)"
    export RPROMPT
}

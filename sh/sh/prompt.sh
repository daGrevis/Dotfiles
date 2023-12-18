#!/usr/bin/env bash

# Needed for function expansion to work in PROMPT.
setopt PROMPT_SUBST

user_and_host_prompt() {
    if [ -z "$is_user_and_host_echoed" ]; then
        echo -n "%F{yellow}$USER%f%F{black}@%f%F{green}$HOST%f "
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

    if [ $has_output = 1 ]; then
        echo -n ' '
    fi
}

git_prompt() {
    local git_status
    git_status=$(git status --porcelain 2> /dev/null)

    local git_status_exit_code="$?"
    if [ "$git_status_exit_code" != '0' ]; then
        return
    fi

    local is_dirty=0
    if [ -n "$git_status" ]; then
        is_dirty=1
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
    if [ $is_dirty = 1 ]; then
        dirty='±'
    fi

    echo -n "%F{cyan}git%f:%B%F{white}$location%f%b%F{yellow}$dirty%f "
}

char_prompt() {
    if [ "$USER" = 'root' ]; then
        echo -n '%F{white}#%f'
    else
        echo -n '%F{white}%%%f'
    fi
}

exit_code_prompt() {
    local exit_code="$1"

    if [ "$exit_code" != '0' ]; then
        echo -n "%B%F{red}$exit_code%f%b "
        return
    fi
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
            echo -n "%F{black}${duration}%f"
            return
        fi;
    fi
}

preexec() {
    is_execed=0
    timer=$(print -P '%D{%s%3.}')
    is_user_and_host_echoed=0
}

precmd() {
    exit_code="$?"

    if [ "$is_execed" = '1' ]; then
        # If we have rendered the prompt already, <Enter>, <C-c> or something similar has been pressed.
        # In such case, act as no command was run and pretend the exit code is successful.
        exit_code=0
    fi

    PROMPT="$(user_and_host_prompt)%B%F{blue}%c%f%b $(properties_prompt)$(git_prompt)$(char_prompt) "
    export PROMPT

    RPROMPT=" $(exit_code_prompt $exit_code)$(timing_prompt)"
    export RPROMPT

    is_user_and_host_echoed=1

    if [ "$is_execed" = '0' ]; then
        is_execed=1
        unset timer
    fi
}

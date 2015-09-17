#!/bin/zsh

# http://superuser.com/questions/655607/removing-the-useless-space-at-the-end-of-the-right-prompt-of-zsh-rprompt
ZLE_RPROMPT_INDENT=0

reset_color() {
    echo "%{$reset_color%}"
}

set_fg() {
    echo "%{$fg[$@]%}"
}

set_fg_bold() {
    echo "%{$fg_bold[$@]%}"
}

who_and_where() {
    if [ -n "$SSH_CLIENT" ]; then
        s="$(set_fg yellow)%n$(reset_color)"
        s+="@"
        s+="$(set_fg magenta)%m$(reset_color)"
        s+=" "
    else
        s=""
    fi
    echo $s
}

git_info() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        echo "$(git_prompt_info)"
    else
        echo ""
    fi
}

current_directory() {
    dir="${PWD/#$HOME/~}"
    parts=("${(@s:/:)dir}")

    s=""
    for part in $parts; do
        x=${part:0:20}
        if [ "$x" != "$part" ]; then
            x="$x…"
        fi
        s="$s$x/";
    done

    if [ "$s" = "~/" ]; then
        s="~"
    fi

    s="%(?:$(set_fg green)$s:$(set_fg red)$s)"

    echo "$s$(reset_color)"
}

PROMPT='$(who_and_where)$(current_directory)$(git_prompt_info) '

ZSH_THEME_GIT_PROMPT_PREFIX=" $(set_fg blue)"
ZSH_THEME_GIT_PROMPT_DIRTY="$(set_fg_bold yellow)±"
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_SUFFIX="$(reset_color)"

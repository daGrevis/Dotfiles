# vim: set ft=zsh

return_status() {
    if [ "$?" != "0" ]; then
        echo -n "%{$fg_bold[red]%}!%{$reset_color%} "
    else
        echo -n "%{$fg_bold[green]%}>%{$reset_color%} "
    fi
}

extra_status() {
    has_output=0

    if [ $(whoami) = "root" ]; then
        has_output=1
        echo -n "%{$fg_bold[red]%}[root]%{$reset_color%}"
    fi

    if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
        has_output=1
        echo -n "%{$fg_bold[yellow]%}[ssh]%{$reset_color%}"
    fi

    if [ -n "$NVM_PATH" ]; then
        has_output=1
        echo -n "%{$fg_bold[green]%}[nvm]%{$reset_color%}"
    fi

    if [ $has_output -eq 1 ]; then
        echo -n ' '
    fi
}

preexec() {
    timer=$(print -P %D{%s%3.})
}

precmd() {
    statuscode="$?"
    statusprompt=""
    if [ "$statuscode" != "0" ]; then
        statusprompt="%{$fg_bold[red]%}$statuscode%{$reset_color%} "
    fi

    timeprompt=""
    if [ $timer ]; then
        now=$(print -P %D{%s%3.})
        local d_ms=$(($now - $timer))
        local d_s=$((d_ms / 1000))
        local ms=$((d_ms % 1000))
        local s=$((d_s % 60))
        local m=$(((d_s / 60) % 60))
        local h=$((d_s / 3600))

        if ((h > 0)); then
            timeprompt=${h}h${m}m${s}s
        elif ((m > 0)); then
            timeprompt=${m}m${s}.$(printf $(($ms / 100)))s # 1m12.3s
        elif ((s > 9)); then
            timeprompt=${s}.$(printf %02d $(($ms / 10)))s # 12.34s
        elif ((s > 0)); then
            timeprompt=${s}.$(printf %03d $ms)s # 1.234s
        else
            timeprompt=${ms}ms
        fi
        timeprompt="%{$fg_bold[black]%}${timeprompt} %{$reset_color%}"

        unset timer
    fi

    export RPROMPT="${statusprompt}${timeprompt}"
}

PROMPT='$(return_status)$(extra_status)%{$fg[cyan]%}%c%{$reset_color%} $(git_prompt_info)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git[%{$fg[white]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[yellow]%}±%{$fg[blue]%}]"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}]"

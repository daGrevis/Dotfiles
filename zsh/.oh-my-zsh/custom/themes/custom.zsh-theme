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

PROMPT='$(return_status)$(extra_status)%{$fg[cyan]%}%c%{$reset_color%} $(git_prompt_info)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git[%{$fg[white]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[yellow]%}±%{$fg[blue]%}]"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}]"

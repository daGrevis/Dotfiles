function ssh_prompt {
    if [[ -n "$SSH_CLIENT" ]]; then
        echo "$fg_bold[yellow]ssh$reset_color "
    fi
}

function directory_prompt {
    echo '%~'
}

PROMPT=" $(ssh_prompt)$(directory_prompt) %% "

#!/bin/bash

alias ga="git add"
alias gaa="git add -A"
alias gbr="git branch"
alias gc!="git commit -v --am"
alias gc="git commit -v"
alias gcl="git clone"
alias gcls="git clone --depth 1"
alias gcm="git commit -v"
alias gco="git checkout"
alias gcob="git checkout -b"
alias gcp="git cherry-pick"
alias gd="git diff"
alias gdf="git diff"
gl() {
    rev_before=$(git rev-parse HEAD)

    git pull
    if [ "$?" = "0" ]; then
        rev_after=$(git rev-parse HEAD)

        if [ "$rev_before" = "$rev_after" ]; then
            return 0
        fi

        rev_range="$rev_before..$rev_after"
        rev_range_short="${rev_before:0:7}..${rev_after:0:7}"

        echo
        echo "$rev_range_short"
        git --no-pager log "$rev_range" \
            --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'
        echo
    fi
}
glg() {
    git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' "$@"
}
alias gmr="git merge"
alias gp="git push"
alias grm="git rm"
alias grs="git reset"
alias grv="git revert"
alias gs="git status -sb"
alias gsb="git status -sb"
alias gst="git status -sb"
alias gsw="git show"
alias gswl="git show --name-only"
alias gtg="git tag"

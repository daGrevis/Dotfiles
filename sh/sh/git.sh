#!/usr/bin/env bash

# Disable automatic git-lfs downloads.
export GIT_LFS_SKIP_SMUDGE=1

GIT_LOG_PRETTY_FORMAT='%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cs, %cr) %C(bold blue)<%an>%Creset'

alias ga="git add"
alias gaa="git add -A"
alias gbr="git branch"
alias gc="git commit -v"
alias gc!="git commit -v --amend --date=now"
alias gcl="git clone"
alias gcls="git clone --depth 1"
alias gcm="git commit -v"
alias gco="git checkout"
alias gcob="git checkout -b"
alias gcp="git cherry-pick"
alias gd="git diff"
gl() {
    rev_before=$(git rev-parse HEAD)

    git pull origin $(git branch | grep \* | cut -d ' ' -f2)
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
            --pretty=format:"$GIT_LOG_PRETTY_FORMAT"
        echo
    fi
}
alias gll='git-lfs pull'
glg() {
    git log --graph --pretty=format:"$GIT_LOG_PRETTY_FORMAT" "$@"
}
alias gmr="git merge"
alias gp="git push"
alias grm="git rm"
alias grs="git reset"
alias grv="git revert"
alias grb="git rebase"
alias grbc="git rebase --continue"
alias grbs="git rebase --skip"
alias grba="git rebase --abort"
alias gs="git status -sb"
gsw() {
    git --no-pager show "$@" | less -R --pattern '^diff --git'
}
alias gswl="git show --name-only"
alias gtg="git tag"
alias gfc="git fetch"

alias git-delete-local-branch="git branch -D"
alias git-delete-remote-branch="git push origin --delete"

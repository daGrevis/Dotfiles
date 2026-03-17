#!/usr/bin/env bash

# Disable automatic git-lfs downloads.
export GIT_LFS_SKIP_SMUDGE=1

GIT_LOG_PRETTY_FORMAT='%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cs, %cr) %C(bold blue)%aN%Creset %C(magenta)<%aE>%Creset'

alias ga="git add --all"
alias gap="git add -p"
alias gac="ga && gc"
alias gbr="git branch"
alias gc="git commit -v"
alias gc!="git commit -v --amend --date=now"
alias gcm="gc -m"
alias gcl="git clone"
alias gcls="git clone --depth 1"
alias gco="git checkout"
alias gcop="git checkout -p"
alias gcob="git checkout -b"
alias gcp="git cherry-pick"
alias gcpc="git cherry-pick --continue"
alias gcps="git cherry-pick --skip"
alias gcpa="git cherry-pick --abort"
unalias gd 2>/dev/null
# Git diff via delta. Press r to reload which will update the diff and keep the scroll position.
gd() {
    local cmd_file="/tmp/.gd-cmd-$$"
    local out_file="/tmp/.gd-out-$$"
    local hist_file="/tmp/.gd-hist-$$"
    local keyfile=$(mktemp)
    echo "git diff --color=always $* | delta --paging=never --width=$COLUMNS" > "$cmd_file"
    printf '#command\nr set-mark a^X\n^X quit r\n' > "$keyfile"
    local start_cmd=""
    while true; do
        sh "$cmd_file" > "$out_file"
        LESSHISTFILE="$hist_file" less --save-marks -R --lesskey-src="$keyfile" ${start_cmd:+"$start_cmd"} "$out_file"
        [ $? -ne 114 ] && break
        local offset=$(awk '/^m a /{print $4}' "$hist_file" | tail -1)
        if [ -n "$offset" ] && [ "$offset" -gt 0 ]; then
            local line_num=$(( $(head -c "$offset" "$out_file" | wc -l) + 1 ))
            start_cmd="+${line_num}g"
        fi
    done
    rm -f "$cmd_file" "$out_file" "$hist_file" "$keyfile"
}
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
alias glx='gl && gll'
glg() {
    git log --graph --pretty=format:"$GIT_LOG_PRETTY_FORMAT" "$@"
}
alias gmr="git merge"
alias gp="git push"
alias gpf="git push -f"
alias grm="git rm"
alias grs="git reset"
alias grv="git revert"
alias grvc="git revert --continue"
alias grvs="git revert --skip"
alias grva="git revert --abort"
alias grb="git rebase"
alias grbc="git rebase --continue"
alias grbs="git rebase --skip"
alias grba="git rebase --abort"
unalias gs 2>/dev/null
gs() {
    # Branch line.
    local gs_out
    gs_out=$(git -c color.status=always status -sb) || return
    echo "${gs_out%%$'\n'*}"
    # Show line-level diff stats (added/deleted) including untracked files.
    local stats
    stats=$(git diff --numstat HEAD 2>/dev/null; git ls-files --others --exclude-standard 2>/dev/null | while read -r f; do test -f "$f" && wc -l < "$f"; done | awk '{print $1 "\t" 0 "\t(new file)"}')

    # Line stats.
    if [ -n "$stats" ]; then
        local added=0 deleted=0
        while IFS=$'\t' read -r a d _; do
            [ "$a" != "-" ] && added=$((added + a))
            [ "$d" != "-" ] && deleted=$((deleted + d))
        done <<< "$stats"
        if [ "$added" -gt 0 ] || [ "$deleted" -gt 0 ]; then
            echo -e " \033[32m+${added}\033[0m \033[31m-${deleted}\033[0m"
        fi
    fi
    # File list.
    local files="${gs_out#*$'\n'}"
    if [ "$files" != "$gs_out" ]; then
        echo "$files"
    fi
}
alias gsw="git show"
alias gswl="git show --name-only"
alias gsh="git stash"
alias gshp="git stash pop"
alias gshl="git stash list"
alias gshm="git stash -m"
alias gsha="git stash apply"
alias gtg="git tag"
alias gfc="git fetch"
alias gfca="git fetch --all"

alias git-delete-local-branch="git branch -D"
alias git-delete-remote-branch="git push origin --delete"

alias ls='ls -a --color=always'

alias less='less -R'

function bb {
    echo 'Shutdown scheduled. (Press Ctrl + C to terminate)'
    echo -n 'Countdown... '
    for i in {10..1}
    do
        echo -n "$i "
        sleep 1
    done
    echo
    echo 'Bye-bye then!'
    sudo shutdown -h now
}

function vimdir {
    gvim `find $1 -type f | xargs echo`
}

alias skype2='skype --dbpath=~/.Skype2'

alias rm='rm -i' # Once I accidentally deleted database file. If you think that this is "for noobs", you are an idiot!

alias diff='colordiff -u'

alias p='ping google.com'

function current_branch() {
    ref=$(git symbolic-ref HEAD 2> /dev/null) || \
    ref=$(git rev-parse --short HEAD 2> /dev/null) || return
    echo ${ref#refs/heads/}
}

# Tons of Git alias I'm trying to use daily.
alias gad='git add'
alias gbr='git branch'
alias gcl='git clone'
alias gcm='git commit'
alias gco='git checkout'
alias gcp='git cherry-pick'
alias gdf='git diff'
alias gin='git init'
alias glg="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset <%an>' --abbrev-commit --date=relative"
alias gmr='git merge'
alias gmv='git mv'
alias gpl='git pull'
alias gpu='git push -u origin $(current_branch)'
alias grm='git rm'
alias grs='git reset'
alias grv='git revert'
alias gsh='git stash'
alias gst='git status -sb'
alias gsw='git show'
alias gtg='git tag'

# A command I use for seeing changes between my home and Dotfiles dir.
alias dotdiff='diff ~/Dotfiles/ ~ | grep -v "Only in" | grep -v "Common subdirectories" | less'

# Opens Gvim as it was a real Vim. The difference is little low.
function vim {
    if ! xset q &> /dev/null; then
        command vim -p $@
    else
        command gvim -p $@ & disown
    fi
}
function vimd {
    vim -p $@ && exit
}

alias chromium='chromium'
# alias chromium="chromium --enable-webgl --ignore-gpu-blacklist"

alias l='ls -l'

alias rot13="tr '[a-m][n-z][A-M][N-Z]' '[n-z][a-m][N-Z][A-M]'"
alias rot13_rev="tr '[n-z][a-m][N-Z][A-M]' '[a-m][n-z][A-M][N-Z]'"

function aux {
    ps -aux | grep $1 | grep -v "grep $1"
}

alias :q=exit

# function hexchat {
#     ps cax | grep hexchat > /dev/null
#     if [ $? -eq 0 ]; then
#         /usr/bin/hexchat -ec "gui show"
#     else
#         /usr/bin/hexchat
#     fi
# }

function remove_orphans {
    sudo pacman -Rns $(pacman -Qqtd)
}

function source_zsh {
    source ~/.zshrc
    source ~/.zshenv
}

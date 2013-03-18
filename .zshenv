alias ls='ls -a --color=always'

alias less='less -R'

function bb {
    echo "Shutdown scheduled. (Press Ctrl + C to terminate)"
    echo -n "Countdown... "
    for i in {10..1}
    do
        echo -n "$i "
        sleep 1
    done
    echo
    echo "Bye-bye then!"
    sudo shutdown -h now
}

alias vim='vim -p'

function vimdir {
    vim `find $1 -type f | xargs echo`
}

alias skype2='skype --dbpath=~/.Skype2'

alias rm='rm -i' # Once I accidentally deleted database file. If you think that this is "for noobs", you are an idiot!

alias diff='colordiff -u'

alias p='ping google.com'

alias gad='git add'
alias gbr='git branch'
alias gcl='git clone'
alias gcm='git commit'
alias gco='git checkout'
alias gdf='git diff'
alias gin='git init'
alias glg="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset <%an>' --abbrev-commit --date=relative"
alias gmr='git merge'
alias gmv='git mv'
alias gnw='git checkout -b $0 && git push -u origin $0'
alias gpl='git pull'
alias gpu='git push -u origin $(current_branch)' # Needs Oh-my-zsh.
alias grm='git rm'
alias grs='git reset'
alias grv='git revert'
alias gst='git status -sb'
alias gtg='git tag'

# A command I use for seeing changes between my home and Dotfiles dir.
alias dotdiff='diff . ~ | grep -v "Only in" | grep -v "Common subdirectories" | less'

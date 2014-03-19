source antigen.zsh

antigen use oh-my-zsh

antigen bundle archlinux
antigen bundle autojump
antigen bundle bower
antigen bundle coffee
antigen bundle encode64
antigen bundle gem
antigen bundle git
antigen bundle lein
antigen bundle npm
antigen bundle pass
antigen bundle pip
antigen bundle redis-cli
antigen bundle systemd
antigen-bundle zsh-users/zsh-history-substring-search
antigen bundle zsh-users/zsh-syntax-highlighting

antigen theme robbyrussell

antigen apply

export EDITOR='gvim -f'

setopt interactivecomments

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

alias rm='rm -i'

alias diff='colordiff -u'

alias p='ping google.com'
alias p2='ping 8.8.8.8'

function current_branch() {
    ref=$(git symbolic-ref HEAD 2> /dev/null) || \
    ref=$(git rev-parse --short HEAD 2> /dev/null) || return
    echo ${ref#refs/heads/}
}

alias gad='git add --ignore-removal'
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
alias ggr='git grep --break --heading --line-number'

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

function aux {
    ps -aux | grep $1 | grep -v "grep $1"
}

alias :q=exit

function remove_orphans {
    sudo pacman -Rns $(pacman -Qqtd)
}

function restart_lamp {
    sudo systemctl restart httpd
    sudo systemctl restart mysqld
}

alias time=/usr/bin/time

function random_password {
    pwgen --ambiguous --capitalize --numerals --symbols 16
}

function sdf {
    svn diff | colordiff | less
}

function slg {
    svn log --limit 20 | less
}

function spl {
    svn update
}

function scm {
    svn commit
}

function sst {
    svn status
}

function hr {
    printf '─%.0s' $(seq $COLUMNS)
}

function delete_pyc {
    find . -name '*.pyc' -delete
}

function update_mirrorlist {
    sudo reflector --verbose -l 5 --sort rate --save /etc/pacman.d/mirrorlist
}

function cower_search {
    cower --color=auto --sort=votes -s $1
}

function cower_show {
    cower --color=auto -i $1
}

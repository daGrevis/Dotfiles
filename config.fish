set fish_path $HOME/.oh-my-fish
set fish_greeting ""

set fish_theme robbyrussell
set fish_plugins archlinux autojump

. $fish_path/oh-my-fish.fish

alias l='ls -lahtr'
function cd
    if count $argv >/dev/null
        if test $argv = "..."
            builtin cd ../../
        else
            builtin cd $argv
        end
    else
        builtin cd
    end
end
function mkcd
    mkdir -p $argv
    cd $argv
end
alias generate-password='pwgen -By1 16'
function aux
    ps -aux | head -n 1
    ps -aux | grep $argv | grep -v "grep $argv"
end
alias serve-http='python -m http.server'
alias screenshot='maim'
alias screenshot-window='maim -s -c 1,0,0,0.1'

set EDITOR 'gvim -f'
function vim
    if xset q > /dev/null
        gvim -p $argv
    else
        command vim -p $argv
    end
end
function vimd
    gvim -p $argv; exit
end

alias gad='git add --ignore-removal'
alias gbl='git blame'
alias gbr='git branch'
alias gcl='git clone'
alias gcm='git commit -v'
alias gco='git checkout'
alias gcp='git cherry-pick'
alias gdf='git diff'
alias ggr='git grep --break --heading --line-number'
alias gin='git init'
alias glg="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset <%an>' --abbrev-commit --date=relative"
alias gmr='git merge'
alias gmv='git mv'
alias gpl='git pull'
alias gpu='git push --set-upstream'
alias grm='git rm'
alias grs='git reset'
alias grv='git revert'
alias gs=gst
alias gsh='git stash'
alias gst='git status -sb'
alias gsw='git show'
alias gtg='git tag'

alias dcl='docker pull'
alias dcli='docker rmi -f (docker images -q)'
alias dim='docker images'
alias dkl='docker rm -f'
alias dlg='docker logs'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias drm='docker rm'
alias drmi='docker rmi'
alias drs='docker restart'
alias dstp='docker stop'
alias dstr='docker start'

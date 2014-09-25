set fish_path $HOME/.oh-my-fish
set fish_greeting ""

set fish_theme robbyrussell
set fish_plugins archlinux autojump

. $fish_path/oh-my-fish.fish

set EDITOR 'gvim -f'

alias l='ls -lahtr'

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

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

setopt interactivecomments

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="robbyrussell"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git autojump)

source $ZSH/oh-my-zsh.sh

# User configuration

export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/lib/jvm/default/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl"
PATH=$PATH:~/Scripts
PATH=$PATH:$(ruby -rubygems -e 'puts Gem.user_dir')/bin
# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

export EDITOR='gvim -f'
export VISUAL=${EDITOR}

bindkey "^E" edit-command-line

alias l='ls -lahtr'

function mkcd {
    mkdir -p $@
    cd $@
}

function aux {
    ps -aux | head -n 1
    ps -aux | grep $1 | grep -v "grep $1"
}

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

alias generate-password='pwgen -By1 16'

alias serve-http='python -m http.server'

function update-mirrors {
    sudo reflector --verbose -l 5 --sort rate --save /etc/pacman.d/mirrorlist
}

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
function clean-containers {
    docker rm -f $(docker ps -aq)
}
function clean-images {
    docker rmi -f $(docker images -q)
}

function clean-pyc {
    find -type f -name '*.pyc' -delete
}

function take-screenshot {
    NAME=$(date +%F-%T)
    maim "Screenshots/${NAME}.png"
}
function take-screenshot-of-windows {
    NAME=$(date +%F-%T)
    maim -s -c 1,0,0,0.1 -b 2 "Screenshots/${NAME}.png"
}


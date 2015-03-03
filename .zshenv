# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

setopt interactivecomments

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="custom"

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
PATH=$PATH:~/go/bin

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

bindkey "^Q" edit-command-line
bindkey "^R" history-incremental-pattern-search-backward

function m {
    man $@ &> /dev/null
    if [ "$?" != "0" ]; then
        echo "No manual entry for $*"
    else
        vim -c "SuperMan $*"
    fi
}

# See https://github.com/ogham/exa
unalias l
function l {
    command -v exa &> /dev/null
    if [ "$?" != "0" ]; then
        ls -lahtr $@
    else
        exa -lag -s modified $@
    fi
}

unalias ll
function ll {
    command -v exa &> /dev/null
    if [ "$?" != "0" ]; then
        # No idea why it doesn't sort by default when `-t` for ls is not specified.
        l $@ | sort -k9,9
    else
        exa -lag $@
    fi
}

function mkcd {
    mkdir -p $@
    cd $@
}

function aux {
    ps -aux | head -n 1
    for pid in `pgrep -f $@`;
    do
        ps aux -q $pid | sed -n 2p
    done
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
alias ggr='git grep --break --heading --line-number'
alias gin='git init'
alias glg="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset <%an>' --abbrev-commit --date=relative"
alias gls='git ls-files'
alias gmr='git merge'
alias gmv='git mv'
alias gpu='git push --set-upstream'
alias grm='git rm'
alias grst='git reset'
alias grv='git revert'
alias gs=gst
alias gsh='git stash'
alias gst='git status -sb'
alias gsw='git show'
alias gtg='git tag'
# See https://github.com/jeffkaufman/icdiff
function gdf {
    echo $@
    if [ -f $@ ]; then
        git difftool --no-prompt --extcmd icdiff $@ | less
    else
        git diff $@ | less
    fi
}
function gpl {
    OLD_HASH=$(git rev-parse --short HEAD)
    git pull
    if [[ "${OLD_HASH}" != $(git rev-parse HEAD) ]]; then
        CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
        echo
        echo "${OLD_HASH}..${CURRENT_BRANCH}"
        git --no-pager log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset <%an>' --abbrev-commit --date=relative ${OLD_HASH}..HEAD
    fi
}

alias dpl='docker pull'
alias dcli='docker rmi -f (docker images -q)'
alias dim='docker images'
alias dkl='docker rm -f'
function dlg {
    docker logs $@ 2>&1
}
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

function pip_upgrade {
    pip freeze --local | grep -v '^\-e' | cut -d = -f 1 | xargs sudo pip install -U
}

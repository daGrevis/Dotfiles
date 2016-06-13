# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

setopt interactivecomments

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="custom"

# TODO: It's incorrect to set this.
# TERM=xterm-256color

source ~/settings.sh

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*'   force-list always

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
plugins=(autojump)

source $ZSH/oh-my-zsh.sh

# User configuration

export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/lib/jvm/default/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl"
PATH=$PATH:~/Utils
if hash ruby 2> /dev/null; then
    PATH=$PATH:$(ruby -rubygems -e 'puts Gem.user_dir')/bin
fi
PATH=$PATH:~/go/bin

export HOME_HOSTNAME="haze"
export WORK_HOSTNAME="rx-wks-44"

. ~/Utils/colors.sh

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

export EDITOR='nvim'
export VISUAL=${EDITOR}
export BROWSER=firefox

bindkey "^Q" edit-command-line
bindkey "^R" history-incremental-pattern-search-backward

m() {
    output=$(man $@)
    if [ "$?" != "0" ]; then
        echo -n $output
    else
        vim -c "SuperMan $*"
    fi
}

alias time=/usr/bin/time

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

function f {
    find -name $@
}
function ff {
    find -name "*$@*"
}

function aux {
    ps -aux | head -n 1
    for pid in `pgrep -f $@`;
    do
        ps aux -q $pid | sed -n 2p
    done
}

t() {
    command -v exa &> /dev/null
    if [ "$?" != "0" ]; then
        tree -a -I '.git' $@
    else
        exa -Tal $@
    fi
}

c() {
    awk "{print \$$@}"
}

alias o=xdg-open

g() {
    grep -i $@
}

copy-to-clipboard() {
    echo "${1}" | xclip
    echo "${1}" | xclip -selection c

    echo "Copied..."
    echo "${1}"
}

function vim {
    command -v nvim &> /dev/null
    if [ "$?" != "0" ]; then
        command vim -p $@
    else
        nvim -p $@
    fi
}

alias generate-password="xkcdpass --numwords=10"

alias serve-http='python -m http.server'

function update-mirrors {
    sudo reflector --verbose -l 5 --sort rate --save /etc/pacman.d/mirrorlist
}
pacman-import-gpg-key() {
    # https://wiki.archlinux.org/index.php/Pacman-key#Adding_unofficial_keys
    sudo pacman-key -r $1 && \
        sudo pacman-key --lsign-key $1
}

notify-updates() {
    count=$(checkupdates | wc -l)

    if [ "$count" = "0" ]; then
        return
    fi

    notify-send "New updates" -- "$count update(s)"
}

json-prettify() {
    cat $1 | python -m json.tool |& pygmentize -s -l json
}

alias ccat='pygmentize -g'

get-ip() {
    ip route get 8.8.8.8 | awk '{print $NF; exit}'
    curl -s 'https://api.ipify.org'
    echo
}

function pip_upgrade {
    pip freeze --local | grep -v '^\-e' | cut -d = -f 1 | xargs sudo pip install -U
}

function generate-and-save-password {
    if [ "$#" -ne 1 ]; then
        echo "Usage: generate-and-save-password [ OPTIONS ] [ location (like site or software) ]";
        return
    fi

    loc=$1
    pw=$(generate-password)

    expect <(echo "spawn pass insert -e "${loc}"
                   expect \"Enter password\"
                   send \"${pw}\r\"
                   interact" )

    copy-to-clipboard "${pw}"
}

function show-password {
    pass show $1 | gedit - 2> /dev/null & disown
}

function delete-pyco {
    find -type f -name '*.py[co]' -delete
}

function set-urgent {
    echo -e "\a"
}

function update-fonts {
    fc-cache -vf
}

function remove-broken-symlinks-recursively {
    find -L $@ -type l -delete
}

get-gpg-public-key() {
    gpg --armor --export ${1:-$USER}
}

gpg-encrypt() {
    gpg --encrypt -o $1.gpg $1
}

import-gpg-public-key() {
    gpg --import $@
}

ssh-fingerprint() {
    ssh-keygen -lf ~/.ssh/id_rsa.pub
}

dmenu-go() {
    export FAVFILE=~/sh-commands.fav

    items=$(
        fav ls --only-names;
        echo "$PATH" | tr ":" "\n" | xargs stest -flx | sort -u
    )
    # Filter out duplicated commands without sorting
    items=$(echo "$items" | awk '!x[$0]++')

    selection=$(themenu.sh "$items")

    fav insert "$selection"

    eval "$selection"
}

disable-sreen() {
    xset dpms force off
}

disable-screen-from-sleeping() {
    xset -dpms
}

enable-screen-to-sleep() {
    xset +dpms
}

brightness-dec-by-5() {
    xbacklight -dec 5 -time 0
}

brightness-inc-by-5() {
    xbacklight -inc 5 -time 0
}

volume-dec-by-5() {
    python ~/Utils/change_volume.py "-5"
}

volume-inc-by-5() {
    python ~/Utils/change_volume.py 5
}

volume-toggle() {
    volume_toggle.sh

    notify-send -u low "Volume" -- "Toggling"
}

take-screenshot() {
    name=$(date +%F-%T)
    pth="Screenshots/$name.png" # It doesn't work with ~.

    (cd; maim $pth)

    echo "Saved to ~/$pth"

    notify-send -u low "Taking screenshot of monitor"

    copy-to-clipboard $pth
}
take-screenshot-of-window() {
    name=$(date +%F-%T)
    pth="Screenshots/$name.png" # It doesn't work with ~.

    (cd; maim -s -c 1,0,0,0.1 -b 2 $pth)

    echo "Saved to ~/$pth"

    notify-send -u low "Taking screenshot of window"

    copy-to-clipboard $pth
}

notify-executing() {
    notify-send -u low "Executing..." -- "$1"
}

open-pavucontrol() {
    notify-executing "pavucontrol"

    pavucontrol
}

open-vim() {
    notify-executing "vim"

    termite -e nvim
}

open-mousepad() {
    notify-executing "mousepad"

    mousepad
}

open-firefox() {
    notify-executing "firefox"

    firefox
}

open-firefox-private() {
    notify-executing "firefox -private"

    firefox -private
}

open-chrome() {
    notify-executing "chrome-stable"

    google-chrome-stable
}

open-chrome-incognito() {
    notify-executing "chrome-stable --incognito"

    google-chrome-stable --incognito
}

open-spotify() {
    notify-executing "spotify"

    spotify
}

open-transmission() {
    notify-executing "transmission-gtk"

    transmission-gtk
}

open-ipython() {
    notify-executing "ipython"

    termite -e ipython
}

open-ipython2() {
    notify-executing "ipython2"

    termite -e ipython2
}

open-glances() {
    notify-executing "glances"

    termite -e glances
}

open-ranger() {
    notify-executing "ranger"

    termite -e ranger
}

open-weechat() {
    notify-executing "weechat"

    termite -e weechat
}

check-network() {
    wget -q -T 1 --spider google.com
}

7x() {
    # Unzips archive into an empty directory.
    pth=$1
    pth_no_ext="${pth%.*}"

    mkdir -p $pth_no_ext
    mv $pth "$pth_no_ext/$pth"
    cd $pth_no_ext
    7z x $pth
    l
}

skype2() {
    skype --dbpath=~/.Skype2
}

alias pping="prettyping"

df() {
    colordiff -u $@ | less
}

calm() {
    cal -m $(date +"%Y")
}

show-ports() {
    netstat -tulpn
}

help() {
    apropos . | awk '{print $1}' | selecta | xargs man && clear
}

#
# Git alias.
#

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
function gl {
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
function glg {
    git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' $@
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

#
# Docker alias.
#

alias dpl='docker pull'
alias dim='docker images'
function dlg {
    docker logs $@ 2>&1
}
alias dps='docker ps'
alias dpsa='docker ps -a'
alias drm='docker rm -f'
alias drmi='docker rmi'
alias drs='docker restart'
alias dstp='docker stop'
alias dst='docker start'
function docker-rmcs {
    docker rm -f $(docker ps -aq)
}
function docker-rmis {
    docker rmi -f $(docker images -q)
}

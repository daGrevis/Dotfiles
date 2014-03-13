DEFAULT_USER='dagrevis'

# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME='custom'

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(
    archlinux
    autojump
    bower
    coffee
    encode64
    npm
    pass
    pip
    redis-cli
    systemd
    urltools
    web-search
)

source $ZSH/oh-my-zsh.sh

# Oh-my-zsh creates alias `sl`, but `sl` is a package too!
unalias sl

# Customize to your needs...
PATH=""
PATH+=/usr/local/bin
PATH+=":"
PATH+=/usr/bin
PATH+=":"
PATH+=/bin
PATH+=":"
PATH+=/usr/local/sbin
PATH+=":"
PATH+=/usr/sbin
PATH+=":"
PATH+=/sbin
PATH+=":"
PATH+=/usr/bin/core_perl
PATH+=":"
PATH+=/usr/bin/vendor_perl
PATH+=":"
PATH+=/home/dagrevis/.cabal/bin
PATH+=":"
PATH+=/home/dagrevis/Scripts
PATH+=":"
PATH+=$(ruby -rubygems -e 'puts Gem.user_dir')/bin
export PATH=$PATH

export WORKON_HOME=~/Envs
source /usr/bin/virtualenvwrapper.sh

# Enables autojump.
[[ -s ~/.autojump/etc/profile.d/autojump.zsh ]] && source ~/.autojump/etc/profile.d/autojump.zsh

# Try <C-x><C-e>.
export EDITOR=gvim\ -f

# Bash-like comments.
setopt interactivecomments

# Disables correction.
unsetopt correct_all

# t1=$(gdate +%s.%N)

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

export EDITOR='nvim'
export VISUAL="$EDITOR"

GPG_TTY=`tty`
export GPG_TTY

s=""
s+=":/usr/local/bin"
s+=":/usr/local/opt"
s+=":/opt/local/bin"
s+=":/opt/local/sbin"
s+=":$HOME/.bin"
s+=":$HOME/.node/bin"
s+=":$HOME/.cargo/bin"
s+=":$PATH"
export PATH="$s"

_NVM_DIR=~/.nvm

nvm() {
  unset -f nvm
  export NVM_DIR=$_NVM_DIR
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  nvm "$@"
}

node() {
  unset -f node
  export NVM_DIR=$_NVM_DIR
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  node "$@"
}

npm() {
  unset -f npm
  export NVM_DIR=$_NVM_DIR
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  npm "$@"
}

export ZSH=~/.antigen/repos/https-COLON--SLASH--SLASH-github.com-SLASH-robbyrussell-SLASH-oh-my-zsh.git

ZSH_CUSTOM=~/.oh-my-zsh/custom

ZSH_THEME='custom'

plugins=(autojump)

source $ZSH/oh-my-zsh.sh

source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

ZSH_THEME_TERM_TAB_TITLE_IDLE='$(basename ${PWD/$HOME/"~"})/'

bindkey '^X' edit-command-line

source ~/sh/utils.sh
source ~/sh/git.sh
source ~/sh/docker.sh
source ~/sh/pass.sh

# t2=$(gdate +%s.%N)
# echo $((t2 - t1))

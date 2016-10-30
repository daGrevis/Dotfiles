export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

export EDITOR='nvim'
export VISUAL="$EDITOR"

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

export NVM_DIR=~/.nvm
source ~/.nvm/nvm.sh

nvm use v6 > /dev/null

source /usr/local/share/antigen.zsh

antigen use oh-my-zsh

antigen bundle osx
antigen bundle brew
antigen bundle brew-cask
antigen bundle node
antigen bundle npm
antigen bundle gem
antigen bundle autojump
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-completions src

antigen theme robbyrussell

antigen apply

ZSH_THEME_TERM_TITLE_IDLE='%~'
ZSH_THEME_TERM_TAB_TITLE_IDLE='$(basename ${PWD/$HOME/"~"})/'

WORDCHARS='-._'

zstyle ':completion:*' matcher-list '' \
  'm:{a-z\-}={A-Z\_}' \
  'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
  'r:[[:ascii:]]||[[:ascii:]]=** r:|=* m:{a-z\-}={A-Z\_}'

source ~/sh/utils.sh
source ~/sh/git.sh
source ~/sh/docker.sh
source ~/sh/pass.sh

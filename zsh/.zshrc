# t1=$(gdate +%s.%N)

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

export EDITOR='nvim'
export VISUAL="$EDITOR"

export LESS=-Ri

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
s+=":$HOME/.nvm/versions/node/v12.2.0/bin"
s+=":$PATH"
export PATH="$s"

tm() {
  if [ "$1" = "ls" ]; then
    tmux ls
  elif [ "$1" = "" ]; then
    tmux attach -t "default" || tmux new -s "default"
  else
    tmux new -s "$1" || tmux attach -t "$1"
  fi
}

# Lazy-loaded nvm, node & npm.
NVM_DIR=~/.nvm
NVM_SH="/usr/local/opt/nvm/nvm.sh"

nvm() {
  unset -f nvm
  . $NVM_SH
  nvm "$@"
}

node() {
  unset -f node
  . $NVM_SH
  node "$@"
}

npm() {
  unset -f npm
  . $NVM_SH
  npm "$@"
}

export ZSH=~/.oh-my-zsh

ZSH_CUSTOM=~/.oh-my-zsh/custom

ZSH_THEME='custom'

plugins=(autojump)

source $ZSH/oh-my-zsh.sh

unalias l

ZSH_SYNTAX_HIGHLIGHTING="/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
[ -s "$ZSH_SYNTAX_HIGHLIGHTING" ] && . "$ZSH_SYNTAX_HIGHLIGHTING"

ZSH_THEME_TERM_TAB_TITLE_IDLE='$(basename ${PWD/$HOME/"~"})/'

bindkey '^X' edit-command-line

precmd() {
  if [ -f 'package.json' ] && [ -z "$NVM_DIR" ]; then
    nvm > /dev/null
  fi
}

# gcloud
if [ -f '/Users/dagrevis/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/dagrevis/google-cloud-sdk/path.zsh.inc'; fi
if [ -f '/Users/dagrevis/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/dagrevis/google-cloud-sdk/completion.zsh.inc'; fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export FZF_DEFAULT_OPTS="--bind ctrl-n:next-history,ctrl-p:previous-history,ctrl-r:up,change:top --color=hl+:1,hl:3 --history=$HOME/.fzf_history"

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude ".git"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

alias blender=/Applications/Blender/blender.app/Contents/MacOS/blender

if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

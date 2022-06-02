export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

export EDITOR='nvim'
export VISUAL="$EDITOR"

export PAGER='less'
export LESS='-RXi+gg'
export MANPAGER="nvim -R -c \"execute 'Man ' . \$MAN_PN\" -c 'only' -"
export GIT_PAGER='delta'

GPG_TTY=`tty`
export GPG_TTY

s=""
s+=":/usr/local/bin"
s+=":/usr/local/opt"
s+=":/opt/local/bin"
s+=":/opt/local/sbin"
s+=":$HOME/.cargo/bin"
s+=":$PATH"
export PATH="$s"

# Load env from home-manager home.sessionVariables.
HM_SESSION_VARS_SH="$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
if [ -f $HM_SESSION_VARS_SH ]; then
  source "$HM_SESSION_VARS_SH"
fi

# Load asdf for managing multiple runtime versions of node, ruby and so on.
if [ -z "$ASDF_SH" ]; then
  ASDF_SH="/usr/local/opt/asdf/libexec/asdf.sh"
fi
source "$ASDF_SH"

DISABLE_AUTO_TITLE='true'

export ZSH=~/.oh-my-zsh

ZSH_CUSTOM=~/.oh-my-zsh-custom

ZSH_THEME='custom'

plugins=(autojump)

source $ZSH/oh-my-zsh.sh

unalias l

ZSH_SYNTAX_HIGHLIGHTING="/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
[ -s "$ZSH_SYNTAX_HIGHLIGHTING" ] && . "$ZSH_SYNTAX_HIGHLIGHTING"

ZSH_THEME_TERM_TAB_TITLE_IDLE='$(basename ${PWD/$HOME/"~"})/'

bindkey '^X' edit-command-line

# gcloud
if [ -f '/Users/dagrevis/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/dagrevis/google-cloud-sdk/path.zsh.inc'; fi
if [ -f '/Users/dagrevis/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/dagrevis/google-cloud-sdk/completion.zsh.inc'; fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export FZF_DEFAULT_OPTS="--bind ctrl-n:next-history,ctrl-p:previous-history,ctrl-r:up,change:top --color=hl+:1,hl:3,gutter:0,bg+:0 --history=$HOME/.fzf_history"

command -v fd &> /dev/null
if [ "$?" != "0" ]; then
    export FZF_DEFAULT_COMMAND='find . -type f'
else
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude ".git"'
fi

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

_fzf_compgen_path() {
  command -v fd &> /dev/null
  if [ "$?" != "0" ]; then
      find "$1" -type f
  else
      fd --hidden --follow --exclude ".git" . "$1"
  fi
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  command -v fd &> /dev/null
  if [ "$?" != "0" ]; then
      find "$1" -type d
  else
      fd --type d --hidden --follow --exclude ".git" . "$1"
  fi
}

alias blender=/Applications/blender.app/Contents/MacOS/blender

if [ -z "$TMUX" ]; then
  # Start default tmux session if not already running inside of tmux.
  mux default
fi

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

export EDITOR='nvim'
export VISUAL="$EDITOR"

export PAGER='less'
export LESS='-RXi+gg'
export MANPAGER="nvim -R -c \"execute 'Man ' . \$MAN_PN\" -c 'only' -"
export GIT_PAGER='delta'

export GPG_TTY=`tty`

s=""
s+=":/usr/local/bin"
s+=":/usr/local/opt"
s+=":/opt/local/bin"
s+=":/opt/local/sbin"
s+=":/opt/homebrew/bin"
s+=":$HOME/.cargo/bin"
s+=":$PATH"
export PATH="$s"

# man zshoptions
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE

export HISTSIZE=100000
export SAVEHIST=$HISTSIZE

# Emacs bindings like <C-a> and <C-e>.
bindkey -e

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "$terminfo[kcuu1]" up-line-or-beginning-search
bindkey "$terminfo[kcud1]" down-line-or-beginning-search

autoload -z edit-command-line
zle -N edit-command-line
bindkey '^X' edit-command-line

export RIPGREP_CONFIG_PATH=~/.ripgreprc

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

# Load autojump zsh wrapper.
AUTOJUMP_ZSH="$HOME/.nix-profile/share/autojump/autojump.zsh"
if [ -f $AUTOJUMP_ZSH ]; then
  source "$AUTOJUMP_ZSH"
fi

source ~/theme.sh

source ~/sh/prompt.sh

unalias l

# gcloud
if [ -f '/Users/dagrevis/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/dagrevis/google-cloud-sdk/path.zsh.inc'; fi
if [ -f '/Users/dagrevis/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/dagrevis/google-cloud-sdk/completion.zsh.inc'; fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export FZF_DEFAULT_OPTS="--history=$HOME/.fzf_history \
    --bind ctrl-n:next-history,ctrl-p:previous-history,ctrl-r:up,change:top \
    --color='bg+:$THEME_BG3' --color='pointer:$THEME_WHITE' --color='hl:$THEME_GREEN' \
    --no-separator"

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

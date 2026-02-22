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

setopt AUTO_MENU
setopt ALWAYS_TO_END
setopt COMPLETE_IN_WORD
setopt LIST_PACKED
setopt AUTO_PARAM_KEYS
setopt AUTO_PARAM_SLASH
setopt AUTO_REMOVE_SLASH
setopt INTERACTIVE_COMMENTS

# History.
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE
export HISTSIZE=100000
export SAVEHIST=$HISTSIZE

# Makes the current selection stand out.
zstyle ':completion:*' menu select

# Disables "do you whish to see all possibilities?".
zstyle ':completion:*' list-prompt ''
zstyle ':completion:*' select-prompt ''

# Make capital and small letters the same when auto-completing.
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

autoload -Uz compinit && compinit

# Emacs bindings like <C-a> and <C-e>.
bindkey -e

# Apparently this is needed for $key[Up] and alike binds to work on both Linux and MacOS.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
    autoload -Uz add-zle-hook-widget
    function zle_application_mode_start { echoti smkx }
    function zle_application_mode_stop { echoti rmkx }
    add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
    add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

# Don't count "/" or "." characters as part of word when backward deleting.
my-backward-delete-word() {
    local WORDCHARS="*?_-[]~=&;!#$%^(){}<>"
    zle backward-delete-word
}
zle -N my-backward-delete-word
bindkey '^W' my-backward-delete-word

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "${key[Up]}" up-line-or-beginning-search
bindkey "${key[Down]}" down-line-or-beginning-search

# Enable <S-Tab> to select previous menu completion.
bindkey '^[[Z' reverse-menu-complete

# https://stackoverflow.com/a/41420448/458610
function expand-dots() {
    local MATCH
    if [[ $LBUFFER =~ '(^| )\.\.\.+' ]]; then
        LBUFFER=$LBUFFER:fs%\.\.\.%../..%
    fi
}

function expand-dots-then-expand-or-complete() {
    zle expand-dots
    zle expand-or-complete
}

function expand-dots-then-accept-line() {
    zle expand-dots
    zle accept-line
}

zle -N expand-dots
zle -N expand-dots-then-expand-or-complete
zle -N expand-dots-then-accept-line
bindkey '^I' expand-dots-then-expand-or-complete
bindkey '^M' expand-dots-then-accept-line

autoload -z edit-command-line
zle -N edit-command-line
bindkey '^X' edit-command-line

export RIPGREP_CONFIG_PATH=~/.ripgreprc

# Alias l might or might not exist so try to remove it.
# If it exists, it would be called instead of the function below.
unalias l 2> /dev/null

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

# gcloud
if [ -f '/Users/dagrevis/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/dagrevis/google-cloud-sdk/path.zsh.inc'; fi
if [ -f '/Users/dagrevis/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/dagrevis/google-cloud-sdk/completion.zsh.inc'; fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export FZF_DEFAULT_OPTS="--history=$HOME/.fzf_history \
    --bind ctrl-n:next-history,ctrl-p:previous-history,ctrl-r:up,change:top \
    --color='bg+:$THEME_BG3' --color='pointer:$THEME_WHITE' --color='hl:$THEME_GREEN' \
    --no-separator \
    --cycle"

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

# Git diff via delta. Press r to reload which will update thee diff and keep the scroll postion.
unalias gd 2> /dev/null
gd() {
    local cmd_file="/tmp/.gd-cmd-$$"
    local out_file="/tmp/.gd-out-$$"
    local hist_file="/tmp/.gd-hist-$$"
    local keyfile=$(mktemp)
    echo "git diff --color=always $* | delta --paging=never --width=$COLUMNS" > "$cmd_file"
    printf '#command\nr set-mark a^X\n^X quit r\n' > "$keyfile"
    local start_cmd=""
    while true; do
        sh "$cmd_file" > "$out_file"
        LESSHISTFILE="$hist_file" less --save-marks -R --lesskey-src="$keyfile" ${start_cmd:+"$start_cmd"} "$out_file"
        [ $? -ne 114 ] && break
        local offset=$(awk '/^m a /{print $4}' "$hist_file" | tail -1)
        if [ -n "$offset" ]; then
            local line_num=$(( $(head -c "$offset" "$out_file" | wc -l) + 1 ))
            start_cmd="+${line_num}g"
        fi
    done
    rm -f "$cmd_file" "$out_file" "$hist_file" "$keyfile"
}

alias blender=/Applications/blender.app/Contents/MacOS/blender

# Disable homebrew from auto-updating everything when installing a package.
export HOMEBREW_NO_AUTO_UPDATE=1
# Disable homebrew from hinting the ways it can be configured with env variables.
export HOMEBREW_NO_ENV_HINTS=1

if [ -z "$TMUX" ]; then
  # Start default tmux session if not already running inside of tmux.
  mux default
fi

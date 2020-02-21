# Setup fzf
# ---------
command -v fzf &> /dev/null
if [ "$?" != "0" ]; then
  export PATH="${PATH}:${HOME}/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "${HOME}/.fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "${HOME}/.fzf-bindings.zsh"

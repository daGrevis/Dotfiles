export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

export EDITOR='nvim'
export VISUAL="$EDITOR"

export PAGER='less'
export LESS='-RXi+gg'
export MANPAGER="nvim -R -c \"execute 'Man ' . \$MAN_PN\" -c 'only' -"
export GIT_PAGER='delta'

s=""
s+=":/usr/local/bin"
s+=":/usr/local/opt"
s+=":/opt/local/bin"
s+=":/opt/local/sbin"
s+=":/opt/homebrew/bin"
s+=":$HOME/.local/bin"
s+=":$HOME/.cargo/bin"
s+=":$PATH"
export PATH="$s"

if [ -f ~/.env ]; then
  set -o allexport
  source ~/.env
  set +o allexport
fi

source ~/sh/utils.sh
source ~/sh/git.sh
source ~/sh/docker.sh
source ~/sh/pass.sh
source ~/sh/mux.sh

export RIPGREP_CONFIG_PATH=~/.ripgreprc

# Disable homebrew from auto-updating everything when installing a package.
export HOMEBREW_NO_AUTO_UPDATE=1
# Disable homebrew from hinting the ways it can be configured with env variables.
export HOMEBREW_NO_ENV_HINTS=1

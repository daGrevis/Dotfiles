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

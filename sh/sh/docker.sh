#!/usr/bin/env bash

alias dpl='docker pull'
alias dim='docker images'
dlg() {
    docker logs '$@' 2>&1
}
alias dps='docker ps'
alias dpsa='docker ps -a'
alias drm='docker rm -f'
alias drmi='docker rmi'
alias drs='docker restart'
alias dstp='docker stop'
alias dst='docker start'
docker-rmcs() {
    docker rm -f "$(docker ps -aq)"
}
docker-rmis() {
    docker rmi -f "$(docker images -q)"
}

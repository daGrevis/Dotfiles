#!/usr/bin/env bash

v() {
    session_path="$HOME/.obsessions/$(basename "$PWD").vim"
    if [ -f "$session_path" ] && [ $# -eq 0 ]; then
        ASDF_NODEJS_VERSION=system nvim -S "$session_path"
    else
        ASDF_NODEJS_VERSION=system nvim -p "$@"
    fi
}
alias vim=v
alias vv='ASDF_NODEJS_VERSION=system nvim'
alias vvv='ASDF_NODEJS_VERSION=system nvim -u NORC'

o() {
    if command -v xdg-open; then
      xdg-open "$@"
      return
    fi

    if command -v open; then
      open "$@"
      return
    fi

    return 1
}

alias g='grep -i'

alias serve-http='python3 -m http.server'

l() {
    # https://github.com/eza-community/eza
    command -v eza &> /dev/null
    if [ "$?" != "0" ]; then
        ls -lahtr "$@"
    else
        eza -lag -s modified "$@"
    fi
}

t() {
    # https://github.com/eza-community/eza
    command -v eza &> /dev/null
    if [ "$?" != "0" ]; then
        tree -a -I ".git" "$@"
    else
        eza -aT -I ".git" --level=7 "$@"
    fi
}

mkcd() {
    mkdir -p "$@" && cd "$@"
}

dff() {
    command -v colordiff &> /dev/null
    if [ "$?" != "0" ]; then
        diff -u "$@" | less
    else
        colordiff -u "$@" | less
    fi
}

json-prettify() {
    python -c 'import fileinput, json; print(json.dumps(json.loads("".join(fileinput.input())), indent=2))'
}

generate-password() {
    xkcdpass -d "-"
}

format-json() {
    cat "$@" | python -m json.tool
}

ip-addresses() {
    ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}'

    curl ipecho.net/plain
    echo
}

aux() {
    ps aux | head -n 1
    ps aux | grep -i "$@" | grep -v 'grep -i'
}

auxpid() {
    aux $@ | awk '{print $2}' | tail -n 1
}

alias ka='killall'
alias k9='kill -9'

open-preview() {
    open -a /Applications/Preview.app $@
}

open-chrome() {
    open -a /Applications/Google\ Chrome.app $@
}

s() {
    source .env && echo '.env sourced!'
}

p() {
    command -v prettyping &> /dev/null
    if [ "$?" != "0" ]; then
        ping google.com
    else
        prettyping --nolegend google.com
    fi
}

video-to-gif() {
    FPS="${FPS:-10}"
    SCALE="${SCALE:-640}"
    ffmpeg -i "$@" -vf fps=$FPS,scale=$SCALE:-1:flags=lanczos,palettegen palette.png
    ffmpeg -i "$@" -i palette.png -filter_complex "fps=$FPS,scale=$SCALE:-1:flags=lanczos[x];[x][1:v]paletteuse" recording.gif
    rm palette.png
}

alias dc=cd

port-used() {
    lsof -nP -i4TCP:"$1" | grep LISTEN
}

man() {
    page="$1"
    if [ $# -eq 0 ]; then
        page=$(apropos . | awk '{print $1}' | sort -u | fzf)
    fi
    command man "$page"
}

gg() {
    clear
    tmux clear-history
}

clip() {
  if [ "$(uname)" = "Darwin" ]; then
    pbcopy "$@"
  else
    xclip -f "$@" | xclip -selection clipboard
  fi
}

n() {
  nix-shell --command "SHELL=$SHELL $SHELL" -p "$1"
}

yt2mp3() {
  local output="/mnt/nixos-shared/youtube-dled"
  local url="$1"
  local year="$2"

  if [ -z "$1" ]; then
    echo "No URL"
    return 1
  fi

  if [ -z "$2" ]; then
    echo "No year"
    return 1
  fi

  local working_dir=$(mktemp -d)

  cd "$working_dir"

  yt-dlp --extract-audio --audio-format mp3 --audio-quality 0 \
         --embed-thumbnail \
         --embed-metadata \
         --parse-metadata "youtube\:track\:%(id)s:%(meta_comment)s" \
         --parse-metadata "%(playlist_index)s:%(meta_track)s" \
         --parse-metadata "%(release_year)s:%(meta_year)s" \
         --output "%(album)s/%(artist)s - %(track)s.%(ext)s" \
         "$url"

  # Fixing up the year because YouTube is not reliable.
  for d in */; do
    cd "$d"
    id3v2 --year "$year" *
  done

  mv "$working_dir"/* "$output"

  cd "$output"
}

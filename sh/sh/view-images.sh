#!/bin/sh

# Shows one or more bitmap images in the terminal, e.g.
# "view-images.sh photo.jpg chart.png". The images open in a viewer that holds
# all of them, and h and l (or the arrow keys) step through the list. The list
# is a ring: the step after the last image is the first one.
#
# A terminal with the kitty graphics protocol, for example kitty, gets the
# pixels of the image. The viewer asks the terminal if it has the protocol: it
# sends a query for an image, and then a request for the attributes of the
# terminal. Every terminal answers the request, and a terminal with the
# protocol answers the query before it.
#
# Inside tmux, the question goes to the terminal of the tmux client. tmux
# reads from that terminal itself, and tmux 3.6 types an answer that it does
# not know into the pane in front, as keys. So the viewer has tmux lock the
# client: tmux stops reading, the client runs "view-images.sh --probe" on the
# terminal, and then tmux draws the screen again. The screen is blank for that
# moment, once for each client.
#
# kitten icat, which comes with kitty, sends those pixels. It compresses them,
# and chafa does not: a screenshot that fills the view is about 170 KB from
# icat and 6 MB from chafa, and tmux alone takes more than 0.1 s to pass 6 MB
# on. Inside tmux, icat puts the image in the passthrough sequence of tmux,
# which only the pane of the viewer allows, and puts Unicode placeholders on
# the screen where the image goes. tmux takes the placeholders for text, so the
# image stays in its pane, and it goes and comes back with the pane.
#
# Each image is drawn into a file once for each size of the view, and a step
# only writes that file to the terminal. The images on both sides of the one
# on the screen are drawn in the background, so a step does not wait for a
# decode either.
#
# Every other terminal gets text. Without the kitty graphics protocol, an image
# can only be approximated with text. chafa does that with block characters
# and 24-bit colour, which tmux already carries.
#
# The symbol set is "block+sextant+space". The Block Elements, U+2580 to
# U+259F, cut a cell in four. The sextants, U+1FB00 to U+1FB3B, cut it in six,
# and chafa takes them for about two cells in three. The set leaves out the
# finer wedges (U+1FB3C) and octants (U+1CD00), which chafa also knows.
#
# "--format symbols" is necessary as well: tmux is built with sixel support,
# chafa sees that and sends sixel pixels, which a terminal without sixel
# drops.
#
# chafa reads nine image formats and no more, so a file of any other format,
# for example WebP or BMP, goes through ImageMagick first. Only the first frame
# of an animation is kept.
#
# Inside tmux the viewer goes into a pane of its own, next to the pane that
# called it, so that the images and whatever the caller writes stay on the
# screen together. A pane of its own is also what lets a program that draws a
# whole screen show images: anything written into such a pane is gone on the
# next redraw. The pane is reused, so a second call replaces the images in it
# instead of splitting the window again.
#
# Every tmux command names the calling pane, and none of them go to the window
# that tmux has in front. The images belong to the window the caller is in,
# whichever window the user looks at. A shell splits its own window that way,
# and a program running in a window in the background splits that one.
#
# "view-images.sh --close" closes the pane again, for a caller that opens
# images and has to take them away later.

set -eu

name=${0##*/}
self=$(cd "$(dirname "$0")" && pwd)/$name
work="${TMPDIR:-/tmp}/view-images-$(id -u)"
# The answers of the terminals of tmux clients, one file for each client.
answers="$work-clients"
# The pane this was called from. tmux sets it for every process in a pane, and
# a program that runs another program passes it on.
here=${TMUX_PANE:-}

chafa_options="--format symbols --symbols block+sextant+space --colors full"
chafa_options="$chafa_options --animate off"
# "--fit both" and "--scale-up" fit the image to the view, as "--size" does for
# chafa, and "--loop 0" keeps the first frame of an animation.
kitty_options="--unicode-placeholder --transfer-mode stream --fit both"
kitty_options="$kitty_options --scale-up --align center --loop 0"
kitty_options="$kitty_options --no-trailing-newline --stdin no"
if [ -n "${TMUX:-}" ]; then
  kitty_options="$kitty_options --passthrough tmux"
else
  kitty_options="$kitty_options --passthrough none"
fi

die() {
  echo "$name: $1" >&2
  exit 1
}

# {{{ Viewer

# Answers whether the terminal draws images with the kitty graphics protocol.
# Only a terminal without tmux in between can tell. The terminal answers the
# query for image 31 with "\033_Gi=31;OK\033\\", and the request for its
# attributes with "\033[?...c". The wait stops at the second answer, or after
# 0.5 s without a byte, for a terminal that answers neither.
has_kitty_graphics() {
  printf '\033_Gi=31,s=1,v=1,a=q,t=d,f=24;AAAA\033\\\033[c'
  answer=
  stty min 0 time 5
  while :; do
    part=$(dd bs=64 count=1 2> /dev/null)
    [ -n "$part" ] || break
    answer=$answer$part
    case $answer in *"[?"*c) break ;; esac
  done
  stty min 1 time 0
  case $answer in
    *"_Gi=31;OK"*) return 0 ;;
    *) return 1 ;;
  esac
}

# Answers whether the terminal that shows the viewer has the kitty graphics
# protocol. Outside tmux, the viewer asked the terminal when it started. In
# tmux, that is the terminal of the client that tmux has for the pane, which is
# the client of the session with the most recent key. The answer holds for as
# long as the client runs, so tmux locks a client only once. The pid and the
# start time together name the client, because a pid comes back.
kitty_graphics() {
  if [ -z "${TMUX:-}" ]; then
    [ "$kitty" = yes ]
    return
  fi
  client=$(tmux display-message -p -t "$here" \
    '#{client_name} #{client_pid}-#{client_created} #{client_session}')
  tty=${client%% *}
  # A session without a client has no terminal to ask.
  [ -n "$tty" ] || return 1
  client=${client#* }
  reply=$answers/${client%% *}
  # The lock runs the lock command of the session of the client, which is not
  # always the session of the pane. "=" asks for that exact name, and ":" for
  # the session, not a window.
  session="=${client#* }:"
  if [ ! -s "$reply" ]; then
    mkdir -p "$answers"
    old=$(tmux show-options -qv -t "$session" lock-command)
    if [ -n "$old" ]; then
      set -- set-option -t "$session" lock-command "$old"
    else
      set -- set-option -u -t "$session" lock-command
    fi
    # tmux sends the lock command to the client with the lock, so the option
    # goes back in the same tmux command, and no other lock sees it.
    tmux set-option -t "$session" lock-command "'$self' --probe '$reply'" \; \
      lock-client -t "$tty" \; "$@"
    # A control mode client has no lock. Its answer stays empty, and the next
    # picture asks again.
    tries=0
    while [ ! -s "$reply" ] && [ "$tries" -lt 20 ]; do
      sleep 0.05
      tries=$((tries + 1))
    done
  fi
  [ "$(cat "$reply" 2> /dev/null)" = yes ]
}

# Draws image number $1 into its file in the cache of the view, unless it is
# there already. A background draw and the viewer can draw the same image at
# the same time, so each one writes a file of its own and then moves it into
# place. A file is in the cache whole or not at all.
render() {
  picture=$cache/$1
  [ ! -s "$picture" ] || return 0
  file=$(sed -n "${1}p" "$work/list")
  part=$(mktemp "$picture.XXXXXX")
  if [ "$mode" = symbols ]; then
    # "--align" puts the picture in the middle of the view, and the view is the
    # pane less its last row. chafa aligns to the view and fits to the size, so
    # both have to be given, and chafa writes no more rows than the view holds.
    # The margin at the bottom is chafa's own row to spare, which the row for
    # the status line already is, and two of them put the picture off centre.
    # shellcheck disable=SC2086
    chafa $chafa_options --align mid,mid --margin-bottom 0 \
      --view-size "$box" --size "$box" -- "$file" > "$part" || true
  else
    # icat writes the rows of the image down from the cursor, and only centres
    # them across. The image header tells how many rows there are, as "r=", so
    # the cursor goes first to the row that centres the image in the view.
    # shellcheck disable=SC2086
    kitten icat $kitty_options --use-window-size "$window" -- "$file" \
      > "$part.icat" 2> /dev/null || true
    height=$(head -c 256 "$part.icat" | LC_ALL=C grep -ao ',r=[0-9]*' \
      | head -n 1)
    height=${height#,r=}
    {
      printf '\033[%d;1H' $(((rows - 1 - ${height:-0}) / 2 + 1))
      cat "$part.icat"
    } > "$part"
    rm -f "$part.icat"
  fi
  mv "$part" "$picture"
}

# Paints the current image and, on the last line, which image it is.
draw() {
  size=$(stty size)
  rows=${size% *}
  columns=${size#* }
  # The last row belongs to the status line below.
  box=${columns}x$((rows - 1))
  # kitten comes with kitty, see home.nix. A terminal without it gets text.
  if command -v kitten > /dev/null && kitty_graphics; then
    mode=kitty
    # icat fits the image to a window that it is told about in cells and in
    # pixels, and the window is the view. The pixels change with the size of
    # the pane, so the terminal is asked again only then.
    if [ "$size" != "${measured:-}" ]; then
      pixels=$(kitten icat --print-window-size)
      measured=$size
    fi
    window=$columns,$((rows - 1)),${pixels%x*}
    window=$window,$((${pixels#*x} * (rows - 1) / rows))
    cache=$work/kitty-$window
  else
    mode=symbols
    cache=$work/symbols-$box
  fi
  mkdir -p "$cache"
  render "$index"
  # tmux passes the image on only to the clients of the session of the pane,
  # and kitty draws nothing for a placeholder whose image it never got. With
  # no client there, for example while the user looks at another session, the
  # wait for a key stops every 0.5 s, so that the view can draw the picture
  # again when a client comes.
  clients=1
  if [ "$mode" = kitty ] && [ -n "${TMUX:-}" ]; then
    clients=$(tmux display-message -p -t "$here" '#{session_attached}')
  fi
  if [ "$clients" -eq 0 ]; then stty min 0 time 5; else stty min 1 time 0; fi
  # Home, then erase, so that a picture which is shorter than the pane does not
  # leave the one before it behind.
  printf '\033[H\033[2J'
  cat "$cache/$index"
  label=$(sed -n "${index}p" "$work/names")
  status=" $index/$count  $label   h back   l forward   q quit "
  printf '\033[%d;1H\033[7m%s\033[0m' \
    "$rows" "$(printf '%s' "$status" | cut -c "1-$columns")"
  # The next step goes to one of these two. The input of a background job is
  # /dev/null, so it takes no key from the viewer.
  (
    render $((index % count + 1))
    render $(((index + count - 2) % count + 1))
  ) > /dev/null 2>&1 &
}

# Reads one keypress and prints a name for it. The bytes arrive as hexadecimal,
# because a command substitution cannot hold a null byte or keep a newline.
read_key() {
  key=$(dd bs=1 count=1 2> /dev/null | od -An -tx1 | tr -d ' \n')
  if [ "$key" = 1b ]; then
    # An arrow key is three bytes. A key on its own is one, and the read must
    # not wait for the two that never come, so this read stops after 0.1 s.
    stty min 0 time 1
    key=$key$(dd bs=1 count=2 2> /dev/null | od -An -tx1 | tr -d ' \n')
    stty min 1 time 0
  fi
  case $key in
    6c | 6e | 20 | 1b5b43) echo forward ;;  # l, n, space, right
    68 | 70 | 7f | 1b5b44) echo back ;;     # h, p, backspace, left
    71 | 1b) echo quit ;;                   # q, escape
    *) echo none ;;
  esac
}

view() {
  # wc on macOS pads the number with spaces, and the arithmetic drops them.
  count=$(($(wc -l < "$work/list")))
  index=1
  saved=$(stty -g)
  trap 'trap - WINCH; stty "$saved"; printf "\033[H\033[2J"' EXIT
  # tmux drops a passthrough sequence from a pane that does not allow it, and
  # kitty then gets no image. "on" is not enough: it also drops one while tmux
  # holds back a redraw because the terminal is busy, and a large image keeps
  # the terminal busy. A chunk that is gone breaks the image. The option is for
  # this pane only.
  if [ -n "${TMUX:-}" ]; then
    tmux set-option -p -t "$here" allow-passthrough all
  fi
  # The terminal gives the keys to the viewer one by one, instead of a line at
  # a time, and prints none of them. Output processing stays on, so that the
  # newlines that chafa writes still return the cursor to the first column.
  stty -icanon -echo min 1 time 0
  # The terminal answers once, before the first picture, and the answer holds
  # for the whole call.
  kitty=no
  if [ -z "${TMUX:-}" ] && has_kitty_graphics; then
    kitty=yes
  fi
  # A resize reaches the shell while it waits for the next key, and the picture
  # is drawn for the size it had before, so it is drawn again.
  trap draw WINCH
  draw
  while :; do
    case $(read_key) in
      forward)
        index=$((index % count + 1))
        draw
        ;;
      back)
        if [ "$index" -eq 1 ]; then index=$count; else index=$((index - 1)); fi
        draw
        ;;
      quit) return 0 ;;
      # The wait for a key stopped without one, see draw.
      none)
        if [ "$clients" -eq 0 ] && [ "$(tmux display-message -p -t "$here" \
          '#{session_attached}')" -gt 0 ]; then
          draw
        fi
        ;;
    esac
  done
}

# }}}

# {{{ Files

# Turns a file that chafa cannot read into a PNG that it can, as "to_png FILE
# PNG". "[0]" is the first frame, which is all that a still viewer can show of
# an animation. A file that ImageMagick cannot read either is not an error for
# the whole call, because the caller can be a program that collected the files
# from elsewhere, and one bad file must not hide the good ones.
to_png() {
  converter=$(command -v magick || command -v convert) || {
    echo "$name: $1 needs ImageMagick, which is not installed, see home.nix" >&2
    return 1
  }
  "$converter" "$1[0]" "$2" 2> /dev/null || {
    echo "$name: not an image: $1" >&2
    return 1
  }
}

# Answers whether chafa has a loader for the type. chafa names its loaders in
# "chafa --version", e.g. "PNG" and "SVG", and a media type carries the same
# name in lower case, e.g. "image/png" and "image/svg+xml".
is_loadable() {
  loader=${1#*/}
  loader=${loader%+xml}
  loader=$(echo "$loader" | tr '[:lower:]' '[:upper:]')
  case " $loaders " in
    *" $loader "*) return 0 ;;
    *) return 1 ;;
  esac
}

# }}}

# The pane that holds the images of the calling pane, if there is one. @img
# marks it, and what it holds is the id of the pane that opened it, so that two
# callers in one window keep one image pane each. The option belongs to the
# pane, so it survives a respawn, and list-panes prints an empty second field
# for every other pane. A pane id as the target means the window that pane is
# in, and no other.
image_pane() {
  tmux list-panes -t "$here" -F '#{pane_id} #{@img}' 2> /dev/null \
    | awk -v owner="$here" '$2 == owner { print $1; exit }'
}

if [ "${1:-}" = "--view" ]; then
  view
  exit 0
fi

# "view-images.sh --probe FILE" asks the terminal and writes the answer, yes or
# no, to FILE. A locked tmux client runs it, see kitty_graphics. The terminal
# is the input of the client, and the output can be a pipe, for example when
# ~/sh/mux.js starts the client.
if [ "${1:-}" = "--probe" ]; then
  saved=$(stty -g)
  stty -icanon -echo min 1 time 0
  if has_kitty_graphics >&0; then result=yes; else result=no; fi
  stty "$saved"
  echo "$result" > "$2"
  exit 0
fi

if [ "${1:-}" = "--close" ]; then
  if [ -n "$here" ]; then
    pane=$(image_pane)
    if [ -n "$pane" ]; then
      tmux kill-pane -t "$pane" 2> /dev/null || true
    fi
  fi
  exit 0
fi

[ $# -gt 0 ] || die "usage: $name FILE..."
command -v chafa > /dev/null || die "chafa is not installed, see home.nix"

# One directory for the whole call, emptied first, because the call before this
# one is being replaced and tmux kills its viewer without a goodbye.
rm -rf "$work"
mkdir -p "$work"
: > "$work/list"
: > "$work/names"

loaders=$(chafa --version | sed -n 's/^Loaders: *//p')
given=0
count=0
for file in "$@"; do
  given=$((given + 1))
  case $file in
    /*) path=$file ;;
    # The viewer starts in a directory of its own, so a relative name has to be
    # resolved here, while the directory is still the one the caller was in.
    *) path=$PWD/$file ;;
  esac
  if [ ! -f "$path" ]; then
    echo "$name: no such file: $file" >&2
    continue
  fi
  label=${path##*/}
  if ! is_loadable "$(file --mime-type -b "$path")"; then
    png=$work/$given.png
    to_png "$path" "$png" || continue
    path=$png
  fi
  count=$((count + 1))
  # The name of the file the caller gave, because a converted one has a name
  # that means nothing to the reader.
  echo "$label" >> "$work/names"
  echo "$path" >> "$work/list"
done
[ "$count" -gt 0 ] || die "nothing to show"

if [ -z "${TMUX:-}" ]; then
  # Outside tmux there is no second pane to draw in. A terminal gets the viewer
  # itself, and anything else, for example a pipe, gets the images in a row.
  if [ -t 0 ] && [ -t 1 ]; then
    view
  else
    while IFS= read -r path; do
      # shellcheck disable=SC2086
      chafa $chafa_options -- "$path"
    done < "$work/list"
  fi
  exit 0
fi

command="$self --view"

pane=$(image_pane)
if [ -n "$pane" ]; then
  tmux respawn-pane -k -t "$pane" "$command"
else
  # -d keeps the focus in the pane that called this, which is the pane with the
  # text in it.
  pane=$(tmux split-window -t "$here" -h -l 40% -d -P \
    -F '#{pane_id}' "$command")
  tmux set-option -p -t "$pane" @img "$here"
fi

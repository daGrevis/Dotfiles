#!/bin/sh

# Shows one or more bitmap images in the terminal, e.g.
# "view-images.sh photo.jpg chart.png". The images open in a viewer that holds
# all of them, and h and l (or the arrow keys) step through the list. The list
# is a ring: the step after the last image is the first one.
#
# alacritty draws no bitmaps. It has neither the sixel protocol nor the kitty
# graphics protocol, so an image can only be approximated with text. chafa does
# that with block characters and 24-bit colour, which both alacritty and tmux
# already carry.
#
# The symbol set is "block+sextant+space". The Block Elements, U+2580 to
# U+259F, cut a cell in four. The sextants, U+1FB00 to U+1FB3B, cut it in six,
# and chafa takes them for about two cells in three. The font (Recursive Nerd
# Font) has neither of the two, but alacritty draws both itself, because
# font.builtin_box_drawing is on by default.
#
# Nothing more is added. The wedges at U+1FB3C and the octants at U+1CD00 cut
# the cell finer still, and chafa knows both, but alacritty draws neither, and
# a glyph from the font cannot replace them: a built-in glyph fills a cell of
# "line height + font.offset.y", which is two pixels taller than any glyph the
# font can hold. Every wedge would sit two pixels short of the blocks around
# it.
#
# "--format symbols" is necessary as well: tmux is built with sixel support,
# chafa sees that and sends pixels that alacritty then drops.
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
# The pane this was called from. tmux sets it for every process in a pane, and
# a program that runs another program passes it on.
here=${TMUX_PANE:-}

chafa_options="--format symbols --symbols block+sextant+space --colors full"
chafa_options="$chafa_options --animate off"

die() {
  echo "$name: $1" >&2
  exit 1
}

# {{{ Viewer

# Paints the current image and, on the last line, which image it is.
draw() {
  file=$(sed -n "${index}p" "$work/list")
  size=$(stty size)
  rows=${size% *}
  columns=${size#* }
  # The last row belongs to the status line below.
  box=${columns}x$((rows - 1))
  # Home, then erase, so that a picture which is shorter than the pane does not
  # leave the one before it behind.
  printf '\033[H\033[2J'
  # "--align" puts the picture in the middle of the view, and the view is the
  # pane less its last row. chafa aligns to the view and fits to the size, so
  # both have to be given, and chafa writes no more rows than the view holds.
  # The margin at the bottom is chafa's own row to spare, which the row for the
  # status line above already is, and two of them put the picture off centre.
  # shellcheck disable=SC2086
  chafa $chafa_options --align mid,mid --margin-bottom 0 \
    --view-size "$box" --size "$box" -- "$file" || true
  label=$(sed -n "${index}p" "$work/names")
  status=" $index/$count  $label   h back   l forward   q quit "
  printf '\033[%d;1H\033[7m%s\033[0m' \
    "$rows" "$(printf '%s' "$status" | cut -c "1-$columns")"
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
  count=$(wc -l < "$work/list")
  index=1
  saved=$(stty -g)
  trap 'trap - WINCH; stty "$saved"; printf "\033[H\033[2J"' EXIT
  # The terminal gives the keys to the viewer one by one, instead of a line at
  # a time, and prints none of them. Output processing stays on, so that the
  # newlines that chafa writes still return the cursor to the first column.
  stty -icanon -echo min 1 time 0
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

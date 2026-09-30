#!/bin/sh

# Prints the logo of the OS and the system information from fastfetch below
# it: the NixOS logo on NixOS and the Apple logo on macOS. Other systems get no
# logo.
#
# The output is as wide as the terminal, but 80 columns at most. The
# home-manager build runs ~/Dotfiles/fetch/logos/render.sh, which renders each
# logo into ~/.config/fetch/logos for every output width from 25 to 80
# columns. The logo is the widest one for which the logo and the rows fit in
# the height of the terminal, but at least half as wide as the output, and it
# is centered. An output narrower than 25 columns gets no logo.
#
# The labels start 2 columns from the left edge. The values start in one
# column, so that the longest value ends 2 columns from the right edge. When
# there is not enough space, the values start 1 space after the longest label,
# and a value that does not fit is cut with "…".

if [ -e /etc/NIXOS ]; then
  os=nixos
elif [ "$(uname)" = "Darwin" ]; then
  os=macos
fi

width=$(tput cols)
if [ "$width" -gt 80 ]; then
  width=80
fi

# The default modules of fastfetch, without Packages, which takes about 90 ms
# on NixOS, and without Title, Separator, Break and Colors. With --separator
# '|', fastfetch prints each module as "Label|Value", and --pipe false keeps
# its colors. awk removes the colors from the labels, and keeps the colors in
# the values, for example of the percentages of Memory and Disk. awk adds the
# row "Colors" with circles in the 8 normal colors, and a row without a label
# with circles in the 8 bright colors.
#
# When the longest value does not fit with the labels, all labels lose their
# part in parentheses, for example "Disk (/)" becomes "Disk". A row of circles
# that does not fit shows fewer circles.
#
# LC_ALL=C makes awk count bytes on Linux and macOS alike. len() and cut()
# count characters, because they skip the bytes 0x80 to 0xBF, which continue a
# UTF-8 character, and the color codes.
fastfetch --logo none --pipe false --separator '|' --structure-disabled title:separator:packages:break:colors |
  LC_ALL=C awk -v width="$width" -v height="$(tput lines)" -v logo="${os:+$HOME/.config/fetch/logos/$os}" '
    function plain(s) {
      gsub(/\033\[[0-9;]*m/, "", s)
      return s
    }
    function len(s) {
      s = plain(s)
      gsub(/[\200-\277]/, "", s)
      return length(s)
    }
    function cut(s, n,   i, b, c) {
      for (i = 1; i <= length(s); i++) {
        b = substr(s, i, 1)
        if (b == "\033") {
          i += index(substr(s, i), "m") - 1
        } else if (b !~ /[\200-\277]/ && ++c > n) {
          return substr(s, 1, i - 1)
        }
      }
      return s
    }
    # "\033[m" ends a color of fastfetch, so the ellipsis is not in it.
    function fit(s, n) {
      if (len(s) <= n) {
        return s
      }
      return n > 1 ? cut(s, n - 1) "\033[m…" : ""
    }
    # 8 circles with 1 space between them, 15 columns, or as many as fit in n.
    function circles(sgr, n,   k, c, s) {
      k = int((n + 1) / 2)
      if (k > 8) {
        k = 8
      }
      for (c = 0; c < k; c++) {
        s = s (c ? " " : "") "\033[" sgr c "m●"
      }
      return k > 0 ? s "\033[0m" : ""
    }
    function shorten(s) {
      sub(/ \(.*\)$/, "", s)
      return s
    }
    function widest(short,   i, l, w) {
      for (i = 1; i <= n; i++) {
        l = short ? shorten(label[i]) : label[i]
        if (len(l) + 2 > w) {
          w = len(l) + 2
        }
      }
      return w
    }
    function count(file,   line, k) {
      while ((getline line < file) > 0) {
        k++
      }
      close(file)
      return k
    }
    function add(l, v) {
      n++
      label[n] = l
      value[n] = v
      if (len(v) > values) {
        values = len(v)
      }
    }
    {
      i = index($0, "|")
      add(plain(substr($0, 1, i - 1)), substr($0, i + 1))
    }
    END {
      # sgr is the start of the SGR code for the foreground: 30 to 37 for the
      # normal colors and 90 to 97 for the bright colors.
      add("Colors", "")
      sgr[n] = 3
      add("", "")
      sgr[n] = 9
      if (values < 15) {
        values = 15
      }

      # The logo and the rows must fit with 1 line for the command above them
      # and 1 line for the prompt below them. If no logo fits, it is the
      # narrowest one that is at least half as wide as the output.
      if (logo != "" && width >= 25) {
        least = int((width + 1) / 2) + 4
        if (least < 25) {
          least = 25
        }
        for (x = width; x > least; x--) {
          if (count(logo "-" x ".txt") + n <= height - 2) {
            break
          }
        }
        pad = sprintf("%" int((width - x) / 2) "s", "")
        file = logo "-" x ".txt"
        while ((getline line < file) > 0) {
          print pad line
        }
        close(file)
      }

      room = width - 4
      labels = widest(0)
      short = labels + values > room
      if (short) {
        labels = widest(1)
      }
      start = room - values
      if (start < labels) {
        start = labels
      }
      for (i = 1; i <= n; i++) {
        l = label[i] == "" ? "" : (short ? shorten(label[i]) : label[i]) ":"
        v = sgr[i] ? circles(sgr[i], room - start) : fit(value[i], room - start)
        # The labels are bold and dim, and the values are in the foreground
        # color with the colors of fastfetch. tmux.conf makes dim work in
        # Termius too.
        printf "  \033[1;2m%s\033[0m%" (start - len(l)) "s%s\n", l, "", v
      }
    }
  '

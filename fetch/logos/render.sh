#!/bin/sh

# Renders the logos that ~/sh/fetch.sh prints into the directory in the first
# argument. rsvg-convert draws each SVG as a PNG that is 1600 pixels wide, and
# render.py turns the PNG into one file for each terminal width. It needs
# librsvg and Python with Pillow, which fetch-logos.nix in the home-manager
# directory gives it on each build.

set -e
src=$(dirname "$0")
out=$1
tmp=$(mktemp -d)
mkdir -p "$out"
rsvg-convert -w 1600 -o "$tmp/nixos.png" "$src/nixos.svg"
rsvg-convert -w 1600 -o "$tmp/macos.png" "$src/macos.svg"
python3 "$src/render.py" "$tmp/nixos.png" cells "$out/nixos" 5277c3 7ebae4
python3 "$src/render.py" "$tmp/macos.png" rows "$out/macos" 75bd21 ffc728 ff661c cf0f2b b01cab 00a1de
rm -r "$tmp"

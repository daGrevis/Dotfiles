#!/bin/bash

declare -a pkgs=(
    "ack"
    "bspwm"
    "coffeelint"
    "dunst"
    "editorconfig"
    "firefox"
    "flake8"
    "git"
    "gtk"
    "ipython"
    "lein"
    "mpv"
    "stalonetray"
    "sxhkd"
    "systemd"
    "termite"
    "utils"
    "vim"
    "x"
    "xdg-open"
    "zsh"
)

echo "Going to ~/Dotfiles"
cd ~/Dotfiles

echo
for pkg in "${pkgs[@]}"
do
   stow --ignore=".md" -R "$pkg"
   echo "(Re)stowing $pkg"
done

echo
echo "Going back to..."
cd -

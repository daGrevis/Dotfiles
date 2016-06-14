#!/bin/bash

declare -a pkgs=(
    "ack"
    "bspwm"
    "coffeelint"
    "ctags"
    "dunst"
    "editorconfig"
    "eslint"
    "firefox"
    "flake8"
    "git"
    "gtk"
    "ipython"
    "lein"
    "mpv"
    "neovim"
    "stalonetray"
    "sxhkd"
    "systemd"
    "termite"
    "utils"
    "vim"
    "weechat"
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

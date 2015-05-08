declare -a pkgs=(
    "ack"
    "bspwm"
    "coffeelint"
    "dunst"
    "editorconfig"
    "flake8"
    "git"
    "gtk"
    "ipython"
    "lein"
    "mpv"
    "pentadactyl"
    "sxhkd"
    "utils"
    "vim"
    "x"
    "xdg-open"
    "xfce4-terminal"
    "zsh"
)

echo "Going to ~/Dotfiles"
cd ~/Dotfiles

echo
for pkg in "${pkgs[@]}"
do
   stow -R "$pkg"
   echo "(Re)stowing $pkg"
done

echo
echo "Going back to..."
cd -

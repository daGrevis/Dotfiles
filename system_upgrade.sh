set -e

sudo pacman -Syu --noconfirm
yaourt -Syua --noconfirm
sudo pacman -Rns $(pacman -Qqtd)

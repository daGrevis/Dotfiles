# daGrevis' Dotfiles

This repository contains configuration files for all kinds of software I'm using
on daily basis. Also known as "dotfiles", these files allow to replicate my
setup on another machine with relative ease.

I'm using this to have practically identical setup between:

- MacOS running on MacBook Pro
- NixOS via VirtualBox running on desktop Windows
- Ubuntu running on my private server

## Installation

On both NixOS and MacOS I have Nix and home-manager installed. Then `home.nix`
(in `nix/.config/home-manager`) can be used to manage symlinks, installed
packages and other configuration.

In theory, on a working Nix installation with home-manager installed as a
standalone tool, all you would have to do is to symlink my `nix` configuration
and rebuild the system.

### On NixOS

```sh
sudo ln -s /home/dagrevis/Dotfiles/nix/etc/nixos /etc/nixos
ln -s /home/dagrevis/Dotfiles/nix/.config/nixpkgs /home/dagrevis/.config/nixpkgs
ln -s /home/dagrevis/Dotfiles/nix/.config/home-manager /home/dagrevis/.config/home-manager
```

### On macOS

```sh
ln -s /Users/dagrevis/Dotfiles/nix/.config/nixpkgs /Users/dagrevis/.config/nixpkgs
ln -s /Users/dagrevis/Dotfiles/nix/.config/home-manager /Users/dagrevis/.config/home-manager
```

Then rebuilding the system and user environment should hopefully bring
everything up!

```sh
sudo nixos-rebuild switch --upgrade
home-manager switch
```

In practice, you will probably need to know what you are doing because things
might need some bit of tweaking here and there. :)

Alternatively you can use `stow` to create the symlinks and skip all this fancy
schmancy nix business.

```sh
stow -t ~ -d ~/Dotfiles -v neovim
```

Example above would make symlinks for "neovim" package. All top-level
directories in this repo can be symlinked in this way.

# Dotfiles for my Arch Linux workstation(s)

**So awesome they should be banned!**

## Screenshots

**Warning**: these screenshots show repo state as it was in [189666b](https://github.com/daGrevis/Dotfiles/tree/189666b).

![Clean](https://github.com/daGrevis/Dotfiles/raw/master/Screenshots/dotfiles-clean.png)

![Terminal](https://raw.githubusercontent.com/daGrevis/Dotfiles/master/Screenshots/dotfiles-terminal.png)

![Git](https://raw.githubusercontent.com/daGrevis/Dotfiles/master/Screenshots/dotfiles-using-git.png)

![Vim](https://raw.githubusercontent.com/daGrevis/Dotfiles/master/Screenshots/dotfiles-vim.png)

![Browser](https://raw.githubusercontent.com/daGrevis/Dotfiles/master/Screenshots/dotfiles-browser.png)

## Information

### Fonts used

* "Fira Code 9" for Vim and terminal,
* "Andale Mono 9" for panels and menus,
* "San Francisco Display" for native windows;

## Installation

### Installing Everything

    symlink_everything.sh

### Installing Parts

    stow zsh
    stow vim
    stow ...

### Notes on Some Packages

### Zsh

It needs [robbyrussell/oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh) to
work properly.

    curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh

**NB! When feeling paranoid, check contents of `install.sh` before.**

    git clone https://github.com/robbyrussell/oh-my-zsh
    cd oh-my-zsh
    vim install.sh

    ./install.sh

#### Vim

It needs [gmarik/Vundle.vim](https://github.com/gmarik/Vundle.vim) to manage
plugins.

    git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim

Plugins should be installed and later updated.

    vim +PluginUpdate +qall

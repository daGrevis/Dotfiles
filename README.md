# Dotfiles for my Arch Linux workstation(s)

**So awesome they should be banned!**

## Screenshots

**Warning**: these screenshots show repo state as it was in [189666b](https://github.com/daGrevis/Dotfiles/tree/189666b).

[![](https://i.imgur.com/HWJv59e.jpg)](https://imgur.com/a/zZFbo)
[![](https://i.imgur.com/r42gO7t.png)](https://imgur.com/a/zZFbo)
[![](https://i.imgur.com/D00mKEn.png)](https://imgur.com/a/zZFbo)
[![](https://i.imgur.com/nqO2GbG.png)](https://imgur.com/a/zZFbo)
[![](https://i.imgur.com/JJqjOmy.png)](https://imgur.com/a/zZFbo)
[![](https://i.imgur.com/BS5s9TL.png)](https://imgur.com/a/zZFbo)
[![](https://i.imgur.com/sVXpghM.png)](https://imgur.com/a/zZFbo)

## Stats

### Fonts used

* "Fira Code 9" for Vim and terminal,
* "Andale Mono 9" for panels and menus,
* "San Francisco Display" for native windows;

## Installation

### Installing Everything

    utils/Utils/stow_everything.sh

### Installing Packages

    stow zsh
    stow vim
    stow ...

### Notes on Some Packages

#### Zsh

It needs [robbyrussell/oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh) to
work properly.

    curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh

**NB! When feeling paranoid, check contents of `install.sh` before.**

    git clone https://github.com/robbyrussell/oh-my-zsh
    cd oh-my-zsh
    vim install.sh

    ./install.sh

You may want to set Zsh as the default shell.

    chsh -s /bin/zsh

#### Vim

It needs [junegunn/vim-plug](https://github.com/junegunn/vim-plug) to manage
plugins.

    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

Plugins should be installed and later updated.

    vim +PlugUpdate +qall

#### Firefox

[Pentadactyl add-on](http://5digits.org/home) makes your browser more like Vim!

You may want to compile it yourself to get it working with the latest Firefox.

    git clone https://github.com/5digits/dactyl
    cd dactyl
    make -C pentadactyl install

##### Other Add-ons You Might Enjoy

* [Disconnect](https://addons.mozilla.org/en-us/firefox/addon/disconnect/),
* [HTTPS Everywhere](https://addons.mozilla.org/en-us/firefox/addon/https-everywhere/),
* [JSONView](https://addons.mozilla.org/en-us/firefox/addon/jsonview/),
* [Reddit Enhancement Suite](https://addons.mozilla.org/en-US/firefox/addon/reddit-enhancement-suite/),
* [Self-Destructing Cookies](https://addons.mozilla.org/En-us/firefox/addon/self-destructing-cookies/),
* [YouTube High Definition](https://addons.mozilla.org/En-us/firefox/addon/youtube-high-definition/);

##### Config Flags

    services.sync.enabled;false
    signon.rememberSignons;false

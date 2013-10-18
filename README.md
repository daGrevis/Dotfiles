# Dotfiles for my Arch Linux workstation(s)

**So awesome they should be banned!**

This is how it looked on September 5th, 2013.

![Desktop](https://raw.github.com/daGrevis/Dotfiles/master/desktop.jpg)

## Installation

~~~
# Symlink dirs using GNU Stow.
stow xorg
stow vim
# ...

# For Vim.

git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle

## In Vim:

    :BundleInstall # Install bundles for the first time.
    :BundleUpdate # Update bundles when you feel like it.
~~~

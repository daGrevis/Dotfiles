# Dotfiles for my Arch Linux workstation(s)

**So awesome they should be banned!**

This is how it looked on December 30th, 2013.

![Desktop](https://dl.dropboxusercontent.com/u/3674268/dotfiles.jpg)

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

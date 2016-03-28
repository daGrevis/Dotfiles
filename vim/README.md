# [Dotfiles](https://github.com/daGrevis/Dotfiles)

**Deprecated in favor of [init.vim](github.com/daGrevis/Dotfiles/raw/master/neovim/.config/nvim/init.vim) for Neovim.**

## Vim

It needs [junegunn/vim-plug](https://github.com/junegunn/vim-plug) to manage
plugins.

~~~
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
~~~

Plugins should be installed and later updated.

~~~
vim +PlugUpdate +qall
~~~

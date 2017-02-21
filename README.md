# Dotfiles for my UNIX workstation(s)

This repo uses [GNU Stow](http://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html).

To symlink Neovim dotfiles, run:

```sh
stow -t ~ -d ~/Projects/Dotfiles -v neovim
```

To symlink other things, change that `neovim` part to something else. Extra
setup may be required.

## Neovim

My
[`init.vim`](https://github.com/daGrevis/Dotfiles/blob/master/neovim/.config/nvim/init.vim)
(`.vimrc` replacement for [Neovim](https://neovim.io/)).

Move `init.vim` to `~/.config/nvim/init.vim` with `stow` command.

If you're in a hurry, use `curl` like this:

```sh
curl -Lo ~/.config/nvim/init.vim --create-dirs http://dagrev.is/init.vim
```

After opening the Vim, required plugins will be installed automatically. Restart
the editor to load them!

It's recommended to read `init.vim` line by line and copy paste what's relevant.
The source is heavily documented just for that reason alone.

![Neovim Preview](preview-neovim.png)

## Zsh

Install [`oh-my-zsh`](https://github.com/robbyrussell/oh-my-zsh) by running:

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

(Keep in mind that you're blindly running a random shell-script from the
internet)

Then you'll want to remove `~/.zshrc` that was created by `oh-my-zsh`. Instead
run `stow zsh` to get my [`.zshrc`](https://github.com/daGrevis/Dotfiles/blob/master/zsh/.zshrc).

My setup depends on `sh` scripts so run `stow sh` for that.

![Zsh Preview](preview-zsh.png)

# Asciinema Recordings

[![asciicast](https://asciinema.org/a/bhr88lz6ampal7n9yl43q60zt.png)](https://asciinema.org/a/bhr88lz6ampal7n9yl43q60zt)

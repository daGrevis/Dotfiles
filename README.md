# Dotfiles for my Arch Linux workstation(s)

[Skip to Installation](https://github.com/daGrevis/Dotfiles#installation)

## Screenshots

[![](https://i.imgur.com/HWJv59e.jpg)](https://imgur.com/a/zZFbo)
[![](https://i.imgur.com/r42gO7t.png)](https://imgur.com/a/zZFbo)
[![](https://i.imgur.com/D00mKEn.png)](https://imgur.com/a/zZFbo)
[![](https://i.imgur.com/nqO2GbG.png)](https://imgur.com/a/zZFbo)
[![](https://i.imgur.com/JJqjOmy.png)](https://imgur.com/a/zZFbo)
[![](https://i.imgur.com/BS5s9TL.png)](https://imgur.com/a/zZFbo)
[![](https://i.imgur.com/sVXpghM.png)](https://imgur.com/a/zZFbo)

**Warning**: screenshots above show repo as in [commit 297129a](https://github.com/daGrevis/Dotfiles/tree/297129a).

# Installation

This repo is structured in a way that allows config to be symlinked
by [GNU Stow](https://www.gnu.org/software/stow/) in a super simple yet powerful
way.

Any directory you see in root of this repo can be symlinked like this:

~~~
stow --ignore=".md" vim
~~~

If we assume that `vim/` contains `vim/.vimrc`, running the command above will
link from `~/.vimrc` to `$REPO/vim/.vimrc`.

This works for everything so just "stow" what you want and config should be in
correct place. Be aware that some things may have manual setup described in
`README.md` of that thing (ex. `firefox/README.md`).

Examples:

~~~
# Check https://github.com/daGrevis/Dotfiles/tree/master/vim
stow --ignore=".md" vim
# Check https://github.com/daGrevis/Dotfiles/tree/master/zsh
stow --ignore=".md" zsh

stow --delete vim # But don't...
~~~

If you want everything like I do and fast, try `stow_everything.sh`. It
not a good idea though.

# Other

Fonts used:

* *Inconsolata-g* for Vim and terminal,
* *Andale Mono* for panels and menus,
* *San Francisco Display* for native windows;

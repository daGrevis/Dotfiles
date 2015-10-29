# Dotfiles for my Arch Linux workstation(s)

## Stats

### Fonts Used

* *Inconsolata-g* for Vim and terminal,
* *Andale Mono* for panels and menus,
* *San Francisco Display* for native windows;

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
stow --ignore=".md" zsh
stow --ignore=".md" bspwm

stow --delete bspwm # But don't...
~~~

If you want everything like I do and fast, try `stow_everything.sh`. It
not a good idea though.

## Screenshots

[![](https://i.imgur.com/HWJv59e.jpg)](https://imgur.com/a/zZFbo)
[![](https://i.imgur.com/r42gO7t.png)](https://imgur.com/a/zZFbo)
[![](https://i.imgur.com/D00mKEn.png)](https://imgur.com/a/zZFbo)
[![](https://i.imgur.com/nqO2GbG.png)](https://imgur.com/a/zZFbo)
[![](https://i.imgur.com/JJqjOmy.png)](https://imgur.com/a/zZFbo)
[![](https://i.imgur.com/BS5s9TL.png)](https://imgur.com/a/zZFbo)
[![](https://i.imgur.com/sVXpghM.png)](https://imgur.com/a/zZFbo)

**Warning**: screenshots above show repo as in [commit 297129a](https://github.com/daGrevis/Dotfiles/tree/297129a).

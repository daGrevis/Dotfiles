# [Dotfiles](https://github.com/daGrevis/Dotfiles)

## Zsh

It needs [robbyrussell/oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh) to
work properly.

~~~
curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
~~~

**NB! When feeling paranoid, check contents of `install.sh` before.**

~~~
git clone https://github.com/robbyrussell/oh-my-zsh
cd oh-my-zsh
vim install.sh

./install.sh
~~~

You may want to set Zsh as the default shell.

~~~
chsh -s /bin/zsh
~~~

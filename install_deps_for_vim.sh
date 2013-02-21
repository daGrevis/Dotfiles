#!/bin/bash

DIR='~/.local/share/vim/'
mkdir -p $DIR
mkdir $DIR'swap/'
mkdir $DIR'backup/'
mkdir $DIR'undo/'

curl -Sso ~/.vim/autoload/pathogen.vim https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim

mkdir -p ~/.vim/bundle
cd ~/.vim/bundle
git clone https://github.com/Lokaltog/vim-powerline powerline
git clone https://github.com/tpope/vim-sensible sensible
git clone https://github.com/ervandew/supertab supertab
git clone https://github.com/scrooloose/syntastic syntastic
git clone https://github.com/tpope/vim-commentary commentary
git clone https://github.com/gregsexton/MatchTag matchtag
git clone https://github.com/tpope/vim-surround surround
git clone https://github.com/tpope/vim-fugitive fugitive
git clone https://github.com/scrooloose/nerdtree nerdtree
git clone https://github.com/majutsushi/tagbar tagbar
git clone https://github.com/tpope/vim-repeat repeat
git clone https://github.com/kien/ctrlp.vim ctrlp
git clone https://github.com/mileszs/ack.vim ack

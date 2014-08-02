" Required by Vundle.
set nocompatible
filetype off

" Loads Vundle.
set runtimepath+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Required plugins.
Plugin 'gmarik/Vundle.vim'

" Optional plugins.
Plugin 'Raimondi/delimitMate'
Plugin 'amdt/vim-niji'
Plugin 'chriskempson/base16-vim'
Plugin 'ervandew/supertab'
Plugin 'guns/vim-clojure-static'
Plugin 'guns/vim-sexp'
Plugin 'kien/ctrlp.vim'
Plugin 'mattn/gist-vim'
Plugin 'mattn/webapi-vim'
Plugin 'mileszs/ack.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'scrooloose/syntastic'
Plugin 'sheerun/vim-polyglot'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-fireplace'
Plugin 'tpope/vim-repeat'
Plugin 'tpope/vim-rsi'
Plugin 'tpope/vim-sensible'
Plugin 'tpope/vim-sexp-mappings-for-regular-people'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-unimpaired'

" Required by Vundle.
call vundle#end()
filetype plugin indent on

" Disables swap-files.
set noswapfile

" Show some special chars, well, specially.
set list
set listchars=tab:→\ ,trail:·,nbsp:·

" Sets how indentation works.
set et
set ts=4
set sw=4
set sts=4

" Enables 'g' flag for search by default.
set gdefault

" Ignore case when searching unless you type uppercase and lowercase letters.
set ignorecase
set smartcase

" Highlights line where cursor is.
set cursorline

" Highlights search.
set hlsearch

nmap <silent> n nzzzv
nmap <silent> N Nzzzv

" Set line-numbers to start from 0 based on current position.
set relativenumber

set cryptmethod=blowfish

" Map leader to <Space>.
let mapleader = "\<Space>"

" Mappings for controlling tabs.
nmap <S-j> :tabprevious<CR>
nmap <S-k> :tabnext<CR>

" Maps <M-1> to go to the first tab and so until <M-9>.
let i = 1
while i < 10
    execute 'nmap <M-' . i . '> :tabnext ' . i . '<CR>'
    let i += 1
endwhile

" Mappings for controlling splits.
nmap <M-h> <C-w>h
nmap <M-j> <C-w>j
nmap <M-k> <C-w>k
nmap <M-l> <C-w>l

" Maps Y to yank line from current position til the end.
nmap Y y$

" Joins line as J did.
map <Leader>j :join<CR>

" Wrap-friendly <j> and <k> keys.
nmap j gj
nmap k gk

nmap <Leader>q :wq!<CR>
nmap <Leader>w :w<CR>

nmap <C-e> :edit<Space>
nmap <C-t> :tabedit<Space>

nmap H ^
nmap L $

nmap * *<C-o>

" Copy/pasting from/to system clipboard.
vmap <C-c> "+y
imap <C-v> <S-Insert>
cmap <C-v> <S-Insert>

" Allows to save files as superuser.
func! SudoW()
    exec "w !sudo dd of=%"
    exec "e!"
endfunc
command! SudoW call SudoW()

" Sets color-scheme.
colorscheme slate

if has('gui_running')

    " Sets your fave color-scheme.
    colorscheme base16-default

    " Removes all GUI stuff.
    set guioptions=
    " Removes popups.
    set guioptions+=c

    " Sets font.
    set guifont=Inconsolata-g\ 12px

endif

" Uses ag for faster search.
let g:ackprg = 'ag --nogroup --nocolor --column'

nmap <Leader>a :Ack<Space>
nmap // :Ack<Space><C-r>/

" Linters for Python files.
let g:syntastic_python_checkers = ['python', 'flake8']
let g:syntastic_python_python_exec = 'python2'
let g:syntastic_python_flake8_exec = 'flake8-python2'

" Linters for CoffeeScript files.
let g:syntastic_coffee_checkers = ['coffee', 'coffeelint']
let g:syntastic_coffee_coffeelint_post_args = '--file ~/coffeelint.json'

" Opens NERDTree with <Tab>.
nmap <Tab> :NERDTreeToggle<CR>

" Makes NERDTree more wider.
let NERDTreeWinSize = 50

" Makes NERDTree show hidden files as well.
let NERDTreeShowHidden = 1

" Anonymous gists.
nmap <Leader>pg :Gist -a<CR>
vmap <Leader>pg <ESC>:'<,'>Gist -a<CR>

" Disables mappings in insert mode.
let g:sexp_enable_insert_mode_mappings = 0

" i18n and l10n.
set encoding=utf-8
set fileencodings=utf-8

" General settings.
set ruler
set number
set autoread
set autoindent

" Indentation.
set tabstop=4
set shiftwidth=4
set expandtab

" Appereance.
set background=dark
set t_Co=256
colorscheme molokai
set cursorline
syntax on

" Filetype.
filetype plugin indent on
filetype on

" Disables arrows.
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>
imap <up> <nop>
imap <down> <nop>
imap <left> <nop>
imap <right> <nop>

" Search.
set showmatch
set hlsearch
set wrapscan
set ic

" Pathogen.
call pathogen#infect()

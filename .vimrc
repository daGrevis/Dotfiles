" i18n and l10n.
set encoding=utf-8
set fileencodings=utf-8

" General settings.
set nocompatible
set autoread

" Indentation.
set autoindent
set tabstop=4
set shiftwidth=4
set expandtab
set softtabstop=4
autocmd BufWritePre * :%s/\s\+$//e " Removes all trailing whitespace.

" Appereance.
set number
set background=dark
set t_Co=256
colorscheme molokai
set cursorline
syntax on
set laststatus=2
set colorcolumn=79 " PEP 8.

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
noremap <silent> <c-l> :nohls<cr><c-l>

" Pathogen.
call pathogen#infect()

" Current plugins:
" * Powerline,

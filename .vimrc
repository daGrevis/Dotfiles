" Current plugins:
"
" * Powerline,
" * Supertab,
" * Syntastic,
" * Commentary;
"
" Other depencdencies:
"
" * Common sense,
" * Molokai (color scheme);

" Blank lines for global peace.....








"
" General settings.
"
" Loads plugins in .vim/bundle dir.
call pathogen#infect()
" Needs to be set so other plugins just work.
set nocompatible
" Tells Vim to realod file if it's edited by anyone else. I think that this don't work.
set autoread
" Sets backups and disallows Vim to create garbage-files whereever it likes. Probably this dont' work neither.
set backup
set backupdir=~/.vim/backup
set directory=~/.vim/tmp
" Sets limit of history. Will help if you are morron and don't use version control.
set history=10000
" Detects filetype.
filetype plugin indent on
filetype on
" Sets encoding and stuff. I don't really know.
set encoding=utf-8
set fileencodings=utf-8

"
" Indentation.
"
" Auto indents next line.
set autoindent
" Converts spaces to tabs. Populate all the tabs!
set expandtab
" I guess, it sets tabs to be displayed as four spaces.
set tabstop=4
set shiftwidth=4
" Says that backspace key deletes four spaces at once.
set softtabstop=4
" Deletes all trailing whitespace after save.
autocmd BufWritePre * :%s/\s\+$//e

"
" Appereance.
"
" Shows numbers next-to lines.
set number
" Turns everything very night-ish.
set background=dark
" Enables 256 colors (ye, that's much :D).
set t_Co=256
" Sets fave color schema.
colorscheme molokai
" Highlights line which is active.
set cursorline
" Turns on syntax highlight.
syntax on
" Always show status bar (Powerline here).
set laststatus=2
" Column after which coding is very dangerous.
set colorcolumn=160
" Makes tabline more pleasant.
hi TabLineFill ctermfg=000000

"
" Search.
"
" Highlights all found results.
set hlsearch
" Says to ignore case.
set ic
" Shortcut Ctrl+l clears highlights.
noremap <silent> <C-l> :nohls<cr><C-l>

"
" Other.
"
" Disables arrows. To teach that I must use HJKL combo.
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>
imap <up> <nop>
imap <down> <nop>
imap <left> <nop>
imap <right> <nop>
" Allows to use colon without holding the shift key. People talk that this is good time-saver.
nore ; :
nore , ;
" Adds shortcuts: Alt+l, Alt+h and Alt+t which opens next, previous or new tab.
map <Esc>t :tabnew<CR>
map <Esc>h gT
map <Esc>l gt
" Pastes contents to sprunge.us. Call it with :Share. P.S. Thanks, @laadinjsh!
let s:cmd = system("uname -s | tr -d '\n'") == "Darwin" ? "pbcopy" : "xclip"
exec 'command! -range=% Share :<line1>,<line2>write !curl -sF "sprunge=<-" http://sprunge.us|'.s:cmd
" Flake8 settings.
let g:syntastic_python_checker_args = "--max-line-length=160"
let g:syntastic_check_on_open = 1

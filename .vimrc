" Current plugins:
"
" * Powerline,
" * Supertab,
" * Syntastic,
" * Commentary,
" * Rainbow,
" * MatchTag;
"
" Other depencdencies:
"
" * Common sense,
" * Tomorrow (color scheme);

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
" Shows relative numbers next-to lines. This will make you wanna jump so faaar!
set relativenumber
" Enables 256 colors (ye, that's much :D).
set t_Co=256
" Sets fave color schema.
colorscheme Tomorrow
" Highlights line which is active.
set cursorline
" Turns on syntax highlight.
syntax on
" Always show status bar (Powerline here).
set laststatus=2
" Column after which coding is very dangerous.
set colorcolumn=160
" Sexy tabs. At least... :)
hi TabLineSel ctermbg=31 ctermfg=7

"
" Search.
"
" Shortcut Ctrl+l clears highlights.
noremap <silent> <C-l> :nohls<cr><C-l>
" Fix broken Vim's regexes.
nnoremap / /\v
vnoremap / /\v
" If you search for an all-lowercase string your search will be case-insensitive, but if one or more characters is uppercase the search will be case-sensitive.
set ignorecase
set smartcase
" Always assume that it's global search.
set gdefault
" Highlights all found results as you type in.
set incsearch
set showmatch
set hlsearch

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
" Wrap-friendly Jk-ing. ;D
nnoremap j gj
nnoremap k gk
" Do you know that feeling when unwanted Help opens?
inoremap <F1> <ESC>
nnoremap <F1> <ESC>
vnoremap <F1> <ESC>
" Allows to use colon without holding the shift key. People talk that this is good time-saver.
nore ; :
nore , ;
" Adds shortcuts: Alt+l, Alt+h and Alt+t which opens next, previous or new tab.
map <Esc>t :tabnew<CR>
map <Esc>h gT
map <Esc>l gt
" Allows to switch between numbers and relative numbers with ease. Use Ctrl+n!
function! NumberToggle()
    if(&relativenumber == 1)
        set number
    else
        set relativenumber
    endif
endfunc
nnoremap <C-n> :call NumberToggle()<cr>
" Allows pasting without breaking indent. To paste from anywhere, but Vim, press F12.
set pastetoggle=<F12>
" Pastes contents to sprunge.us. Call it with :Share. P.S. Thanks, @laadinjsh!
let s:cmd = system("uname -s | tr -d '\n'") == "Darwin" ? "pbcopy" : "xclip"
exec 'command! -range=% Share :<line1>,<line2>write !curl -sF "sprunge=<-" http://sprunge.us|'.s:cmd
" Flake8 settings.
let g:syntastic_python_checker_args = "--max-line-length=160"
let g:syntastic_check_on_open = 1
" Fix that sometimes backspace doesn't work.
set bs=2
" Conf for Rainbow plugin.
au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces
" Conf for NERDTree plugin.
nmap <Tab> :NERDTreeToggle<CR>

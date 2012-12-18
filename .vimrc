" Current plugins:
"
" * Powerline,
" * Supertab,
" * Syntastic,
" * Commentary,
" * Rainbow parentheses,
" * MatchTag,
" * Surround,
" * Fugitive,
" * NERDTree,
" * Tagbar,
" * Repeat,
" * CtrlP;
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
" Sets backups and disallows Vim to create garbage-files (.swp, .swp etc.) whereever it likes.
set backup
set backupdir=~/.vim/backup
set directory=~/.vim/tmp
" Needs to be set so other plugins just work.
set nocompatible
" Sets limit of history. Will help if you are morron and don't use version control.
set history=10000
" Detects filetype.
filetype plugin indent on
filetype on
" Sets encoding and stuff. I don't really know.
set encoding=utf-8
set fileencodings=utf-8
" Disables Ex-mode. Dunno what it do, but I don't need it.
map Q <Nop>

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
colorscheme molokai
" Highlights line which is active.
set cursorline
" Turns on syntax highlight.
syntax on
" Always show status bar (Powerline here).
set laststatus=2
" Column after which coding is very dangerous.
set colorcolumn=160
" Sexy tabs. At least... :)
hi TabLine ctermbg=8 ctermfg=7
hi TabLineFill ctermfg=8
hi TabLineSel ctermbg=1 ctermfg=7

"
" Search.
"
" Shortcut Ctrl+l clears highlights.
noremap <silent> <C-l> :nohls<CR><C-l>
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
" Clears highlights.
nnoremap <CR> :noh<CR>

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
" Adds shortcuts: Alt+k, Alt+j and Alt+t which opens next, previous or new tab.
noremap <Esc>t :tabnew<CR>
noremap <Esc>j gT
noremap <Esc>k gt
" Allows to switch between no numbers, numbers and relative numbers with ease. Use Ctrl+n!
function! NumberToggle()
    if(&number == 1)
        set nonumber
    elseif(&relativenumber == 1)
        set number
    else
        set relativenumber
    endif
endfunc
nnoremap <C-n> :call NumberToggle()<CR>
" Allows pasting without breaking indent. To paste from anywhere, but Vim, press F12.
imap <F12> :set invpaste<CR>
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
" Maps Shift to NERDTree.
nmap <Tab> :NERDTreeToggle<CR>
" Maps Shift+Tab to Tagbar.
nmap <S-Tab> :TagbarToggle<CR> :wincmd b<CR>
" Auto sets filetype to HTML for *.html files.
au BufRead *.html set filetype=html
" Disables spell-check by default, but allows to toggle it w/ F2.
set nospell
function! SpellToggle()
    if(&spell == 1)
        set nospell
    else
        set spell
    endif
endfunc
nnoremap <F2> :call SpellToggle()<CR>
noremap <F3> :lnext<CR>
noremap <F4> :lprev<CR>
" Makes margin above and below cursor.
set scrolloff=8
" Ignores files that match ... .
set wildignore=*.pyc
" Getting to beggining or end of the line in command mode like it's in terminal.
cmap <C-a> <Home>
cmap <C-e> <End>
" Saves file when the focus is lost.
autocmd BufLeave,FocusLost * silent! wall
" Maps \+h to MRU split.
noremap \h :CtrlPMRUFiles<CR>
" Maps \+v to saving file and sourcing .vimrc.
nmap <Leader>v :w<CR> :source ~/.vimrc<CR>

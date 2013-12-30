"""
"    ___     ___   ______  _____  ____  _        ___  _____
"    |   \   /   \ |      ||     ||    || |      /  _]/ ___/
"    |    \ |     ||      ||   __| |  | | |     /  [_(   \_
"    |  D  ||  O  ||_|  |_||  |_   |  | | |___ |    _]\__  |
"    |     ||     |  |  |  |   _]  |  | |     ||   [_ /  \ |
"    |     ||     |  |  |  |  |    |  | |     ||     |\    |
"    |_____| \___/   |__|  |__|   |____||_____||_____| \___| by daGrevis
"
"    https://github.com/daGrevis/Dotfiles
"
"""

" Required for Vundle.
set nocompatible
filetype off
set runtimepath+=~/.vim/bundle/vundle/
call vundle#rc()

Bundle 'gmarik/vundle'

Bundle "bling/vim-airline"
Bundle 'Raimondi/delimitMate'
Bundle 'airblade/vim-gitgutter'
Bundle 'austintaylor/vim-indentobject'
Bundle 'bilalq/lite-dfm'
Bundle 'chriskempson/base16-vim'
Bundle 'ervandew/supertab'
Bundle 'flazz/vim-colorschemes'
Bundle 'godlygeek/tabular'
Bundle 'gregsexton/MatchTag'
Bundle 'kchmck/vim-coffee-script'
Bundle 'kien/ctrlp.vim'
Bundle 'kien/rainbow_parentheses.vim'
Bundle 'majutsushi/tagbar'
Bundle 'mattn/emmet-vim'
Bundle 'mhinz/vim-startify'
Bundle 'mileszs/ack.vim'
Bundle 'mitsuhiko/vim-python-combined'
Bundle 'nanotech/jellybeans.vim'
Bundle 'nathanaelkane/vim-indent-guides'
Bundle 'othree/html5.vim'
Bundle 'scrooloose/nerdtree'
Bundle 'scrooloose/syntastic'
Bundle 'sjl/gundo.vim'
Bundle 'suan/vim-instant-markdown'
Bundle 'tpope/vim-abolish'
Bundle 'tpope/vim-commentary'
Bundle 'tpope/vim-fugitive'
Bundle 'tpope/vim-markdown'
Bundle 'tpope/vim-ragtag'
Bundle 'tpope/vim-repeat'
Bundle 'tpope/vim-sensible'
Bundle 'tpope/vim-surround'
Bundle 'tpope/vim-unimpaired'
Bundle 'vim-scripts/VimClojure'
Bundle 'vim-scripts/colorizer'

" Sets fave color scheme.
colorscheme base16-default
set background=dark

" Sets limit of history.
set history=5000

" Shows relative line numbers except for current line.
set relativenumber
set number

" Highlights line which is active.
set cursorline

" Column after which coding is very bad.
set colorcolumn=160

" Fix broken Vim regexes.
nnoremap / /\v
vnoremap / /\v
nnoremap ? ?\v
vnoremap ? ?\v

" Always assume that it's global search and replace.
set gdefault

" Highlights all found results as you type in.
set hlsearch

" Ignore case when searching unless you type uppercase and lowercase letters.
set ignorecase
set smartcase

" Clears highlights for search results.
nnoremap <C-l> :let @/ = ""<CR>

" Wrap-friendly <j> and <k> keys.
nnoremap j gj
nnoremap k gk

" Mappings for controlling tabs.
noremap <M-a> :tabprevious<CR>
noremap <M-s> :tabnext<CR>
noremap <M-1> :tabnext 1<CR>
noremap <M-2> :tabnext 2<CR>
noremap <M-3> :tabnext 3<CR>
noremap <M-4> :tabnext 4<CR>
noremap <M-5> :tabnext 5<CR>
noremap <M-6> :tabnext 6<CR>
noremap <M-7> :tabnext 7<CR>
noremap <M-8> :tabnext 8<CR>
noremap <M-9> :tabnext 9<CR>
noremap <M-0> :tablast<CR>

" Pastes content to pasting service. Works in normal mode (whole buffer) or
" visual mode (selection only).
map <Leader>zz :exec "w !LINK=$(curl -F 'text=<-' 'http://vpaste.net/?nu&ft="
                     \ . &ft . "') && echo -n $LINK \| xclip -i && "
                     \ . "echo -n $LINK \| xclip -i -selection clipboard"<CR>
vmap <Leader>zz <Esc>:exec "'<,'>w !LINK=$(curl -F 'text=<-' "
                           \ . "'http://vpaste.net/?ft=" . &ft . "') && "
                           \ . "echo -n $LINK \| xclip -i && echo -n $LINK \| "
                           \ . "xclip -i -selection clipboard"<CR>

" Maps <S-Tab> to toggling Tagbar.
noremap <S-Tab> :TagbarToggle<CR> :wincmd b<CR>

" Adds word to words list.
noremap <Leader>s+ zg
" Removes word from words list.
noremap <Leader>s- zug
" Finds next bad word.
noremap <Leader>s] ]s
" Finds previous bad word.
noremap <Leader>s[ [s
" Suggest from words list.
noremap <Leader>s? z=

" Fixes some common mistakes in command mode.
cnoremap W w
cnoremap ~w W
cnoremap Q q
cnoremap ~q Q

" Remaps Ex-mode to no-operation.
noremap Q <Nop>

" Ignores files that match these patters.
set wildignore+=*.png
set wildignore+=*.gif
set wildignore+=*.jpeg
set wildignore+=*.jpg
set wildignore+=*.ico
set wildignore+=*.pyc
set wildignore+=*.pyo
set wildignore+=*.db
set wildignore+=*/bin/*
set wildignore+=*/include/*
set wildignore+=*/lib/*
set wildignore+=*/src/*
set wildignore+=*/reports/*
set wildignore+=*/share/*
set wildignore+=*/static/vendor/*
set wildignore+=*/static/compiled/*

" Saves file when the focus is lost (for example, when buffers are changed).
autocmd BufLeave,FocusLost * silent! wall

" Maps <Leader>c to yanking whole file.
nmap <Leader>c ggVGy

" Maps <Leader>v to pasting all over previous file.
nmap <Leader>v ggdG"0PGdd

" Maps <Right> to indenting text to the right, but <Left> to the left. Works
" in nmode and vmode.
nmap <Left> <<
nmap <Right> >>
vmap <Left> <gv
vmap <Right> >gv

" Maps <Up> to spawning blank line above, but <Down> -- below.
nmap <Up> O<Esc>j
nmap <Down> o<Esc>k

" Show some special chars like tab and traling spaces differently.
set list
set listchars=tab:→\ ,trail:·,nbsp:·

" Tells to use 4 spaces for indentation.
set et
set ts=4
set sw=4
set sts=4

" Deletes all trailing whitespace on save.
autocmd BufWritePre * :%s/\s\+$//e

" Disables folding at all.
set nofen

" Emacs ways to change cursor in cmode.
cmap <C-a> <Home>
cmap <C-e> <End>
cmap <M-b> <S-Left>
cmap <M-f> <S-Right>

" Allows to use splits more quickly (Alt-{h,j,k,l,q,w}).
noremap <M-h> <C-w>h
noremap <M-j> <C-w>j
noremap <M-k> <C-w>k
noremap <M-l> <C-w>l
noremap <M-q> <C-w>s
noremap <M-w> <C-w>v

" Open splits in opposite places.
set splitbelow
set splitright

" Allows to quickly set color column using <Leader>cc.
noremap <Leader>cc :set colorcolumn=

" Allows to quickly set filetype using <Leader>ft.
noremap <Leader>ft :set filetype=

" Searches for diff delimiter.
noremap <Leader>d /\v\={4,}\|\<{4,}\|\>{4,}<CR>

" Allows to quickly blame people. I like to do that.....
noremap <Leader>gb :Gblame<CR>

" Allows to save files as superuser.
cmap w!! %!sudo tee > /dev/null %

" If it's Git commit, do some specific actions.
func! SetGitCommitOptions()
    setlocal colorcolumn=80
    setlocal spell
    exec ":0"
endfunc
autocmd Filetype gitcommit call SetGitCommitOptions()

" Simple shortcuts.
noremap <C-e> :edit<Space>
noremap <C-t> :tabedit<Space>

" Jump back to last known cursor position if possible.
autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \     exec "normal g`\"" |
    \ endif

" Allows to quicly switch to the most recently used tab.
let g:lasttab = 1
au TabLeave * let g:lasttab = tabpagenr()
noremap <Space> :exec "tabn ".g:lasttab<CR>

" Saves undo-files in /tmp.
set undodir=/tmp

" Disables swap-files.
set noswapfile

" Enables spellcheck for Markdown.
au BufRead,BufNewFile *.md setlocal spell

" Tells Vim to remember the vertical position.
set nostartofline

" Filesize.
func! GetFilesize()
    let bytes = getfsize(expand("%:p"))
    if bytes <= 0
        return "0"
    endif
    if bytes < 1024
        return bytes
    else
        return (bytes / 1024) . "K"
    endif
endfunc
noremap <Leader>du :echo GetFilesize()<CR>

" Word count
func! GetWordCount()
    return system("cat " . expand("%") . " | wc -w")
endfunc
noremap <Leader>wc :echo GetWordCount()<CR>

" Simple debugging in Python.
noremap <Leader>pd A<CR>from pprint import pprint
                        \<CR>
                        \print("#" * 80)
                        \<CR>
                        \pprint()
                        \<CR>
                        \print("#" * 80)<Esc>k$

" Interactive debugging in Python.
noremap <Leader>ipd A<CR>import ipdb; ipdb.set_trace()<Esc>

" Simple debugging in PHP.
noremap <Leader>hd A<CR><pre>
                        \<CR>
                        \<?php print_r(); ?>
                        \<CR>
                        \</pre><Esc>k$F(

" This awesomeness was removed from Sensible, but don't worry - I have learned
" how to map things and I'm not afraid to use it!
nnoremap & :&&<CR>
noremap Y y$

" Funny these doesn't work automatically anymore.
autocmd FileType python set commentstring=#%s

" Finds non-ASCII.
noremap <Leader>q /\v[^\x00-\x7F]<CR>

" Remaps <C-x> to go out from imode. Weird fix because of Supertab.
autocmd VimEnter * inoremap <C-x> <Esc>

" Opens registers.
noremap <Leader>r :registers<CR>
"
" Opens buffers.
noremap <Leader>b :buffers<CR>

" Fixes coffee not seeing Vim edits.
au BufWritePost *.coffee silent! copen!

" Abbrevs next.
iabbrev teh the
iabbrev fro for

function Custom_jump(motion) range
    let cnt = v:count1
    let save = @/
    mark '
    while cnt > 0
        silent! exe a:motion
        let cnt = cnt - 1
    endwhile
    call histdel('/', -1)
    let @/ = save
endfun

func! ExecuteClojure()
    exec "!lein exec %"
endfun
command! ExecuteClojure call ExecuteClojure()

func! ExecutePython()
    exec "!python %"
endfun
command! ExecutePython call ExecutePython()

" Things related to plugins next.

"
" Ack next.
"

" Opens Ack with default boilerplate.
noremap <Leader>a :Ack  **/*<C-Left><Left>

" Opens Ack in a new tab.
noremap <Leader>ta :tabe \| Ack  **/*<C-Left><Left>

" Searched for a word under the cursor in a new tab.
nnoremap <C-f> yiw:tabe \| Ack <C-r>" **/*

"
" CtrlP next.
"

" Calls MRU.
noremap <C-p> call CtrlPMRU()

" Shows CtrlP on top.
let g:ctrlp_match_window_bottom = 0

"
" DelimitMate next.
"

let delimitMate_nesting_quotes = ["'", '"', '`']

"
" Startify next.
"

" Closes Startify when CtrlP opens a file.
let g:ctrlp_reuse_window = "startify"

let g:startify_show_files_number = 20
let g:startify_bookmarks = [
                         \ "~/.vimrc",
                         \ "~/.xinitrc",
                         \ "~/.Xresources",
                         \ "~/.zshrc",
                         \ "~/.zshenv",
                         \ "~/.xmonad/xmonad.hs",
                         \ "~/.xmobarrc",
                         \ "~/.config/chromium/Default/User StyleSheets/Custom.css",
                         \ "~/.gtkrc-2.0",
                         \ ]

" It says `Vim 7.4` in ASCII art.
let g:startify_custom_header = [
                               \ '   \/||\/| "/.+|',
                               \ '',
                               \ ]

" Doesn't change the directory when going to a file from Startify.
let g:startify_change_to_dir = 0

" Goes back to Startify.
nmap <Backspace> :Startify<CR>

"
" Syntastic next.
"

" Executes Syntastic when buffer is opened.
let g:syntastic_check_on_open = 1

" Allows to use `:lnext` and `:lprevious` to move around Syntastic errors.
let g:syntastic_always_populate_loc_list = 1

" Conf for Python files.
let g:syntastic_python_checkers = ['python', 'pylama']
let g:syntastic_python_pylama_post_args = '-o ~/pylama.ini'

" Conf for CoffeeScript files.
let g:syntastic_coffee_checkers = ['coffee', 'coffeelint']
let g:syntastic_coffee_coffeelint_post_args = '--file ~/coffeelint.json'

"
" GitGutter next.
"

" Disables redraw in real-time.
let g:gitgutter_realtime = 0

" Disables redraw on file read.
let g:gitgutter_eager = 0

"
" NERDTree next.
"

" Maps <S> key to toggling NERDTree.
nmap <Tab> :NERDTreeToggle<CR>

" Ignore files. Can this somehow extend from wildignore?
let NERDTreeIgnore = ['\.pyc$']

"
" Gundo next.
"

" Toggles Gundo.
nmap <Leader>u :GundoToggle<CR>

"
" Indent-guides next.
"

let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_color_change_percent = 2

"
" LiteDFM next.
"

nnoremap <F11> :LiteDFMToggle<CR>

" My Vim shall work in TTY too thanks to control structures.
if has("gui_running")

    " Removes all GUI stuff.
    set guioptions=
    set guioptions+=c " Removes popups.

    " Tells to always use block-style cursor.
    set guicursor=a:block

    " Allows copying/pasting in GVim using <C-c> and <C-p>.
    nmap <C-v> "+gpa<Esc>
    imap <C-v> <Esc><C-v>
    vmap <C-c> "+y
    cmap <C-v> <C-r>*
    " To copy from cmode, type `q:` and copy a command from there.
    " To copy from smode, type `q/` and copy a phrase from there.
    " Pasting into command mode: `<C-r>"`.

    " Enable mouse in all modes.
    set mouse=a

    " Sets font.
    " set guifont=Envy\ Code\ R\ for\ Powerline\ 10
    set guifont=Hermit\ 8

    " I love extra whitespace!
    set linespace=4

    " Fix all the colorschemes at runtime!

    " hornet
    " autocmd ColorScheme * hi TabLine guibg=#303030
    " autocmd ColorScheme * hi TabLineFill guifg=#303030
    " autocmd ColorScheme * hi LineNr guifg=#757575
    " autocmd ColorScheme * hi SignColumn guibg=#303030

    " busybee
    " autocmd ColorScheme * hi TabLine guibg=#202020
    " autocmd ColorScheme * hi TabLine guifg=#e2e2e5
    " autocmd ColorScheme * hi TabLineFill guifg=#202020
    " autocmd ColorScheme * hi SignColumn guibg=#202020
    " autocmd ColorScheme * hi LineNr guifg=#555555

    " luna
    " autocmd ColorScheme * hi TabLineFill guifg=#2e2e2e
    " autocmd ColorScheme * hi TabLine guibg=#2e2e2e
    " autocmd ColorScheme * hi TabLineSel guibg=#474747
    " autocmd ColorScheme * hi SignColumn guibg=#2e2e2e
    " autocmd ColorScheme * hi LineNr guifg=#616161
    " autocmd ColorScheme * hi TODO guibg=#474747
    " autocmd ColorScheme * hi Comment guifg=#616161
    " autocmd ColorScheme * hi Identifier guifg=#ff8036
    " autocmd ColorScheme * hi Function guifg=#ff8036
    " autocmd ColorScheme * hi pythonClass guifg=#ff8036
    " autocmd ColorScheme * hi rubyArrayDelimiter guifg=#ff8036

    " solarized
    " autocmd ColorScheme * hi TODO guibg=#dc322f guifg=#073642
    " autocmd ColorScheme * hi PmenuSel guifg=#b58900

    " solarized light
    " autocmd ColorScheme * hi SignColumn guibg=#eee8d5

    " solarized dark
    " autocmd ColorScheme * hi SignColumn guibg=#073642

    " " base16-tomorrow
    " " #969896 darken by 20%.
    " autocmd ColorScheme * hi Comment guifg=#636563
    " " #969896 darken by 10%.
    " autocmd ColorScheme * hi LineNr guifg=#7d7f7d
    " " Default yellow.
    " autocmd ColorScheme * hi CursorLineNr guifg=#ffff60
    " autocmd ColorScheme * hi StartifySection guifg=#cc6666
    " autocmd ColorScheme * hi StartifyNumber guifg=#f0c674
    " autocmd ColorScheme * hi StartifyBracket guifg=#de935f
    " autocmd ColorScheme * hi Cursor guibg=#de935f

    " base16-default
    autocmd ColorScheme * hi Comment guifg=#505050
    autocmd ColorScheme * hi LineNr guifg=#505050
    autocmd ColorScheme * hi TODO guibg=#ac4142 guifg=#f5f5f5
    " Default yellow.
    autocmd ColorScheme * hi CursorLineNr guifg=#ffff60
    autocmd ColorScheme * hi StartifySection guifg=#ac4142
    autocmd ColorScheme * hi StartifyNumber guifg=#f4bf75
    autocmd ColorScheme * hi StartifyBracket guifg=#d28445
    autocmd ColorScheme * hi Cursor guibg=#f5f5f5

else

    colorscheme default

endif

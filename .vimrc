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

" 9000+ plugins, but still faster than swiftest IDEs!
Bundle 'AndrewRadev/splitjoin.vim'
Bundle 'austintaylor/vim-indentobject'
Bundle 'bling/vim-airline'
Bundle 'cespare/vim-toml'
Bundle 'chriskempson/base16-vim'
Bundle 'editorconfig/editorconfig-vim'
Bundle 'godlygeek/tabular'
Bundle 'gregsexton/MatchTag'
Bundle 'greyblake/vim-preview'
Bundle 'guns/vim-sexp'
Bundle 'honza/vim-snippets'
Bundle 'kien/ctrlp.vim'
Bundle 'lfilho/cosco.vim'
Bundle 'lilydjwg/colorizer'
Bundle 'majutsushi/tagbar'
Bundle 'mattn/emmet-vim'
Bundle 'mattn/gist-vim'
Bundle 'mattn/webapi-vim'
Bundle 'mhinz/vim-signify'
Bundle 'mhinz/vim-startify'
Bundle 'mileszs/ack.vim'
Bundle 'nathanaelkane/vim-indent-guides'
Bundle 'noahfrederick/vim-noctu'
Bundle 'oblitum/rainbow'
Bundle 'Raimondi/delimitMate'
Bundle 'scrooloose/nerdtree'
Bundle 'scrooloose/syntastic'
Bundle 'sheerun/vim-polyglot'
Bundle 'SirVer/ultisnips'
Bundle 'sjl/gundo.vim'
Bundle 'tpope/vim-abolish'
Bundle 'tpope/vim-classpath'
Bundle 'tpope/vim-commentary'
Bundle 'tpope/vim-dispatch'
Bundle 'tpope/vim-fireplace'
Bundle 'tpope/vim-fugitive'
Bundle 'tpope/vim-markdown'
Bundle 'tpope/vim-ragtag'
Bundle 'tpope/vim-repeat'
Bundle 'tpope/vim-rsi'
Bundle 'tpope/vim-sensible'
Bundle 'tpope/vim-sexp-mappings-for-regular-people'
Bundle 'tpope/vim-surround'
Bundle 'tpope/vim-unimpaired'
Bundle 'Valloric/YouCompleteMe'
Bundle 'vim-scripts/gitignore'

" Abbrevs next.
iabbrev teh the
iabbrev fro for

"
" Setters next.
"

" Sets limit of history.
set history=5000

" Shows relative line numbers except for current line.
set relativenumber
set number

" Highlights line which is active.
set cursorline

" Always assume that it's global search and replace.
set gdefault

" Highlights all found results as you type in.
set hlsearch

" Ignore case when searching unless you type uppercase and lowercase letters.
set ignorecase
set smartcase

" Ignores files that match these patterns.
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
set wildignore+=*/static/vendor/*
set wildignore+=*/static/compiled/*

" Show some special chars like tab and trailing spaces differently.
set list
set listchars=tab:→\ ,trail:·,nbsp:·

" Sane defaults for coding styles. Use EditorConfig for language-specific or
" project-specific defaults.
set et
set ts=4
set sw=4
set sts=4

" Disables folding at all.
set nofen

" Open splits in opposite places.
set splitbelow
set splitright

" Saves undo-files in /tmp.
set undodir=/tmp

" Disables swap-files.
set noswapfile

" Adds dictionaries to auto-complete.
set complete+=k

" Adds word-list.
set dictionary+=/usr/share/dict/words

" Auto-complete won't open preview split or whatever.
set completeopt-=preview

" Tells Vim to remember the vertical position.
set nostartofline

" Don't redraw while executing macros.
set lazyredraw

" Sets color-column**s**.
let &colorcolumn="80,".join(range(160,999),",")

"
" Commands next.
"

func! ExecuteClojure()
    exec "!lein exec %"
endfunc
command! ExecuteClojure call ExecuteClojure()

func! ExecutePython()
    exec "!python %"
endfunc
command! ExecutePython call ExecutePython()

" Allows to save files as superuser.
func! SudoW()
    exec "w !sudo dd of=%"
    exec "e!"
endfunc
command! SudoW call SudoW()

"
" Maps next.
"

" Fix broken Vim regexes.
nmap / /\v
vmap / /\v
nmap ? ?\v
vmap ? ?\v
cnoremap s/ s/\v/<Left>

" Clears highlights for search results.
nmap <C-l> :let @/ = ""<CR>

" Wrap-friendly <j> and <k> keys.
nmap j gj
nmap k gk

" Mappings for controlling tabs.
nmap <S-j> :tabprevious<CR>
nmap <S-k> :tabnext<CR>
nmap <M-1> :tabnext 1<CR>
nmap <M-2> :tabnext 2<CR>
nmap <M-3> :tabnext 3<CR>
nmap <M-4> :tabnext 4<CR>
nmap <M-5> :tabnext 5<CR>
nmap <M-6> :tabnext 6<CR>
nmap <M-7> :tabnext 7<CR>
nmap <M-8> :tabnext 8<CR>
nmap <M-9> :tabnext 9<CR>
nmap <M-0> :tablast<CR>

" Fixes some common mistakes in command mode.
nmap :W :w
nmap :Q :q

" Runs macro.
nmap Q @q

" Maps <Right> to indenting text to the right, but <Left> to the left. Works
" in normal mode and visual mode.
nmap <Left> <<
nmap <Right> >>
vmap <Left> <gv
vmap <Right> >gv

" Maps <Up> to spawning blank line above, but <Down> -- below.
nmap <Up> O<Esc>j
nmap <Down> o<Esc>k

" Allows to use splits more quickly (Alt-{h,j,k,l,q,w}).
nmap <M-h> <C-w>h
nmap <M-j> <C-w>j
nmap <M-k> <C-w>k
nmap <M-l> <C-w>l
nmap <M-q> <C-w>s
nmap <M-w> <C-w>v

" Simple shortcuts.
nmap <C-e> :edit<Space>
nmap <C-t> :tabedit<Space>

" This awesomeness was removed from Sensible, but don't worry - I have learned
" how to map things and I'm not afraid to use it!
nmap Y y$

" Maps H and L to jump to the first and the last position of current line.
nmap H ^
nmap L $

" Highlights next found match.
func! HighlightNext (blinktime)
    highlight HighlightNext guibg=#ac4142 guifg=#f5f5f5
    let [bufnum, lnum, col, off] = getpos('.')
    let matchlen = strlen(matchstr(strpart(getline('.'), col - 1), @/))
    let target_pat = '\c\%#'.@/
    let ring = matchadd('HighlightNext', target_pat, 101)
    redraw
    exec 'sleep ' . float2nr(a:blinktime * 400) . 'm'
    call matchdelete(ring)
    redraw
endfunc
nmap <silent> n n:call HighlightNext(0.4)<CR>
nmap <silent> N N:call HighlightNext(0.4)<CR>

" Jump to end of text you pasted.
vnoremap <silent> y y`]
vnoremap <silent> p p`]
nnoremap <silent> p p`]

"
" Leader-maps next.
"

" Map leader to <Space>.
let mapleader = "\<Space>"

" Pastes content to pasting service. Works in normal mode (whole buffer) or
" visual mode (selection only).
map <Leader>zz :exec "w !LINK=$(curl -F 'text=<-' 'http://vpaste.net/?nu&ft="
                     \ . &ft . "') && echo -n $LINK \| xclip -i && "
                     \ . "echo -n $LINK \| xclip -i -selection clipboard"<CR>
vmap <Leader>zz <Esc>:exec "'<,'>w !LINK=$(curl -F 'text=<-' "
                           \ . "'http://vpaste.net/?ft=" . &ft . "') && "
                           \ . "echo -n $LINK \| xclip -i && echo -n $LINK \| "
                           \ . "xclip -i -selection clipboard"<CR>

" Adds word to words list.
nmap <Leader>s+ zg
" Removes word from words list.
nmap <Leader>s- zug
" Finds next bad word.
nmap <Leader>s] ]s
" Finds previous bad word.
nmap <Leader>s[ [s
" Suggest from words list.
nmap <Leader>s? z=

" Maps <Leader>c to yanking whole file.
nmap <Leader>c ggVGy

" Maps <Leader>v to pasting all over previous file.
nmap <Leader>v ggdG"0PGdd

" Allows to quickly set filetype using <Leader>ft.
nmap <Leader>ft :set filetype=

" Allows to quickly set text-width for wrapping using <Leader>tw.
nmap <Leader>tw :set textwidth=

" Searches for diff delimiter.
nmap <Leader>gd /\v\={4,}\|\<{4,}\|\>{4,}<CR>

" Allows to quickly blame people. I like to do that.....
nmap <Leader>gb :Gblame<CR>

" Finds non-ASCII.
nmap <Leader>nasc /\v[^\x00-\x7F]<CR>

" Remove the Windows ^M - when encodings get messed up.
nmap <Leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

" Joins line as J did. I remapped original J to switch to left tab.
map <Leader>j :join<CR>

" Sorts lines.
nmap <Leader>s :%!sort<CR>
vmap <Leader>s :!sort<CR>

" Sources line/selection.
nmap <Leader>x ^vg_y:execute @@<cr>:echo 'Sourced line.'<cr>
vmap <Leader>x y:execute @@<cr>:echo 'Sourced selection.'<cr>

" Simple debugging in Python.
nmap <Leader>pd A<CR>from pprint import pprint
                        \<CR>
                        \print("#" * 80)
                        \<CR>
                        \pprint()
                        \<CR>
                        \print("#" * 80)<Esc>k$

" Interactive debugging in Python.
nmap <Leader>ipd A<CR>import ipdb; ipdb.set_trace()<Esc>

nmap <Leader>w :w<CR>
nmap <Leader>q :wq<CR>

" Allows to quickly switch to the most recently used tab.
let g:lasttab = 1
au TabLeave * let g:lasttab = tabpagenr()
nmap <Leader><Leader> :exec "tabn ".g:lasttab<CR>

"
" Auto-commands next.
"

" Saves file when the focus is lost (for example, when buffers are changed).
autocmd BufLeave,FocusLost * silent! wall

" Deletes all trailing whitespace on save.
autocmd BufWritePre * :%s/\s\+$//e

" Jump back to last known cursor position if possible.
autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \     exec "normal g`\"" |
    \ endif

" Enables niceties for writing text.
autocmd Filetype text,markdown setlocal spell

" If it's Git commit, do some specific actions.
func! SetGitCommitOptions()
    setlocal colorcolumn=80
    setlocal spell
    exec ":0"
endfunc
autocmd Filetype gitcommit call SetGitCommitOptions()

" Funny these doesn't work automatically anymore.
autocmd FileType python set commentstring=#%s

" Fixes coffee not seeing Vim edits.
au BufWritePost *.coffee silent! copen!

" Things related to plugins next.

"
" Ack next.
"

" Shortcut for quicker search.
nmap <Leader>a :Ack<Space>

" Seacrhes for a word under the cursor.
nmap <C-f> :Ack <C-R><C-W><Space>

" Uses ag for faster search.
let g:ackprg = 'ag --nogroup --nocolor --column'

"
" CtrlP next.
"

" Calls MRU.
nmap <C-p> call CtrlPMRU()

" Shows CtrlP on top.
let g:ctrlp_match_window_bottom = 0

" Uses ag for faster search.
let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'

"
" DelimitMate next.
"

let delimitMate_nesting_quotes = ["'", '"', '`']

"
" Startify next.
"

" Closes Startify when NERDTree or CtrlP opens a buffer.
autocmd FileType startify setlocal buftype=

let g:startify_show_files_number = 20
let g:startify_bookmarks = ["~/Dotfiles/", "~/Texts/"]

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

" Linters for Python files.
let g:syntastic_python_checkers = ['python', 'pep8', 'pyflakes']

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

" Maps <Tab> key to toggling NERDTree.
nmap <Tab> :NERDTreeToggle<CR>

" Removes all unnecessary stuff.
let NERDTreeMinimalUI = 1

" Adds arrows for directories.
let NERDTreeDirArrows = 1

" Changes width.
let NERDTreeWinSize = 60

" Shows dotfiles.
let NERDTreeShowHidden = 1

" Respect to wildignore.
func! s:FileGlobToRegexp(glob)
    if a:glob =~# '^\*\.'
        return '\.' . a:glob[2:] . '$'
    else
        return '^' . a:glob . '$'
    endif
endfunc
func! s:SuffixToRegexp(suffix)
    return escape(v:val, '.~') . "$"
endfunc
let g:NERDTreeIgnore =
\   map(split(&wildignore, ','), 's:FileGlobToRegexp(v:val)') +
\   map(split(&suffixes, ','), 's:SuffixToRegexp(v:val)')

"
" Gundo next.
"

" Toggles Gundo.
nmap <Leader>u :GundoToggle<CR>

"
" Indent-guides next.
"

let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_color_change_percent = 4

"
" Rainbow next.
"

" Sensible.vim and Rainbow.vim conflicted. Hack-on!
let g:syntax_on = 1
syntax enable

au FileType lisp,clojure RainbowLoad

"
" Dispatch next.
"

nmap <Leader>d :Dispatch<Space>

"
" Airline next.
"

" Enables tagline, but disables bufferline.
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_buffers = 0

" Shows everything about code tree.
let g:airline#extensions#tagbar#flags = 'f'

" Show number of tab instead of buffer count for each tab.
let g:airline#extensions#tabline#tab_nr_type = 1

"
" Sexps next.
"

" Disables mappings in insert mode.
let g:sexp_enable_insert_mode_mappings = 0

"
" Cosco next.
"

command! CommaOrSemiColon call cosco#commaOrSemiColon()

nmap <Leader>; :call cosco#commaOrSemiColon()<CR>

"
" Tagbar next.
"

" Maps <S-Tab> to toggling Tagbar.
nnoremap <S-Tab> :TagbarToggle<CR> :wincmd b<CR>

"
" Preview next.
"

let g:PreviewBrowsers = 'chromium'

nmap <Leader>pr :Preview<CR>

"
" Splitjoin next.
"

nmap <Leader>ss :SplitjoinSplit<CR>
nmap <Leader>sj :SplitjoinJoin<CR>

"
" Ultisnips next.
"

" Allows YCM to work together with Ultisnips. Expand snippet with <C-Tab>.
let g:UltiSnipsExpandTrigger = '<C-Tab>'
let g:UltiSnipsListSnippets = '<C-S-Tab>'

" My Vim shall work in TTY too thanks to control structures.
if has("gui_running")

    " Sets favourite color scheme.
    colorscheme base16-default
    set background=dark

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
    " To copy from command-mode, type `q:` and copy a command from there.
    " To copy from command-mode, type `q/` and copy a phrase from there.
    " Pasting into command mode: `<C-r>"`.

    " Enable mouse in all modes.
    set mouse=a

    " Sets font.
    " set guifont=Envy\ Code\ R\ for\ Powerline\ 10
    " set guifont=Envypn\ 10
    set guifont=Meslo\ LG\ M\ 9
    " set guifont=Hermit\ 8
    " set guifont=Tamsyn\ 14px

    " I love extra whitespace!
    " set linespace=4

    " Fix all the color schemes at runtime!

    if g:colors_name == "base16-default"

        hi TODO guibg=#ac4142 guifg=#f5f5f5
        " Default yellow.
        hi CursorLineNr guifg=#ffff60
        hi StartifySection guifg=#ac4142
        hi StartifyNumber guifg=#f4bf75
        hi StartifyBracket guifg=#d28445
        hi Cursor guibg=#f5f5f5

    endif

    if g:colors_name == "base16-tomorrow"

        " #969896 darken by 20%.
        hi Comment guifg=#636563
        " #969896 darken by 10%.
        hi LineNr guifg=#7d7f7d
        " Default yellow.
        hi CursorLineNr guifg=#ffff60
        hi StartifySection guifg=#cc6666
        hi StartifyNumber guifg=#f0c674
        hi StartifyBracket guifg=#de935f
        hi Cursor guibg=#e0e0e0

    endif

    if g:colors_name == "base16-bright"

        hi Comment guifg=#b0b0b0
        hi CursorLineNr guifg=#505050

    endif

else

    colorscheme noctu

    " Disables indent-guides.
    let g:indent_guides_auto_colors = 0

endif

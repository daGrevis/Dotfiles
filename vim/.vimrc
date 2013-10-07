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

"Bundle 'altercation/vim-colors-solarized'
"Bundle 'tomasr/molokai'
Bundle 'Raimondi/delimitMate'
Bundle 'airblade/vim-gitgutter'
Bundle 'austintaylor/vim-indentobject'
Bundle 'ervandew/supertab'
Bundle 'godlygeek/tabular'
Bundle 'gregsexton/MatchTag'
Bundle 'itchyny/lightline.vim'
Bundle 'kchmck/vim-coffee-script'
Bundle 'kien/ctrlp.vim'
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

" Sets fave color scheme.
colorscheme jellybeans
" set background=light

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

" Pastes contents to vpaste.net.
map <Leader>zz :exec "w !vpaste.sh ft=".&ft<CR>
vmap <Leader>zz <ESC>:exec "'<,'>w !vpaste.sh ft=".&ft<CR>

" Maps <S-Tab> to toggling Tagbar.
noremap <S-Tab> :TagbarToggle<CR> :wincmd b<CR>

" Disables spell-check by default, but allows to toggle with a function.
set nospell
function! SpellToggle()
    if(&spell == 1)
        set nospell
    else
        set spell
    endif
endfunc

" Maps <Leader>s to toggling spell-check.
noremap <Leader>ss :call SpellToggle()<CR>

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
" in mode and vmode.
nmap <Left> <<
nmap <Right> >>
vmap <Left> <gv
vmap <Right> >gv

" Maps <Up> to spawning blank line above, but <Down> -- below.
nmap <Up> O<Esc>j
nmap <Down> o<Esc>k

" Maps <Leader>l to toggling characters that are not printable (like new-lines
" or tabs).
set list
set listchars=tab:→\ ,trail:·,nbsp:·

" Tells to use 4 spaces for indentation.
set et
set ts=4
set sw=4
set sts=4

" Deletes all trailing whitespace on save.
autocmd BufWritePre * :%s/\s\+$//e

" Enable mouse in all modes. Next line makes me a bad person.
set mouse=a

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

" Searches for diff delimeter.
noremap <Leader>d /\v\={4,}<CR>

" Allows to quickly blame people. I like to do it.....
noremap <Leader>gb :Gblame<CR>

" Allows to save files w/ superuser permissions.
cmap w!! %!sudo tee > /dev/null %

" If it's Git commit, do some specific ations.
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

" Allows to switch to last used tab with <Space><Space>.
let g:lasttab = 1
au TabLeave * let g:lasttab = tabpagenr()
noremap <Space> :exec "tabn ".g:lasttab<CR>

" Saves undo-files in /tmp.
set undodir=/tmp

" Disables swap-files.
set noswapfile

" Enables spellcheck for Markdown.
au BufRead,BufNewFile *.md setlocal spell

" Tells Vim to remember the vertical postion.
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
                        \print("#" * 80)<Esc>k

" This awesomeness was removed from Sensible, but don't worry - I have learned
" how to map things and I'm not afraid to use it!
nnoremap & :&&<CR>
noremap Y y$

" Funny these doesn't work automatically anymore.
autocmd FileType python set commentstring=#%s

" Enables spell-check in imode.
au InsertEnter * setlocal spell
au InsertLeave * setlocal nospell

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

" 42.
nnoremap <Leader>42 :help 42<CR>

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

noremap <C-p> call CtrlPMRU()

" Shows CtrlP on top.
let g:ctrlp_match_window_bottom = 0

"
" DelimitMate next.
"

let delimitMate_nesting_quotes = ["'", '"', '`']

"
" Lightline next.
"

let g:lightline = {
      \ 'colorscheme': 'jellybeans',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ], [ 'fugitive', 'filename' ], ['ctrlpmark', 'tagbar'] ],
      \   'right': [ [ 'syntastic', 'lineinfo' ], ['percent'], [ 'fileformat', 'fileencoding', 'filetype' ] ]
      \ },
      \ 'component_function': {
      \   'fugitive': 'MyFugitive',
      \   'filename': 'MyFilename',
      \   'fileformat': 'MyFileformat',
      \   'filetype': 'MyFiletype',
      \   'fileencoding': 'MyFileencoding',
      \   'mode': 'MyMode',
      \   'ctrlpmark': 'CtrlPMark',
      \ },
      \ 'component_expand': {
      \   'syntastic': 'SyntasticStatuslineFlag',
      \ },
      \ 'component_type': {
      \   'syntastic': 'error',
      \ },
      \ 'separator': { 'left': '⮀', 'right': '⮂' },
      \ 'subseparator': { 'left': '⮁', 'right': '⮃' },
      \ 'component': {
      \   'tagbar': '%{tagbar#currenttag("[%s]", "", "f")}',
      \ },
      \ }

function! MyModified()
  return &ft =~ 'help\|vimfiler\|gundo' ? '' : &modified ? '+' : &modifiable
         \ ? '' : '-'
endfunction

function! MyReadonly()
  return &ft !~? 'help\|vimfiler\|gundo' && &ro ? '<U+2B64>' : ''
endfunction

function! MyFilename()
  let fname = expand('%:t')
  return fname == 'ControlP' ? g:lightline.ctrlp_item :
        \ fname == '__Tagbar__' ? g:lightline.fname :
        \ fname =~ '__Gundo\|NERD_tree' ? '' :
        \ &ft == 'vimfiler' ? vimfiler#get_status_string() :
        \ &ft == 'unite' ? unite#get_status_string() :
        \ &ft == 'vimshell' ? vimshell#get_status_string() :
        \ ('' != MyReadonly() ? MyReadonly() . ' ' : '') .
        \ ('' != fname ? fname : '[No Name]') .
        \ ('' != MyModified() ? ' ' . MyModified() : '')
endfunction

function! MyFugitive()
  try
    if expand('%:t') !~? 'Tagbar\|Gundo\|NERD' && &ft !~? 'vimfiler' && exists('*fugitive#head')
      let mark = '⭠ '
      let _ = fugitive#head()
      return strlen(_) ? mark._ : ''
    endif
  catch
  endtry
  return ''
endfunction

function! MyFileformat()
  return winwidth(0) > 70 ? &fileformat : ''
endfunction

function! MyFiletype()
  return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype : 'no ft') : ''
endfunction

function! MyFileencoding()
  return winwidth(0) > 70 ? (strlen(&fenc) ? &fenc : &enc) : ''
endfunction

function! MyMode()
  let fname = expand('%:t')
  return fname == '__Tagbar__' ? 'Tagbar' :
        \ fname == 'ControlP' ? 'CtrlP' :
        \ fname == '__Gundo__' ? 'Gundo' :
        \ fname == '__Gundo_Preview__' ? 'Gundo Preview' :
        \ fname =~ 'NERD_tree' ? 'NERDTree' :
        \ &ft == 'unite' ? 'Unite' :
        \ &ft == 'vimfiler' ? 'VimFiler' :
        \ &ft == 'vimshell' ? 'VimShell' :
        \ winwidth(0) > 60 ? lightline#mode() : ''
endfunction

function! CtrlPMark()
  if expand('%:t') =~ 'ControlP'
    call lightline#link('iR'[g:lightline.ctrlp_regex])
    return lightline#concatenate([g:lightline.ctrlp_prev, g:lightline.ctrlp_item
          \ , g:lightline.ctrlp_next], 0)
  else
    return ''
  endif
endfunction

let g:ctrlp_status_func = {
  \ 'main': 'CtrlPStatusFunc_1',
  \ 'prog': 'CtrlPStatusFunc_2',
  \ }

function! CtrlPStatusFunc_1(focus, byfname, regex, prev, item, next, marked)
  let g:lightline.ctrlp_regex = a:regex
  let g:lightline.ctrlp_prev = a:prev
  let g:lightline.ctrlp_item = a:item
  let g:lightline.ctrlp_next = a:next
  return lightline#statusline(0)
endfunction

function! CtrlPStatusFunc_2(str)
  return lightline#statusline(0)
endfunction

let g:tagbar_status_func = 'TagbarStatusFunc'

function! TagbarStatusFunc(current, sort, fname, ...) abort
    let g:lightline.fname = a:fname
  return lightline#statusline(0)
endfunction

augroup AutoSyntastic
  autocmd!
  autocmd BufWritePost * call s:syntastic()
augroup END
function! s:syntastic()
  SyntasticCheck
  call lightline#update()
endfunction

let g:unite_force_overwrite_statusline = 0
let g:vimfiler_force_overwrite_statusline = 0
let g:vimshell_force_overwrite_statusline = 0

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
                         \ ]

" It says `Vim 7.4` in ASCII art.
let g:startify_custom_header = [
                               \ '   \/||\/| "/.+|',
                               \ '',
                               \ ]

let g:startify_custom_footer = [''] + map(split(system('fortune | cowsay -f tux.cow'), '\n'), '"   ". v:val') + ['','']

" Doesn't change the directory when going to a file from Startify.
let g:startify_change_to_dir = 0

" Goes back to Startify.
nmap <Backspace> :Startify<CR>

"
" Syntastic next.
"

" Executes Syntastic when buffer is opened.
let g:syntastic_check_on_open = 1

" Tells Syntastic to set line length to 160 symbols as maximum.
let g:syntastic_python_flake8_post_args = "--max-line-length=160"

" Allows to use `:lnext` and `:lprevious` to move around Syntastic errors.
let g:syntastic_always_populate_loc_list = 1

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

"
" Gundo next.
"

" Toggles Gundo.
nmap <Leader>u :GundoToggle<CR>

"
" Indent-guides next.
"

let g:indent_guides_enable_on_vim_startup = 1

" My Vim shall work in terminal too thanks to control structures.
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

else

    colorscheme default

    let g:lightline = {
        \ 'separator': { 'left': '|', 'right': '|' },
        \ 'subseparator': { 'left': '|', 'right': '|' }
        \ }

endif

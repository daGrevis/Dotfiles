" Required by Vundle.
set nocompatible
filetype off

" Loads Vundle.
set runtimepath+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" TODO: Neobundle looks very promising, need to check it out.

" Required plugins.
Plugin 'gmarik/Vundle.vim'

" Optional plugins.
Plugin 'Raimondi/delimitMate'
Plugin 'Z1MM32M4N/vim-superman'
Plugin 'amdt/vim-niji'
Plugin 'ervandew/supertab'
Plugin 'guns/vim-clojure-static'
Plugin 'haya14busa/incsearch.vim'
Plugin 'itchyny/lightline.vim'
Plugin 'kien/ctrlp.vim'
Plugin 'mattn/gist-vim'
Plugin 'mattn/webapi-vim'
Plugin 'mileszs/ack.vim'
Plugin 'morhetz/gruvbox'
Plugin 'scrooloose/nerdtree'
Plugin 'scrooloose/syntastic'
Plugin 'sheerun/vim-polyglot'
Plugin 'terryma/vim-expand-region'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-eunuch'
Plugin 'tpope/vim-fireplace'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-repeat'
Plugin 'tpope/vim-rsi'
Plugin 'tpope/vim-sensible'
Plugin 'tpope/vim-sleuth'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-unimpaired'
Plugin 'vim-scripts/gitignore'
Plugin 'wellle/targets.vim'

" Required by Vundle.
call vundle#end()
filetype plugin indent on

" Disables swap-files.
set noswapfile

" Show some special chars, well, specially.
set list
set listchars=tab:→\ ,trail:·,nbsp:·

" Enables 'g' flag for search by default.
set gdefault

" Ignore case when searching unless you type uppercase and lowercase letters.
set ignorecase
set smartcase

" Highlights line where cursor is.
set cursorline

" Highlights search.
set hlsearch

" Highlights next found match.
func! HighlightNext (blinktime)
    highlight HighlightNext guibg=#fb4934
    let [bufnum, lnum, col, off] = getpos('.')
    let matchlen = strlen(matchstr(strpart(getline('.'), col - 1), @/))
    let target_pat = '\c\%#'.@/
    let ring = matchadd('HighlightNext', target_pat, 101)
    redraw
    exec 'sleep ' . float2nr(a:blinktime * 400) . 'm'
    call matchdelete(ring)
    redraw
endfunc
nmap <silent> n n:call HighlightNext(0.2)<CR>
nmap <silent> N N:call HighlightNext(0.2)<CR>

" Set line-numbers to start from 0 based on current position.
set relativenumber

set cryptmethod=blowfish2

set colorcolumn=100
set textwidth=100

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

" Allows to switch back to tab you were before.
let g:last_tab = 1
nmap <Space><Space> :execute "tabn " . g:last_tab<CR>
au TabLeave * let g:last_tab = tabpagenr()

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
nmap <M-q> :q!<CR>

nmap <C-e> :e<Space>
nmap <C-t> :tabe<Space>

nmap H ^
vmap H ^
nmap L $
vmap L $

nmap * *<C-o>
nmap # #<C-o>

" Default Q is very annoying. Maps it to something useful.
nmap Q @q

" TODO: What should I do know?
nmap <C-q> <Nop>

" Reselect text when indenting.
vmap < <gv
vmap > >gv

" Sane regexes (aka very magic).
cnoremap s/ s/\v
cnoremap %s/ %s/\v

" Indent all the things!
nmap + gg=G2<C-o>

" Copy/pasting from/to system clipboard.
vmap <C-c> "+y
nmap <C-v> "*p
cmap <C-v> <C-r>+

" Auto-closes that window when using q: instead of :q for mistake.
map q: :q

" Word suggestions for typos.
map <Leader>z :set spell<CR>z=

au filetype python setlocal makeprg=python\ %
au filetype clojure setlocal makeprg=lein\ exec\ %

" Sets color-scheme.
colorscheme slate

if has('gui_running')

    " Sets your fave color-scheme.
    colorscheme gruvbox

    " Removes all GUI stuff.
    set guioptions=c

    " Sets font.
    set guifont=Fira\ Code\ 9

endif

nmap <Leader>a :Ack<Space>
nmap // :<C-r>/<Backspace><Backspace><C-a><Right><Right><Backspace><Backspace>Ack<Space>

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

" Use Git to get files. Much faster and it respects .gitignore rules.
let g:ctrlp_user_command = [
            \ '.git/',
            \ 'git --git-dir=%s/.git ls-files -oc --exclude-standard'
            \ ]

" Searches in files, buffers and MRU files at the same time.
let g:ctrlp_cmd = 'CtrlPMixed'

" Don't reload CtrlP cache when opening file outside project.
let g:ctrlp_working_path_mode = 'r'

let g:ctrlp_match_window = 'bottom,order:btt,min:1,max:20,results:20'

" Incremental search.
map / <Plug>(incsearch-forward)\v
map ? <Plug>(incsearch-backward)\v

" Improved selecting in visual mode.
vmap v <Plug>(expand_region_expand)
vmap <S-v> <Plug>(expand_region_shrink)

" Improved yanking/pasting.
vnoremap <silent> y y`]
vnoremap <silent> p p`]
nnoremap <silent> p p`]

" Type 123<CR> to go to 123rd line.
nnoremap <CR> G
nnoremap <BS> gg

" Installs vim-plug along with all plugins in case plugin manager isn't installed.
"
" This allows to replicate my Vim setup by simply copying init.vim into the
" right place. This can be done with a simple one-liner as shown below.
"     curl -Lo ~/.config/nvim/init.vim --create-dirs https://github.com/daGrevis/Dotfiles/raw/master/neovim/.config/nvim/init.vim
if empty(glob('~/.config/nvim/autoload/plug.vim'))
    silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://github.com/junegunn/vim-plug/raw/master/plug.vim

    function! AuPlugged()
        exe ':PlugInstall'
        echo 'Plugins installed, **restart Neovim to load them**!'
    endfunction
    augroup AuPlugged
        autocmd!
        autocmd VimEnter * call AuPlugged()
    augroup END
endif

call plug#begin('~/.config/nvim/plugged')

" Commenting.
Plug 'tpope/vim-commentary'

" UNIX helpers.
Plug 'tpope/vim-eunuch'

" Hooks for 3rd party repeat support.
Plug 'tpope/vim-repeat'

" Surround text-objects.
Plug 'tpope/vim-surround'

" Bracket mappings.
Plug 'tpope/vim-unimpaired'

" Diff via sign column.
Plug 'mhinz/vim-signify'

" Marks via sign column.
Plug 'kshenoy/vim-signature'

" Highlight all matching patterns.
Plug 'haya14busa/incsearch.vim'

Plug 'vim-utils/vim-husk'
Plug 'Raimondi/delimitMate'
Plug 'ervandew/supertab'
Plug 'bronson/vim-visual-star-search'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'scrooloose/nerdtree'
Plug 'mileszs/ack.vim'
Plug 'benekastah/neomake'
Plug 'majutsushi/tagbar'
Plug 'AndrewRadev/splitjoin.vim'
Plug 'rhysd/devdocs.vim'
Plug 'justinmk/vim-sneak'
Plug 'wellle/targets.vim'

Plug 'hynek/vim-python-pep8-indent', {'for': 'python'}

Plug 'elzr/vim-json', {'for': ['json']}
Plug 'pangloss/vim-javascript', {'for': ['json', 'javascript', 'javascript.jsx']}
Plug 'mxw/vim-jsx', {'for': 'javascript.jsx'}

Plug 'kchmck/vim-coffee-script', {'for': 'coffee'}

Plug 'Yggdroot/indentLine'
Plug 'chriskempson/base16-vim'

call plug#end()

try
    set encoding=utf-8
    scriptencoding utf-8
catch
    " We can't source these more than once.
endtry

set noswapfile

set gdefault

set ignorecase
set smartcase

set list
set listchars=tab:→\ ,trail:·,nbsp:·

set relativenumber

set cursorline
set colorcolumn=100

set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4

set lazyredraw

set scrolloff=20

set statusline=
" Path and line number.
set statusline+=%f\:%l
" Modified and readonly flags.
set statusline+=\ %m%r
" Right align.
set statusline+=%=
" Current tag.
set statusline+=%{tagbar#currenttag('[%s]\ ','\ ','f')}
" Filetype.
set statusline+=%{&ft}

set splitbelow
set splitright

set iskeyword+=-

set mouse=a

set wildignore+=*.pyc

set dictionary=
set dictionary+=/usr/share/dict/cracklib-small

set completeopt=
set completeopt+=menu
set completeopt+=preview
set completeopt+=longest

set complete=
set complete+=.
set complete+=b
set complete+=t

" Complete from top to bottom.
let g:SuperTabDefaultCompletionType = '<C-n>'

syntax on

let g:mapleader = "\<Space>"

nnoremap <Leader>e :e<Space>
nnoremap <Leader>ee :e!<CR>
nnoremap <Leader>q :wq<CR>
nnoremap <Leader>t :tabe<Space>
nnoremap <Leader>w :w<CR>
nnoremap <Leader>h :help<Space>
nnoremap <Leader>f :set ft=
nnoremap <Leader>z :setlocal spell<CR>z=
vnoremap <Leader>x y:@"<CR>
nnoremap <Leader>j :join<CR>
vnoremap <Leader>j :join<CR>
nnoremap <Leader>m :messages<CR>
nnoremap <Leader>r :registers<CR>
nnoremap <Leader>s :set<Space>

cnoremap <C-t> <Home>tabe \| <End>

nnoremap <M-q> :q!<CR>

nnoremap <C-l> :nohlsearch<CR>

nnoremap j gj
nnoremap k gk

nnoremap H ^
vnoremap H ^
nnoremap L $
vnoremap L $

nnoremap Y y$

vnoremap < <gv
vnoremap > >gv

nnoremap gp `[v`]

nnoremap ' `

nnoremap "" "0

nnoremap <M-h> <C-w>h
nnoremap <M-j> <C-w>j
nnoremap <M-k> <C-w>k
nnoremap <M-l> <C-w>l

nnoremap Q @q

nmap <Home> [[
nmap <End> ]]
nmap <PageUp> [m
nmap <PageDown> ]m

nmap * g*<C-o>
nmap # g#<C-o>

cnoremap <C-v> <C-r>+
inoremap <C-v> <C-c>"+pi

nnoremap // :<C-r>/'<Home>Ack<Space>'<End>

" J and K position is just too good for line joining and keyword lookup. I do
" switching between tabs much more often so it's a remap.
" NOTE: Join lines with <Leader>j.
nnoremap J gt
nnoremap K gT

" Dictionary completion.
inoremap <C-z> <C-x><C-k>

nmap f <Plug>Sneak_f
nmap F <Plug>Sneak_F
vmap f <Plug>Sneak_f
vmap F <Plug>Sneak_F

nmap t <Plug>Sneak_t
nmap T <Plug>Sneak_T
vmap t <Plug>Sneak_t
vmap T <Plug>Sneak_T

function! MapGoToTab()
    let s:i = 1
    while s:i < 10
        exe 'nnoremap <M-' . s:i . '> :tabnext ' . s:i . '<CR>'
        let s:i += 1
    endwhile
endfunction
call MapGoToTab()

augroup vimrc
    autocmd!
augroup END

let g:last_tab = 1
nnoremap <Space><Space> :exe 'tabn ' . g:last_tab<CR>
autocmd vimrc TabLeave * let g:last_tab = tabpagenr()

function! AuFocusLost()
    exe ':stopinsert'
    exe ':silent! update'
    exe ':Neomake'
endfunction
autocmd vimrc FocusLost * call AuFocusLost()

function! AuBufLeave()
    exe ':silent! update'
    exe ':Neomake'
endfunction
autocmd vimrc BufLeave * call AuBufLeave()

function! AuBufReadPost()
    " It just isn't good enough.
    setlocal omnifunc=

    setlocal relativenumber

    if &filetype !=# 'gitcommit' && line("'\"") > 1 && line("'\"") <= line('$')
        exe "normal! g'\""
    endif
endfunction
autocmd vimrc BufReadPost * call AuBufReadPost()

function! AuBufWritePost()
    exe ':Neomake'
endfunction
autocmd vimrc BufWritePost * call AuBufWritePost()

function! AuFileTypeGitCommit()
    setlocal spell
endfunction
autocmd vimrc FileType gitcommit call AuFileTypeGitCommit()

" Don't be weird... Amazing hack.
" https://github.com/Yggdroot/indentLine/issues/140#issuecomment-173867054
let g:vim_json_syntax_conceal = 0

let g:ack_qhandler = 'botright copen 20'

let g:ctrlp_working_path_mode = 'r'
let g:ctrlp_user_command = [
            \ '.git/',
            \ 'git --git-dir=%s/.git ls-files -oc --exclude-standard'
            \ ]
let g:ctrlp_status_func = {
            \ 'main': 'CtrlPStatusFuncMain',
            \ }
let g:ctrlp_match_window = 'max:20'

function! CtrlPStatusFuncMain(focus, byfname, regex, prev, item, next, marked)
    return getcwd()
endfunction

let g:neomake_error_sign = {
            \ 'text': 'E>',
            \ 'texthl': 'ErrorSign',
            \ }
let g:neomake_warning_sign = {
            \ 'text': 'W>',
            \ 'texthl': 'WarningSign',
            \ }

let g:neomake_python_enabled_makers = ['python']

let g:neomake_verbose = 0
" let g:neomake_logfile = '/home/dagrevis/tmp/neomake.log'

nnoremap <Backspace> :TagbarToggle<CR>

let g:tagbar_width = 60
let g:tagbar_autofocus = 1
let g:tagbar_autoclose = 1
let g:tagbar_sort = 0
let g:tagbar_compact = 1
let g:tagbar_indent = 4
let g:tagbar_iconchars = [' ', ' ']

nnoremap <Tab> :NERDTreeToggle<CR>

let g:NERDTreeWinSize = 60
let g:NERDTreeShowHidden = 1

nnoremap <Leader>a :Ack<Space>

nnoremap <Leader>k :DevDocsUnderCursor<CR>

let g:signify_sign_change = '~'

map / <Plug>(incsearch-forward)
map ? <Plug>(incsearch-backward)

try
    colorscheme base16-eighties
    set background=dark

    let g:colorscheme_loaded = 1
catch
    let g:colorscheme_loaded = 0
endtry

" Color map.
" https://raw.github.com/chriskempson/base16/master/base16-default.png
"
" 00, 0  = black
" 01, 18 = less black
" 02, 19 = ..
" 03, 8  = ..
" 04, 20 = ..
" 05, 7  = ..
" 05, 21 = less white
" 07, 15 = white
"
" 08, 1  = red
" 09, 16 = orange
" 0A, 3  = yellow
" 0B, 2  = green
" 0C, 6  = teal
" 0D, 4  = blue
" 0E, 5  = purple
" 0F, 17 = brown

hi StatusLine ctermbg=18 ctermfg=7
hi StatusLineNC ctermbg=18 ctermfg=8
hi TabLine ctermbg=18 ctermfg=7
hi TabLineFill ctermbg=18
hi TabLineSel ctermbg=19 ctermfg=7
hi LineNr ctermbg=18
hi CursorLineNr ctermbg=18
hi CursorLine ctermbg=18
hi ColorColumn ctermbg=18
hi Visual ctermbg=19
hi Pmenu ctermbg=19 ctermfg=7
hi PmenuSel ctermbg=7 ctermfg=18
hi PmenuThumb ctermbg=19
hi PmenuSbar ctermbg=19
hi WildMenu ctermbg=19 ctermfg=7
hi VertSplit ctermbg=18 ctermfg=8
hi SignColumn ctermbg=18
hi WarningMsg ctermfg=3
hi Todo ctermbg=18 ctermfg=4 cterm=bold
hi Search ctermfg=19

hi IncSearch ctermbg=16 ctermfg=18 cterm=bold

hi ErrorSign ctermbg=0 ctermfg=1
hi WarningSign ctermbg=0 ctermfg=3

hi SignifySignAdd ctermbg=18
hi SignifySignChange ctermbg=18 ctermfg=3
hi SignifySignDelete ctermbg=18 ctermfg=1
hi SignifySignChangeDelete ctermbg=18 ctermfg=1

hi SignatureMarkText ctermbg=0 ctermfg=4

hi SneakPluginTarget ctermfg=8 ctermbg=3

if empty(glob('~/.config/nvim/autoload/plug.vim'))
    silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://github.com/junegunn/vim-plug/raw/master/plug.vim
    autocmd VimEnter * PlugInstall
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

Plug 'vim-utils/vim-husk'
Plug 'Raimondi/delimitMate'
Plug 'ervandew/supertab'
Plug 'bronson/vim-visual-star-search'
Plug 'kshenoy/vim-signature'
Plug 'mhinz/vim-signify'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'mileszs/ack.vim'
Plug 'benekastah/neomake'
Plug 'majutsushi/tagbar'

Plug 'hynek/vim-python-pep8-indent', {'for': 'python'}

Plug 'elzr/vim-json', {'for': ['json']}
Plug 'pangloss/vim-javascript', {'for': ['json', 'javascript', 'javascript.jsx']}
Plug 'mxw/vim-jsx', {'for': 'javascript.jsx'}

Plug 'kchmck/vim-coffee-script', {'for': 'coffee'}

Plug 'Yggdroot/indentLine'
Plug 'chriskempson/base16-vim'

call plug#end()

set noswapfile

set wildignore+=*.pyc

set gdefault

set ignorecase
set smartcase

set list
set listchars=tab:→\ ,trail:·,nbsp:·

set relativenumber

set colorcolumn=100

set cursorline

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

set mouse=a

syntax on

let mapleader = "\<Space>"

noremap <Leader>e :e<Space>
noremap <Leader>ee :e!<CR>
noremap <Leader>t :tabe<Space>
noremap <Leader>w :w<CR>
noremap <Leader>q :wq<CR>
noremap <Leader>h :help<Space>
vnoremap <Leader>x y:@"<CR>

cnoremap <C-t> <Home>tabe \| <End>

noremap <M-q> :q!<CR>

noremap <C-l> :nohlsearch<CR>

noremap j gj
noremap k gk

noremap H ^
vnoremap H ^
noremap L $
vnoremap L $

noremap Y y$

vnoremap < <gv
vnoremap > >gv

noremap gp `[v`]

noremap ' `

noremap "" "0

let i = 1
while i < 10
    exe 'noremap <M-' . i . '> :tabnext ' . i . '<CR>'
    exe 'noremap <Leader>' . i . ' :tabnext ' . i . '<CR>'
    let i += 1
endwhile

let g:last_tab = 1
noremap <Space><Space> :exe 'tabn ' . g:last_tab<CR>
autocmd TabLeave * let g:last_tab = tabpagenr()

noremap <M-h> <C-w>h
noremap <M-j> <C-w>j
noremap <M-k> <C-w>k
noremap <M-l> <C-w>l

noremap Q @q

nmap <Home> [[
nmap <End> ]]
nmap <PageUp> [m
nmap <PageDown> ]m

nmap * g*<C-o>
nmap # g#<C-o>

cnoremap <C-v> <C-r>+
inoremap <C-v> <C-r>+

noremap <Leader>a :Ack<Space>
noremap // :<C-r>/'<Home>Ack<Space>'<End>

func! AuFocusLost()
    exe ':silent! update'
endfunc
autocmd FocusLost * call AuFocusLost()

func! AuBufLeave()
    exe ':silent! update'
endfunc
autocmd BufLeave * call AuBufLeave()

func! AuBufReadPost()
    exe ':Neomake'

    if &ft != "gitcommit" && line("'\"") > 1 && line("'\"") <= line("$")
        exe "normal! g'\""
    endif
endfunc
autocmd BufReadPost * call AuBufReadPost()

func! AuBufWritePost()
    exe ':Neomake'
endfunc
autocmd BufWritePost * call AuBufWritePost()

" Don't be weird... Amazing hack.
" https://github.com/Yggdroot/indentLine/issues/140#issuecomment-173867054
let g:vim_json_syntax_conceal = 0

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
            \ 'text': 'EE',
            \ 'texthl': 'ErrorMsg',
            \ }
let g:neomake_warning_sign = {
            \ 'text': 'WW',
            \ 'texthl': 'WarningMsg',
            \ }

let g:neomake_python_enabled_makers = ['python']

" let g:neomake_logfile = '/home/dagrevis/tmp/neomake.log'

noremap <Backspace> :TagbarToggle<CR>

let g:tagbar_width = 60
let g:tagbar_autofocus = 1
let g:tagbar_autoclose = 1
let g:tagbar_sort = 0
let g:tagbar_compact = 1
let g:tagbar_indent = 4
let g:tagbar_iconchars = [' ', ' ']

" Complete from top to bottom.
let g:SuperTabDefaultCompletionType = "<C-n>"

try
    colorscheme base16-eighties
    set background=dark

    let colorscheme_loaded = 1
catch
    let colorscheme_loaded = 0
endtry

" 1 = red
" 2 = green
" 3 = yellow
" 4 = blue
" 5 = purple
" 6 = teal
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
hi Todo ctermbg=1 ctermfg=18
hi VertSplit ctermbg=18 ctermfg=8
hi SignColumn ctermbg=18
hi WarningMsg ctermfg=3

hi SignifySignAdd ctermbg=18
hi SignifySignChange ctermbg=18 ctermfg=3
hi SignifySignDelete ctermbg=18
hi SignifySignChangeDelete ctermbg=18 ctermfg=1

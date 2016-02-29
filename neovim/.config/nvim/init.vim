if empty(glob('~/.config/nvim/autoload/plug.vim'))
    silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://github.com/junegunn/vim-plug/raw/master/plug.vim
    autocmd VimEnter * PlugInstall
endif

call plug#begin('~/.config/nvim/plugged')

Plug 'tpope/vim-commentary'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'vim-utils/vim-husk'
Plug 'Raimondi/delimitMate'
Plug 'ervandew/supertab'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'mileszs/ack.vim'
Plug 'bronson/vim-visual-star-search'
Plug 'kshenoy/vim-signature'
Plug 'airblade/vim-gitgutter'
Plug 'benekastah/neomake'

Plug 'kchmck/vim-coffee-script', {'for': 'coffee'}
Plug 'mxw/vim-jsx', {'for': 'javascript.jsx'}
Plug 'pangloss/vim-javascript', {'for': ['javascript', 'json', 'javascript.jsx']}

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

set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4

syntax on

let mapleader = "\<Space>"

noremap <Leader>e :e<Space>
noremap <Leader>ee :e!<CR>
noremap <Leader>t :tabe<Space>
noremap <Leader>w :w<CR>
noremap <Leader>q :wq<CR>
vnoremap <Leader>x y:@"<CR>

cnoremap <C-t> <Home>tabe \| <End>

noremap <M-q> :q!<CR>

noremap <C-l> :nohlsearch<CR>

noremap H ^
vnoremap H ^
noremap L $
vnoremap L $

noremap Y y$

vnoremap < <gv
vnoremap > >gv

noremap gp `[v`]

let i = 1
while i < 10
    exe 'nmap <M-' . i . '> :tabnext ' . i . '<CR>'
    exe 'nmap <Leader>' . i . ' :tabnext ' . i . '<CR>'
    let i += 1
endwhile

let g:last_tab = 1
nmap <Space><Space> :exe 'tabn ' . g:last_tab<CR>
autocmd TabLeave * let g:last_tab = tabpagenr()

noremap <M-h> <C-w>h
noremap <M-j> <C-w>j
noremap <M-k> <C-w>k
noremap <M-l> <C-w>l

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

func! AuNewFileBufRead()
    exe ':Neomake'

    if &ft != "gitcommit" && line("'\"") > 1 && line("'\"") <= line("$")
        exe "normal! g'\""
    endif
endfunc
autocmd BufNewFile,BufRead * call AuNewFileBufRead()

autocmd BufNewFile,BufRead *.coffee set filetype=coffee

let g:ctrlp_working_path_mode = 'r'
let g:ctrlp_user_command = [
            \ '.git/',
            \ 'git --git-dir=%s/.git ls-files -oc --exclude-standard'
            \ ]
let g:ctrlp_status_func = {
            \ 'main': 'CtrlPStatusFuncMain',
            \ }

function! CtrlPStatusFuncMain(focus, byfname, regex, prev, item, next, marked)
    return getcwd()
endfunction

let g:neomake_error_sign = {
            \ 'text': 'E>',
            \ 'texthl': 'ErrorMsg',
            \ }

let g:neomake_python_enabled_makers = ['python']

colorscheme base16-eighties
set background=dark

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
hi Pmenu ctermbg=18 ctermfg=7
hi PmenuSel ctermbg=19 ctermfg=7
hi PmenuThumb ctermbg=18
hi PmenuSbar ctermbg=18
hi GitGutterAdd ctermbg=18
hi GitGutterChange ctermbg=18 ctermfg=3
hi GitGutterDelete ctermbg=18 ctermfg=1
hi GitGutterChangeDelete ctermbg=18 ctermfg=1

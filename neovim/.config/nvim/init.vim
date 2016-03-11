" Installs vim-plug and required plugins if needed.
" 
" This allows to replicate my Vim setup by simply copying init.vim into the
" right place. This can be done with a simple one-liner as shown below.
"     curl -Lo ~/.config/nvim/init.vim --create-dirs https://github.com/daGrevis/Dotfiles/raw/master/neovim/.config/nvim/init.vim
if empty(glob('~/.config/nvim/autoload/plug.vim'))
    silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://github.com/junegunn/vim-plug/raw/master/plug.vim

    func! AuPlugged()
        exe ':PlugInstall'
        echo 'Plugins installed, **restart Neovim to load them**!'
    endfunc
    autocmd VimEnter * call AuPlugged()
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
Plug 'AndrewRadev/splitjoin.vim'
Plug 'rhysd/devdocs.vim'

Plug 'hynek/vim-python-pep8-indent', {'for': 'python'}

Plug 'elzr/vim-json', {'for': ['json']}
Plug 'pangloss/vim-javascript', {'for': ['json', 'javascript', 'javascript.jsx']}
Plug 'mxw/vim-jsx', {'for': 'javascript.jsx'}

Plug 'kchmck/vim-coffee-script', {'for': 'coffee'}

Plug 'Yggdroot/indentLine'
Plug 'chriskempson/base16-vim'

call plug#end()

set noswapfile

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

set splitbelow
set splitright

set iskeyword+=-

set mouse=a

set wildignore+=*.pyc

set dictionary=
set dictionary+=/usr/share/dict/cracklib-small

syntax on

let mapleader = "\<Space>"

nnoremap <Leader>e :e<Space>
nnoremap <Leader>ee :e!<CR>
nnoremap <Leader>q :wq<CR>
nnoremap <Leader>t :tabe<Space>
nnoremap <Leader>w :w<CR>
nnoremap <Leader>h :help<Space>
nnoremap <Leader>f :set ft=
nnoremap <Leader>z :setl spell<CR>z=

vnoremap <Leader>x y:@"<CR>

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
inoremap <C-v> <C-r>+

nnoremap // :<C-r>/'<Home>Ack<Space>'<End>

" J and K position is just too good for line joining and keyword lookup. I do
" switching between tabs much more often so it's a remap.
" NOTE: Join with <Leader>j (using splitjoin.vim).
" NOTE: Open docs with <Leader>k (using devdocs.vim).
nnoremap J gt
nnoremap K gT

" Dictionary completion.
inoremap <C-z> <C-x><C-k>

let i = 1
while i < 10
    exe 'nnoremap <M-' . i . '> :tabnext ' . i . '<CR>'
    exe 'nnoremap <Leader>' . i . ' :tabnext ' . i . '<CR>'
    let i += 1
endwhile

let g:last_tab = 1
nnoremap <Space><Space> :exe 'tabn ' . g:last_tab<CR>
autocmd TabLeave * let g:last_tab = tabpagenr()

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

func! AuFileTypeGitCommit()
    setl spell
endfunc
au FileType gitcommit call AuFileTypeGitCommit()

func! AuFileTypePython()
    " Default omnifunc for Python literally does not work so we disable it.
    " NOTE: Try jedi-vim one more time.
    setl omnifunc=
endfunc
au FileType python call AuFileTypePython()

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

nnoremap <Backspace> :TagbarToggle<CR>

let g:tagbar_width = 60
let g:tagbar_autofocus = 1
let g:tagbar_autoclose = 1
let g:tagbar_sort = 0
let g:tagbar_compact = 1
let g:tagbar_indent = 4
let g:tagbar_iconchars = [' ', ' ']

" Complete from top to bottom.
let g:SuperTabContextDefaultCompletionType = "<C-n>"
" Omni-complete when possible, but fallback to keyword complete.
" https://github.com/ervandew/supertab/blob/66511772a430a5eaad7f7d03dbb02e8f33c4a641/doc/supertab.txt#L435-L460
let g:SuperTabDefaultCompletionType = 'context'
autocmd FileType *
            \ if &omnifunc != '' |
            \   call SuperTabChain(&omnifunc, '<C-n>') |
            \ endif

nnoremap <Leader>a :Ack<Space>

" Join and split.
nnoremap <Leader>j gJ
vnoremap <Leader>j gJ
nnoremap <Leader>s :SplitjoinSplit<CR>

nnoremap <Leader>k :DevDocsUnderCursor<CR>

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

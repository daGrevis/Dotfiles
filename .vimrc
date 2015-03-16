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
Plugin 'Yggdroot/indentLine'
Plugin 'Z1MM32M4N/vim-superman'
Plugin 'amdt/vim-niji'
Plugin 'bling/vim-airline'
Plugin 'chriskempson/base16-vim'
Plugin 'ervandew/supertab'
Plugin 'guns/vim-clojure-static'
Plugin 'haya14busa/incsearch.vim'
Plugin 'justinmk/vim-sneak'
Plugin 'kien/ctrlp.vim'
Plugin 'lilydjwg/colorizer'
Plugin 'mattn/gist-vim'
Plugin 'mattn/webapi-vim'
Plugin 'mileszs/ack.vim'
Plugin 'morhetz/gruvbox'
Plugin 'scrooloose/nerdtree'
Plugin 'scrooloose/syntastic'
Plugin 'sheerun/vim-polyglot'
Plugin 'tacahiroy/ctrlp-funky'
Plugin 'terryma/vim-expand-region'
Plugin 'tpope/vim-abolish'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-dispatch'
Plugin 'tpope/vim-eunuch'
Plugin 'tpope/vim-fireplace'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-leiningen'
Plugin 'tpope/vim-repeat'
Plugin 'tpope/vim-rsi'
Plugin 'tpope/vim-sensible'
Plugin 'tpope/vim-sleuth'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-unimpaired'
Plugin 'venantius/vim-eastwood'
Plugin 'vim-scripts/gitignore'
Plugin 'wellle/targets.vim'

" Required by Vundle.
call vundle#end()
filetype plugin indent on

" Sets how indentation works.
func! ResetIndentation ()
    setlocal et
    setlocal ts=4
    setlocal sw=4
    setlocal sts=4
endfunc

" Disables swap-files.
set noswapfile

" Show some special chars, well, specially.
set list
set listchars=tab:→\ ,trail:·,nbsp:·

" Shown at the start of wrapped lines.
let &showbreak = '↳ '

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
    hi HighlightNext guibg=#F2777A
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

" Minimal number of screen lines to keep above and below the cursor.
set scrolloff=10

syntax manual

" Map leader to <Space>.
let mapleader = "\<Space>"

" Mappings for controlling tabs.
nmap <S-j> :tabprevious<CR>
nmap <S-k> :tabnext<CR>

" Maps <M-1> to go to the first tab and so until <M-9>.
let i = 1
while i < 10
    execute 'nmap <M-' . i . '> :tabnext ' . i . '<CR>'
    execute 'nmap <Leader>' . i . ' :tabnext ' . i . '<CR>'
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

nmap <Leader>e :e<Space>
nmap <Leader>t :tabe<Space>

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
imap <C-v> <C-o><C-v>
cmap <C-v> <C-r>+

" Type 123<CR> to go to 123rd line.
nnoremap <CR> G
nnoremap <BS> gg

" Auto-closes that window when using q: instead of :q for mistake.
map q: :q

" Jump to next/previous class.
nmap <Home> [[
nmap <End> ]]

" Jump to next/previous function.
nmap <PageUp> [m
nmap <PageDown> ]m

"
" Commands.
"

command! -nargs=* ResetIndentation call ResetIndentation()

"
" Auto-commands.
"

au filetype python setlocal makeprg=python\ %
au filetype clojure setlocal makeprg=lein\ exec\ %

au filetype text,markdown setlocal textwidth=100

au filetype html,css,scss,sass,javascript,coffee setlocal iskeyword+=-

func! AuFtGitCommit()
    setlocal colorcolumn=50
    setlocal spell
endfunc
au filetype gitcommit call AuFtGitCommit()

func! ShouldDisableBlingBling()
    let ext = expand('%:e')

    let should = 0
    if ext == "css" || ext == "js" && getfsize(expand("%")) > 20 * 1024
        let should = 1
    endif

    return should
endfunc

func! AuBufReadPre()
    if ShouldDisableBlingBling()
        setlocal nowrap
        setlocal nohlsearch
        execute "ColorClear"
    endif
endfunc
autocmd BufReadPre * call AuBufReadPre()

func! AuBufReadPost()
    " Restore last cursor position.
    if line("'\"") > 1 && line("'\"") <= line("$")
        exe "normal! g'\""
    endif

    if ShouldDisableBlingBling()
        setlocal syntax=OFF
    else
        setlocal syntax=ON
    endif
endfunc
autocmd BufReadPost * call AuBufReadPost()

" Minor adjustments to colorschemes.
func! AuColorScheme()
    let colo = g:colors_name

    if colo == "base16-eighties"
        hi Comment guifg=#A09F93
    endif
endfunc
autocmd ColorScheme * call AuColorScheme()

"
" Leader mappings.
"

" Word suggestions for typos.
map <Leader>z :set spell<CR>z=

" Shortcut for setting filetype.
nmap <Leader>f :set ft=

" Count occurrences of a pattern in current buffer.
nmap <Leader>n :%s///gn<Left><Left><Left><Left>

" See registers.
nmap <Leader>r :registers<CR>

nmap <Leader>s :sort<CR>
vmap <Leader>s :sort<CR>

" Sources VimL.
vmap <Leader>x y:@"<CR>

nmap <Leader>m :make<CR>

nmap <Leader>b :Gblame<CR>

" Goes into visual-block mode.
nmap <Leader>v v<C-v>

" Replace word under the cursor.
nmap <Leader>k yiw:%s/<C-r>0/

nmap <Leader>h :help<Space>

" Sets color-scheme.
colorscheme slate

if has('gui_running')

    " Sets your fave color-scheme.
    " colorscheme gruvbox
    " colorscheme base16-default
    " colorscheme molokai
    " colorscheme badwolf
    " colorscheme flattown
    colorscheme base16-eighties

    " Removes all GUI stuff.
    set guioptions=c

    " Sets font.
    set guifont=Inconsolata-g\ for\ Powerline\ Medium\ 9

endif

"
" Airline configuration.
"

let g:airline_powerline_fonts = 1

"
" Ack configuration.
"

nmap <Leader>a :Ack<Space>
nmap // :<C-r>/<Backspace><Backspace><C-a><Right><Right><Backspace><Backspace>Ack<Space>

" Fixes <Enter> not working in Ack.vim quickfix-list when <Enter> is mapped globally.
au filetype qf nmap <buffer> <CR> o

"
" Syntastic configuration.
"

" Linters for Python files.
let g:syntastic_python_checkers = ['python', 'flake8']
let g:syntastic_python_python_exec = 'python2'
let g:syntastic_python_flake8_exec = 'flake8-python2'

" Linters for CoffeeScript files.
let g:syntastic_coffee_checkers = ['coffee', 'coffeelint']
let g:syntastic_coffee_coffeelint_post_args = '--file ~/coffeelint.json'

"
" NERDTree configuration.
"

" Opens NERDTree with <Tab>.
nmap <Tab> :NERDTreeToggle<CR>

" Makes NERDTree more wider.
let NERDTreeWinSize = 50

" Makes NERDTree show hidden files as well.
let NERDTreeShowHidden = 1

"
" Gist configuration.
"

" Anonymous gists.
nmap <Leader>pg :Gist -a<CR>
vmap <Leader>pg <ESC>:'<,'>Gist -a<CR>

"
" CtrlP configuration.
"

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

"
" CtrlPFunky configuration.
"

let g:ctrlp_funky_syntax_highlight = 1

nmap <Backspace> :CtrlPFunky<CR>

"
" Incsearch configuration.
"

map / <Plug>(incsearch-forward)\v
map ? <Plug>(incsearch-backward)\v

"
" Expand-region configuration.
"

vmap v <Plug>(expand_region_expand)
vmap <S-v> <Plug>(expand_region_shrink)

"
" Sneak configuration.
"

let g:sneak#prompt = ''

nmap <Enter> <Plug>Sneak_s
nmap <S-Enter> <Plug>Sneak_S

" Replaces `f` with 1-char Sneak.
nmap f <Plug>Sneak_f
nmap F <Plug>Sneak_F
xmap f <Plug>Sneak_f
xmap F <Plug>Sneak_F
omap f <Plug>Sneak_f
omap F <Plug>Sneak_F
" Replaces `t` with 1-char Sneak.
nmap t <Plug>Sneak_t
nmap T <Plug>Sneak_T
xmap t <Plug>Sneak_t
xmap T <Plug>Sneak_T
omap t <Plug>Sneak_t
omap T <Plug>Sneak_T

au ColorScheme * hi SneakPluginTarget guifg=black guibg=#F2777A ctermfg=black ctermbg=red

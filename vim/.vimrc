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
Plugin 'SirVer/ultisnips'
Plugin 'Z1MM32M4N/vim-superman'
Plugin 'bling/vim-airline'
Plugin 'chriskempson/base16-vim'
Plugin 'ervandew/supertab'
Plugin 'guns/vim-clojure-static'
Plugin 'haya14busa/incsearch.vim'
Plugin 'honza/vim-snippets'
Plugin 'justinmk/vim-sneak'
Plugin 'kchmck/vim-coffee-script'
Plugin 'kien/ctrlp.vim'
Plugin 'lilydjwg/colorizer'
Plugin 'luochen1990/rainbow'
Plugin 'mattn/gist-vim'
Plugin 'mattn/webapi-vim'
Plugin 'mileszs/ack.vim'
Plugin 'morhetz/gruvbox'
Plugin 'nathanaelkane/vim-indent-guides'
Plugin 'nelstrom/vim-visual-star-search'
Plugin 'plasticboy/vim-markdown'
Plugin 'scrooloose/nerdtree'
Plugin 'scrooloose/syntastic'
Plugin 'suan/vim-instant-markdown'
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
func! ResetIndentation()
    setlocal et
    setlocal ts=4
    setlocal sw=4
    setlocal sts=4
endfunc

syntax on

call ResetIndentation()

" Disables folds.
set nofoldenable

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
func! HighlightNext(blinktime)
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

try
    set cryptmethod=blowfish2
catch
    set cryptmethod=blowfish
endtry

set colorcolumn=100

" Minimal number of screen lines to keep above and below the cursor.
set scrolloff=20

" Don't update the display while executing macros.
set lazyredraw

" Map leader to <Space>.
let mapleader = "\<Space>"

" Go to next/prev tab.
nmap - gT
nmap = gt

" Move tabs. Idiomatic <S-{-,=}>.
nmap _ :tabm -1<CR>
nmap + :tabm +1<CR>

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

" Always go to exact position of the mark.
nmap ' `

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

" Languages in which completion that includes `-` symbol makes sense.
au filetype html,htmldjango,css,scss,sass,javascript,coffee,sh setlocal iskeyword+=-

au filetype man,html,htmldjango setlocal nowrap

func! AuFtMarkdown()
    setlocal spell
    setlocal cc=80
    setlocal tw=80
endfunc
au filetype markdown call AuFtMarkdown()

func! AuFtVim()
    setlocal cc=78
    setlocal tw=78
endfunc
au filetype vim call AuFtVim()

func! AuFtPo()
    setlocal commentstring=#~\ %s
    setlocal cc=80
endfunc
au filetype po call AuFtPo()

func! AuFtSql()
    setlocal commentstring=--\ %s
endfunc
au filetype sql call AuFtSql()

func! AuFtGitCommit()
    setlocal colorcolumn=50
    setlocal spell
endfunc
au filetype gitcommit call AuFtGitCommit()

func! AuFtQuickFix()
    setlocal nowrap

    " Fixes <CR> not working in Ack.vim quickfix-list
    " when <CR> is mapped globally.
    nmap <buffer> <CR> o
endfunc
au filetype qf call AuFtQuickFix()

func! AuFtHtmlDjango()
    set ft=html
endfunc
au filetype htmldjango call AuFtHtmlDjango()

func! ShouldDisableBlingBling()
    let ext = expand('%:e')

    let should = 0
    if (ext == "css" || ext == "js") && getfsize(expand("%")) > 20 * 1024
        let should = 1
    endif

    return should
endfunc

func! AuBufReadPre()
    if ShouldDisableBlingBling()
        setlocal nowrap
        setlocal nohlsearch
    endif
endfunc
au BufReadPre * call AuBufReadPre()

func! AuBufReadPost()
    " Restore last cursor position.
    if &ft != "gitcommit" && line("'\"") > 1 && line("'\"") <= line("$")
        exe "normal! g'\""
    endif
endfunc
au BufReadPost * call AuBufReadPost()

" Minor adjustments to colorschemes.
func! AuColorScheme()

    if g:colors_name == "slate"
        hi def link HighlightNext WarningMsg
    endif

    if g:colors_name == "base16-eighties"
        hi HighlightNext guibg=#F2777A
        hi Comment guifg=#A09F93

        hi SneakPluginTarget guifg=black guibg=#F2777A ctermfg=black ctermbg=red

        hi SyntasticErrorSign guibg=#F2777A guifg=#393939
        hi SyntasticStyleErrorSign guibg=#FFCC66 guifg=#2D2D2D

        let g:airline_theme = "base16eighties"
    endif

    if g:colors_name == "flatlandia"
        hi HighlightNext guibg=#aa2915
        hi Comment guifg=#798188
        hi SignColumn guibg=#3b3e40
        hi SneakPluginTarget guifg=black guibg=#aa2915 ctermfg=black ctermbg=red
    endif
endfunc
au ColorScheme * call AuColorScheme()

func! AuFocusLost()
    exe ":silent! wall"
endfunc
au FocusLost * call AuFocusLost()

func! AuBufLeave()
    exe ":silent! update"
endfunc
au BufLeave * call AuBufLeave()

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

" Replace text.
nmap <Leader>k yiw:%s/<C-r>0/
vmap <Leader>k y:%s/<C-r>0/

nmap <Leader>h :help<Space>

" Restructures text so it doesn't go over `textwidth`.
nmap <Leader>gq mtggvGgq`t

" Sets color-scheme.
colorscheme slate

if has('gui_running')

    " Sets your fave color-scheme.
    " colorscheme badwolf
    " colorscheme base16-default
    colorscheme base16-eighties
    " colorscheme flattown
    " colorscheme gruvbox
    " colorscheme molokai
    " colorscheme flatlandia

    " Removes all GUI stuff.
    set guioptions=c

    " Sets font.
    set guifont=Inconsolata-g\ for\ Powerline\ Medium\ 9

endif

"
" Airline configuration.
"

if has('gui_running')
    let g:airline_powerline_fonts = 1
endif

" Fine-tune tabline.
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_buffers = 0
let g:airline#extensions#tabline#show_tabs = 1
let g:airline#extensions#tabline#tab_nr_type = 1
let g:airline#extensions#tabline#formatter = "unique_tail_improved"
let g:airline#extensions#tabline#show_close_button = 0

"
" Ack configuration.
"

nmap <Leader>a :Ack<Space>
nmap // :<C-r>/<Backspace><Backspace><C-a><Right><Right><Backspace><Backspace>Ack<Space>

"
" Syntastic configuration.
"

let g:syntastic_always_populate_loc_list = 0
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0

nmap <Leader><Tab> :SyntasticCheck<CR>
nmap <Leader><S-Tab> :SyntasticReset<CR>

" Linters for Python files.
let g:syntastic_python_checkers = ['python', 'frosted']
let g:syntastic_python_python_exec = 'python2'

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

let g:ctrlp_prompt_mappings = {
            \ "PrtClearCache()": ["<C-r>"],
            \ }

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

"
" Rainbow configuration.
"

let g:rainbow_active = 1

let g:rainbow_conf = {
            \ 'guifgs': [
            \ "#F2777A",
            \ "#F99157",
            \ "#FFCC66",
            \ "#99CC99",
            \ "#66CCCC",
            \ "#6699CC",
            \ "#CC99CC",
            \ "#D27B53",
            \ ]
            \ }

"
" Instant Markdown configuration.
"

" Actually don't be instant.
let g:instant_markdown_slow = 1

" Autostart is too of a surprise.
let g:instant_markdown_autostart = 0

" It just make sense to open preview like this.
func! AuFtMarkdownInstantMarkdown()
    nmap <buffer> <Space>m :InstantMarkdownPreview<CR>
endfunc
au filetype markdown call AuFtMarkdownInstantMarkdown()

"
" Colorized configuration.
"

let g:colorizer_startup = 0

"
" Indent guides configuration.
"

let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_default_mapping = 0
let g:indent_guides_color_change_percent = 3

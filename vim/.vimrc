" Required.
set nocompatible
filetype off

" Loads vim-plug.
call plug#begin('~/.vim/plugged')

" Optional plugins.
Plug 'AndrewRadev/splitjoin.vim'
Plug 'Raimondi/delimitMate'
Plug 'SirVer/ultisnips'
Plug 'Z1MM32M4N/vim-superman'
Plug 'airblade/vim-gitgutter'
Plug 'chriskempson/base16-vim'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'drmikehenry/vim-fontsize'
Plug 'ervandew/supertab'
Plug 'ggVGc/vim-fuzzysearch'
Plug 'guns/vim-clojure-static'
Plug 'haya14busa/incsearch.vim'
Plug 'haya14busa/vim-operator-flashy'
Plug 'honza/vim-snippets'
Plug 'hynek/vim-python-pep8-indent'
Plug 'justinmk/vim-sneak'
Plug 'kana/vim-operator-user'
Plug 'kchmck/vim-coffee-script'
Plug 'kshenoy/vim-signature'
Plug 'lilydjwg/colorizer'
Plug 'ludovicchabant/vim-gutentags'
Plug 'luochen1990/rainbow'
Plug 'majutsushi/tagbar'
Plug 'mattn/gist-vim'
Plug 'mattn/webapi-vim'
Plug 'mileszs/ack.vim'
Plug 'morhetz/gruvbox'
Plug 'mxw/vim-jsx'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'nelstrom/vim-visual-star-search'
Plug 'pangloss/vim-javascript'
Plug 'plasticboy/vim-markdown'
Plug 'rhysd/devdocs.vim'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/syntastic'
Plug 'sjl/gundo.vim'
Plug 'suan/vim-instant-markdown'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-fireplace'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-leiningen'
Plug 'tpope/vim-obsession'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-scripts/SQLUtilities'
Plug 'vim-scripts/gitignore'
Plug 'vim-utils/vim-husk'
Plug 'wellle/targets.vim'

" Required by vim-plug.
call plug#end()

" Sets how indentation works.
func! ResetIndentation()
    setlocal et
    setlocal ts=4
    setlocal sw=4
    setlocal sts=4
endfunc

func! RemoveSpaces()
    %s/\s\+$//e
    w
endfunc

func! UnDOS()
    %s/\r//g
endfunc

syntax on

call ResetIndentation()

set timeoutlen=300
set ttimeoutlen=50

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

" Minimal number of screen lines to keep above and below the cursor.
set scrolloff=0

" Don't update the display while executing macros.
set lazyredraw

set wildmode=longest,full

" Startup message is irritating.
set shortmess+=I

" The completion menu will show only when there is more than one match.
set completeopt=menuone

" Enables Vim built-in completion.
set omnifunc=syntaxcomplete#Complete

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

" Wrap-friendly <j> and <k> keys.
nmap j gj
nmap k gk

nmap <M-q> :q!<CR>

nmap H ^
vmap H ^
nmap L $
vmap L $

nmap * g*<C-o>
nmap # g#<C-o>

" Default Q is very annoying. Maps it to something useful.
nmap Q @q

nmap <C-q> :e ~/Texts<CR>

" Reselect text when indenting.
vmap < <gv
vmap > >gv

" Reselect last pasted text.
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

" Indent all the things!
nmap + gg=G2<C-o>

" Copy/pasting from/to system clipboard.
vmap <C-c> "+y
nmap <C-v> "*p
imap <C-v> <C-o>"*P
cmap <C-v> <C-r>+
cmap <S-Insert> <C-r>+

cmap <C-t> <C-a>tabe \| <C-e>

" Auto-closes that window when using q: instead of :q for mistake.
map q: :q

" Jump to next/previous class.
nmap <Home> [[zz
nmap <End> ]]zz

" Jump to next/previous function.
nmap <PageUp> [mzz
nmap <PageDown> ]mzz

" Always go to exact position of the mark.
nmap ' `

" Quick access to yank register.
nmap "" "0

" Hides 'Type :quit to exit'.
nnoremap <C-c> <C-c>:echo<CR>

" I don't see any reason to go a character ahead, so lets just go back.
nmap ~ ~h

" Goes to definition in a new tab (requires ctags).
nmap <C-]> :tab tag <C-r><C-w><CR>

"
" Commands.
"

command! -nargs=* ResetIndentation call ResetIndentation()

command! -nargs=* RemoveSpaces call RemoveSpaces()

command! -nargs=* UnDOS call UnDOS()

"
" Auto-commands.
"

" Enables Vim built-in completion.
au FileType css,sass,scss setlocal omnifunc=csscomplete#CompleteCSS
au FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
au FileType javascript,javascript.jsx,coffee setlocal omnifunc=javascriptcomplete#CompleteJS
au FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

au filetype python setlocal makeprg=python\ %
au filetype clojure setlocal makeprg=lein\ exec\ %

" Languages in which completion that includes `-` symbol makes sense.
au filetype html,htmldjango,css,scss,sass,javascript,coffee,sh,gitcommit setlocal iskeyword+=-

au filetype man setlocal nowrap

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
        " setlocal nohlsearch
    endif
endfunc
au BufReadPre * call AuBufReadPre()

func! AuBufReadPost()
    if has('gui_running')
        setlocal colorcolumn=100

        if &ft == "gitcommit"
            setlocal colorcolumn=50
        endif
    else
        setlocal colorcolumn=
    endif

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
        hi Comment guifg=#A09F93
        hi StatusLine guifg=#F2F0EC guibg=#515151
        hi Wildmenu guifg=#2D2D2D guibg=#6699CC

        hi Cursor guibg=#6699CC

        " Completion menu.
        hi Pmenu guifg=#F2F0EC guibg=#515151
        hi PmenuSel guifg=#2D2D2D guibg=#6699CC
        " Blends out right sidebar.
        hi PmenuThumb guibg=#2D2D2D
        hi PmenuSbar guibg=#2D2D2D

        hi HighlightNext guibg=#F2777A

        hi SneakPluginTarget guifg=black guibg=#A09F93 ctermfg=black ctermbg=white

        hi SyntasticErrorSign guibg=#F2777A guifg=#393939
        hi SyntasticStyleErrorSign guibg=#FFCC66 guifg=#2D2D2D

        hi GitGutterAdd guifg=#99CC99
        hi GitGutterChange guifg=#FFCC66
        hi GitGutterDelete guifg=#F2777A
        hi GitGutterChangeDelete guifg=#F99157

        hi Flashy guibg=#FFCC66

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

autocmd BufRead,BufNewFile *.conf setfiletype conf

"
" Leader mappings (leaders).
" They are sorted alphabetically.
"

nmap <silent> <Leader>= <Plug>FontsizeBegin
nmap <silent> <Leader>+ <Plug>FontsizeInc
nmap <silent> <Leader>- <Plug>FontsizeDec
nmap <silent> <Leader>0 <Plug>FontsizeDefault

" Find in files (alternative grep).
nmap <Leader>a :Ack<Space>

" Blaming is always fun and it's useful for teaching. Be polite tho!
nmap <Leader>b :Gblame<CR>

" Colorize strings that are colors! Disabled by default because it's slow.
nmap <Leader>c :ColorToggle<CR>

" Search for diff markers.
nmap <Leader>d /\v[<>=]{4,}<CR>

" Open file.
nmap <Leader>e :e<Space>

" Reload file.
nmap <Leader>ee :e!<CR>

" Shortcut for setting filetype.
nmap <Leader>f :set ft=

" Restructures text so it doesn't go over `textwidth`.
vmap <Leader>q mtggvGgq`t

" Don't underestimate Vim help -- it is top notch!
nmap <Leader>h :help<Space>

" Replace word or selected text in current buffer.
nmap <Leader>k yiw:%s/<C-r>0/
vmap <Leader>k y:%s/<C-r>0/

nmap <Leader>m :make<CR>

" Shows registers.
nmap <Leader>r :registers<CR>

" Count occurrences of a pattern in current buffer.
nmap <Leader>n :%s///gn<Left><Left><Left><Left>

" Anonymous gists.
nmap <Leader>pg :Gist -a<CR>
vmap <Leader>pg <ESC>:'<,'>Gist -a<CR>

" Save and close buffer.
nmap <Leader>q :wq!<CR>

" Sort everything or selected text in current buffer.
nmap <Leader>s :sort<CR>
vmap <Leader>s :sort<CR>

nmap <Leader>t :tabe<Space>

" Go back in time (tree-view history). Yes, Vim is awesome!
nmap <Leader>u :GundoToggle<CR>

" Start selecting in visual-block mode.
nmap <Leader>v v<C-v>

nmap <Leader>w :w<CR>

" Sources what you have selected as Vimscript.
vmap <Leader>x y:@"<CR>

" Correct word under the cursor.
map <Leader>z :set spell<CR>z=

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

    " Blink faster!
    set guicursor+=n-v-c:blinkon200

endif

"
" Airline configuration.
"

" Hacky way to disable airline.
if ! has("gui_running")
    let g:loaded_airline = 1
endif

" Fine-tune tabline.
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_buffers = 0
let g:airline#extensions#tabline#show_tabs = 1
let g:airline#extensions#tabline#tab_nr_type = 1
let g:airline#extensions#tabline#formatter = "unique_tail_improved"
let g:airline#extensions#tabline#show_close_button = 0
let g:airline_left_sep = ""
let g:airline_right_sep = ""

"
" Ack configuration.
"

nmap // :<C-r>/'<C-a>Ack<Space>'<Left>

"
" Syntastic configuration.
"

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 1

let g:syntastic_python_checkers = ["python", "frosted"]
let g:syntastic_python_python_exec = "python2"

let g:syntastic_coffee_checkers = ["coffee", "coffeelint"]
let g:syntastic_coffee_coffeelint_post_args = "--file ~/coffeelint.json"

let g:syntastic_javascript_checkers = ["eslint"]

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

"
" CtrlP configuration.
"

nmap <C-p> :w \| CtrlP<CR>

nmap <Backspace> :w \| CtrlPBufTag<CR>

" Use Git to get files. Much faster and it respects .gitignore rules.
let g:ctrlp_user_command = [
            \ '.git/',
            \ 'git --git-dir=%s/.git ls-files -oc --exclude-standard'
            \ ]

" Searches in files, buffers and MRU files at the same time.
let g:ctrlp_cmd = 'CtrlPMixed'

" Don't reload CtrlP cache when opening file outside project.
let g:ctrlp_working_path_mode = 'r'

let g:ctrlp_match_window = 'bottom,order:btt,min:1,max:40'

let g:ctrlp_prompt_mappings = {
            \ "PrtClearCache()": ["<C-r>"],
            \ }

"
" Incsearch configuration.
"

nmap / <Plug>(incsearch-forward)
nmap ? <Plug>(incsearch-backward)

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
            \ "#FFCC66",
            \ "#6699CC",
            \ "#CC99CC",
            \ "#F99157",
            \ "#66CCCC",
            \ "#99CC99",
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

" It just makes sense to open preview like this.
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

if has('gui_running')
    let g:indent_guides_enable_on_vim_startup = 1
endif
let g:indent_guides_default_mapping = 0
let g:indent_guides_color_change_percent = 3

"
" GitGutter configuration.
"

" It should never lag.
let g:gitgutter_realtime = 0
let g:gitgutter_eager = 0

"
" UltiSnips configuration.
"

let g:UltiSnipsExpandTrigger = "<C-Space>"
let g:UltiSnipsJumpForwardTrigger = "<C-Space>"

"
" FuzzySearch configuration.
"

" Inverted search is just confusing to bother with (just search and go back
" with N). Instead lets map it to something more useful like fuzzy search!
nmap ? :FuzzySearch<CR>

"
" Devdocs configuration.
"

nmap K <Plug>(devdocs-under-cursor)

"
" Tagbar configuration.
"

let g:tagbar_width = 80
let g:tagbar_autofocus = 1
let g:tagbar_autoclose = 1
let g:tagbar_sort = 0

nmap <S-Tab> :TagbarToggle<CR>

"
" Gutentags configuration.
"

let g:gutentags_exclude = [
            \ "node_modules",
            \ "bower_components",
            \ ]

"
" Flashy configuration.
"

map y <Plug>(operator-flashy)
nmap Y <Plug>(operator-flashy)$

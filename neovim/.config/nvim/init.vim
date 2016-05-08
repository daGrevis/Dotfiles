" Part of https://github.com/daGrevis/Dotfiles
" Source: https://github.com/daGrevis/Dotfiles/raw/master/neovim/.config/nvim/init.vim

" Auto-install {{{

" Installs vim-plug along with all plugins in case plugin manager isn't installed.
"
" This allows to replicate my Vim setup by simply copying init.vim into the
" right place. This can be done with a simple one-liner as shown below.
"     curl -Lo ~/.config/nvim/init.vim --create-dirs https://github.com/daGrevis/Dotfiles/raw/master/neovim/.config/nvim/init.vim
if empty(glob('~/.config/nvim/autoload/plug.vim'))
    silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://github.com/junegunn/vim-plug/raw/master/plug.vim

    function! AuPlugged()
        exe ':PlugInstall'
        echom 'Installing plugins... **Restart Vim to load them!**'
    endfunction
    augroup AuPlugged
        autocmd!
        autocmd VimEnter * call AuPlugged()
    augroup END
endif

" }}}

" Plugins {{{

call plug#begin('~/.config/nvim/plugged')

" Hooks for 3rd party repeat support.
Plug 'https://github.com/tpope/vim-repeat'

" Various new text objects and enchantments to standard ones.
Plug 'https://github.com/wellle/targets.vim'

" Easily delete, change and add such surroundings in pairs.
Plug 'https://github.com/tpope/vim-surround'

" Sneak motion and enchantments to f/F/t/T mappings.
Plug 'https://github.com/justinmk/vim-sneak'

" Highlight all pattern matches.
Plug 'https://github.com/haya14busa/incsearch.vim'

" Bracket mappings.
Plug 'https://github.com/tpope/vim-unimpaired'

" Search under the cursor from visual mode.
Plug 'https://github.com/bronson/vim-visual-star-search'

" Readline bindings in command mode.
Plug 'https://github.com/vim-utils/vim-husk'

" UNIX helpers from command mode.
Plug 'https://github.com/tpope/vim-eunuch'

" Commenting.
Plug 'https://github.com/tpope/vim-commentary'

" Git bindings.
Plug 'https://github.com/tpope/vim-fugitive'

" Tab completion.
Plug 'https://github.com/ervandew/supertab'

" Auto-close delimiters.
Plug 'https://github.com/Raimondi/delimitMate'

" File finder (fuzzy search, regex and more).
Plug 'https://github.com/ctrlpvim/ctrlp.vim'

" File explorer.
Plug 'https://github.com/scrooloose/nerdtree'

" Asynchronous linting (syntax checking, static analysis and so on).
Plug 'https://github.com/benekastah/neomake'

" Grepping tool with support for Ack.
Plug 'https://github.com/mhinz/vim-grepper'

" Syntax tree using ctags.
Plug 'https://github.com/majutsushi/tagbar'

" Diffs via sign column.
Plug 'https://github.com/mhinz/vim-signify'

" Marks via sign column.
Plug 'https://github.com/kshenoy/vim-signature'

" Interface to DevDocs.io documentation.
Plug 'https://github.com/rhysd/devdocs.vim'

" Edit GPG encrypted files.
Plug 'https://github.com/jamessan/vim-gnupg'

" Display vertical indentation lines.
Plug 'https://github.com/Yggdroot/indentLine'

" Fave color-scheme.
Plug 'https://github.com/chriskempson/base16-vim'

" File-type specific plugins below.

Plug 'https://github.com/hynek/vim-python-pep8-indent', {'for': 'python'}

Plug 'https://github.com/elzr/vim-json', {'for': ['json']}
" https://github.com/pangloss/vim-javascript/issues/378
Plug 'https://github.com/pangloss/vim-javascript', {'for': ['json', 'javascript', 'javascript.jsx'], 'branch': 'develop'}
Plug 'https://github.com/mxw/vim-jsx', {'for': 'javascript.jsx'}

Plug 'https://github.com/kchmck/vim-coffee-script', {'for': 'coffee'}

Plug 'https://github.com/reedes/vim-pencil', {'for': 'markdown'}

call plug#end()

" }}}

" Encoding {{{

try
    set encoding=utf-8
    scriptencoding utf-8
catch
    " We can't source these more than once.
endtry

" }}}

" Leader {{{

" Vim has this abstract button called Leader. Sets Leader to Space.
" This means that <Leader>w mapping can be invoked by pressing <Space>w.
let g:mapleader = "\<Space>"

" }}}

" Tabs vs Spaces {{{

" Use spaces when inserting a tab.
set expandtab
" Number of spaces that a tab counts for.
set tabstop=4
" Number of spaces that a tab counts for when using auto-indent.
set shiftwidth=4

" }}}

" Look and Feel {{{

set noswapfile

" Ignore patterns.
set wildignore=
set wildignore+=*.pyc

" Adds - to the list of keyword characters. Used for w and * mapping among
" other things.
set iskeyword+=-

" Show characters like Tab or trailing space differently.
set list listchars=tab:→\ ,trail:·,nbsp:·

" Show the line number relative to the cursor. This allows rapid movement in
" buffers with 10j, 17k or alike moves to get to the specific line.
set relativenumber

" Keeps cursor at the center region of screen.
set scrolloff=25

" Highlights the screen line of the cursor. Helps finding the cursor.
set cursorline

" Highlights the screen column.
set colorcolumn=101

" Enables mouse (super useful in rare situations).
set mouse=a

" Any action not typed will not cause the screen to redraw. Good for macros.
set lazyredraw

" Don't hide my JSON! Amazing hack.
" https://github.com/Yggdroot/indentLine/issues/140#issuecomment-173867054
let g:vim_json_syntax_conceal = 0

" }}}

" Completion {{{

set complete=
set complete+=.
set complete+=b
set complete+=t

set dictionary=
set dictionary+=/usr/share/dict/cracklib-small

" Dictionary completion.
inoremap <C-z> <C-x><C-k>

" Complete top to bottom.
let g:SuperTabDefaultCompletionType = '<C-n>'

" }}}

" Splits {{{

set splitbelow
set splitright

" Switch to a split.
nnoremap <M-h> <C-w>h
nnoremap <M-j> <C-w>j
nnoremap <M-k> <C-w>k
nnoremap <M-l> <C-w>l

" }}}

" Tabs {{{

" J and K position is just too good for line joining and keyword lookup. I do
" switching between tabs much more often so it's a remap.
" NOTE: Join lines with <Leader>j.
nnoremap J gt
nnoremap K gT

" Go to tab 1-9 with <M-1>, <M-2> etc..
function! MapGoToTab()
    let s:i = 1
    while s:i < 10
        exe 'nnoremap <M-' . s:i . '> :tabnext ' . s:i . '<CR>'
        let s:i += 1
    endwhile
endfunction
call MapGoToTab()

" }}}

" Folding {{{

" Folding 101
" * zi - toggle folding
" * za - toggle fold
" * zj - next fold
" * zk - previous fold
" * zR - open everything
" * zM - close everything

set nofoldenable

set foldmethod=marker

nnoremap <Enter> za

" }}}

" Spelling {{{

" #PROTIP: Use cos mapping from vim-unimpaired to toggle spell-checker.

" Suggest word under/after the cursor.
nnoremap <Leader>z :setlocal spell<CR>z=

" }}}

" System Clipboard {{{

" Paste text.
cnoremap <C-v> <C-r>+
inoremap <C-v> <C-c>"+pi

" Copy text (also exits visual model cause it's <C-c>).
vnoremap <C-c> "+y

" }}}

" File Finder {{{

" Don't change working directory.
let g:ctrlp_working_path_mode = ''

" List files using git when possible. This is much faster and will respect
" .gitignore rules.
let g:ctrlp_user_command = [
            \ '.git/',
            \ 'git --git-dir=%s/.git ls-files -oc --exclude-standard'
            \ ]

" Sets height.
let g:ctrlp_match_window = 'max:20'

" Rewrites status-line.
function! CtrlPStatusFuncMain(focus, byfname, regex, prev, item, next, marked)
    return getcwd()
endfunction
let g:ctrlp_status_func = {
            \ 'main': 'CtrlPStatusFuncMain',
            \ }

" }}}

" File Explorer {{{

nnoremap <Tab> :NERDTreeToggle<CR>

let g:NERDTreeWinSize = 60
let g:NERDTreeShowHidden = 1

" https://github.com/kien/ctrlp.vim/issues/78
let g:ctrlp_dont_split = 'nerdtree'

" }}}

" Syntax Tree {{{

nnoremap <Backspace> :TagbarToggle<CR>

" Tweaks apparance.
let g:tagbar_width = 60
let g:tagbar_compact = 1
let g:tagbar_indent = 4
let g:tagbar_iconchars = [' ', ' ']

" Focus Tagbar on open.
let g:tagbar_autofocus = 1
" Close Tagbar when going to tag.
let g:tagbar_autoclose = 1

" Sort according to order in the source file (don't sort).
let g:tagbar_sort = 0

" }}}

" Linter {{{

" Visual appearance.
let g:neomake_error_sign = {
            \ 'text': 'E>',
            \ 'texthl': 'ErrorSign',
            \ }
let g:neomake_warning_sign = {
            \ 'text': 'W>',
            \ 'texthl': 'WarningSign',
            \ }

" let g:neomake_{ language }_enabled_makers
" let g:neomake_python_enabled_makers = ['python']

" Logging. Be quite by default.
let g:neomake_verbose = 0
" let g:neomake_logfile = '/home/dagrevis/tmp/neomake.log'

" }}}

" Searching {{{

" Match globally (avoid /g in s/foo/bar/g).
set gdefault

" Ignore case when all characters are in lower case.
set ignorecase smartcase

" Highlights all pattern matches when searching.
" #PROTIP: Interactively test your regex.
map / <Plug>(incsearch-forward)
map ? <Plug>(incsearch-backward)

" }}}

" Grepping {{{

" Grep something.
nnoremap // :Grepper<CR>

" Enabled greppers sorted by priority.
let g:grepper = {
    \ 'tools': ['ack', 'git', 'grep'],
    \ }

" }}}

" Diffs {{{

" The character to use when line was changed.
let g:signify_sign_change = '~'

" }}}

" Status-line {{{

function! StatusLinePath()
    let s:path = @%
    if s:path ==# ''
        let s:path = '[No Name]'
    endif

    let s:output = s:path . ':' . line('.') . '|' . virtcol('.')
    return s:output
endfunction

set statusline=
" Path and line number.
set statusline+=%{StatusLinePath()}
" Modified and read-only flags.
set statusline+=\ %m%r
" Right align.
set statusline+=%=
" Current tag.
set statusline+=%{tagbar#currenttag('%s\ ','\ ','f')}
" File-type.
set statusline+=%{&ft}

" }}}

" Mappings {{{

" Move downward/upward with a respect to lines wrap.
nnoremap j gj
nnoremap k gk

" Join lines.
nnoremap <Leader>j :join<CR>
vnoremap <Leader>j :join<CR>

" Temporary disable search highlighting.
nnoremap <C-l> :nohlsearch<CR>

" Goes to the first non-blank character of the line.
nnoremap H ^
vnoremap H ^
" Goes to the end of the line.
nnoremap L $
vnoremap L $

" Yank till end of the line.
nnoremap Y y$

" Indent visually selected text.
vnoremap < <gv
vnoremap > >gv

" Select last yanked/pasted text.
nnoremap gp `[v`]

" Character-wise marks.
nnoremap ' `

" Visually select word under the cursor without moving.
nmap * g*<C-o>
nmap # g#<C-o>

" Run macro called q.
nnoremap Q @q

" Yank X, delete Y, paste X with ""p.
" http://stackoverflow.com/a/1504373
nnoremap "" "0

" Move through syntax tree.
" For example, <PageDown> goes to next method.
nmap <Home> [[
nmap <End> ]]
nmap <PageUp> [m
nmap <PageDown> ]m

" Juggling with buffers.
nnoremap <Leader>e :e<Space>
nnoremap <Leader>ee :e!<CR>
nnoremap <Leader>q :wq<CR>
nnoremap <Leader>w :w<CR>
nnoremap <M-q> :q!<CR>

" Command templates.
nnoremap <Leader>h :help<Space>
nnoremap <Leader>t :tabe<Space>
nnoremap <Leader>s :set<Space>
nnoremap <Leader>f :set ft=

" Execute command in a new tab.
" Type :Ack foo and press <C-t>.
cnoremap <C-t> <Home>tabe \| <End>

" Show messages.
nnoremap <Leader>m :messages<CR>
" Display registers.
nnoremap <Leader>r :registers<CR>

" Source visually selected Vimscript.
vnoremap <Leader>x y:@"<CR>

" Just like standard f/F except it works on multiple lines.
nmap f <Plug>Sneak_f
nmap F <Plug>Sneak_F
vmap f <Plug>Sneak_f
vmap F <Plug>Sneak_F

" Just like standard t/T except it works on multiple lines.
nmap t <Plug>Sneak_t
nmap T <Plug>Sneak_T
vmap t <Plug>Sneak_t
vmap T <Plug>Sneak_T

" Keeps s/S original functionality.
" https://github.com/justinmk/vim-sneak/issues/87
nmap <Plug>(Go_away_Sneak_s) <Plug>Sneak_s
nmap <Plug>(Go_away_Sneak_S) <Plug>Sneak_S

" Search DevDocs.io for word under the cursor.
nnoremap <Leader>k :DevDocsUnderCursor<CR>

" }}}

" Auto-groups {{{

" Allows cleaning old auto-commands.
augroup vimrc
    autocmd!
augroup END

" Go back to last tab.
let g:last_tab = 1
nnoremap <Space><Space> :exe 'tabn ' . g:last_tab<CR>
function! AuTabLeave()
    let g:last_tab = tabpagenr()
endfunction
autocmd vimrc TabLeave * call AuTabLeave()

function! AuFocusGained()
    " https://github.com/neovim/neovim/issues/1936
    exe ':checktime'
endfunction
autocmd vimrc FocusGained * call AuFocusGained()

function! AuFocusLost()
    " Save when losing focus.
    exe ':silent! update'

    " Go back to normal mode.
    exe ':stopinsert'
endfunction
autocmd vimrc FocusLost * call AuFocusLost()

function! AuBufLeave()
    " Save when leaving buffer.
    exe ':silent! update'
endfunction
autocmd vimrc BufLeave * call AuBufLeave()

function! AuBufReadPost()
    " I'm not using omni-complete.
    setlocal omnifunc=

    " Always show line numbers.
    setlocal relativenumber

    " Remember last cursor position.
    if line("'\"") > 1 && line("'\"") <= line('$')
        " Unless it's a commit message.
        if &filetype !=# 'gitcommit'
            exe "normal! g'\""
        endif
    endif
endfunction
autocmd vimrc BufReadPost * call AuBufReadPost()

function! AuBufWritePost()
    " Run linter on explicit save.
    exe ':Neomake'
endfunction
autocmd vimrc BufWritePost * call AuBufWritePost()

function! AuFileTypePo()
    setlocal commentstring=#~\ %s
endfunction
autocmd vimrc FileType po call AuFileTypePo()

function! AuFileTypeSql()
    setlocal commentstring=--\ %s
endfunction
autocmd vimrc FileType sql call AuFileTypeSql()

function! AuFileTypeSass()
    setlocal shiftwidth=4
endfunction
autocmd vimrc FileType sass call AuFileTypeSass()

function! AuFileTypeMarkdown()
    setlocal tw=80
    setlocal cc=81
    call pencil#init()
endfunction
autocmd vimrc FileType markdown call AuFileTypeMarkdown()

function! AuFileTypeGitCommit()
    " Enables spell-checker for commit messages.
    setlocal spell
endfunction
autocmd vimrc FileType gitcommit call AuFileTypeGitCommit()

function! AuGrepper()
    " Sets Grepper window height to 20 lines.
    exe ':resize 20'
endfunction
autocmd vimrc User Grepper call AuGrepper()

" }}}

" Color-scheme {{{

try
    colorscheme base16-eighties
    set background=dark

    let g:colorscheme_loaded = 1
catch
    let g:colorscheme_loaded = 0
endtry

" Fall-back to a color-scheme called slate.
if !g:colorscheme_loaded
    colorscheme slate
endif

" }}}

" Color-scheme modifications {{{

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
hi Folded ctermbg=18
hi Comment ctermfg=20

hi IncSearch ctermbg=16 ctermfg=18 cterm=bold

hi ErrorSign ctermbg=0 ctermfg=1
hi WarningSign ctermbg=0 ctermfg=3

hi SignifySignAdd ctermbg=18
hi SignifySignChange ctermbg=18 ctermfg=3
hi SignifySignDelete ctermbg=18 ctermfg=1
hi SignifySignChangeDelete ctermbg=18 ctermfg=1

hi SignatureMarkText ctermbg=0 ctermfg=4

hi SneakPluginTarget ctermfg=8 ctermbg=3

" }}}

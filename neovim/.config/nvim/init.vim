" Part of http://dagrev.is/Dotfiles
" Source: http://dagrev.is/init.vim

" Auto-install {{{

" Installs vim-plug along with all plugins in case plugin manager isn't installed.
"
" This allows to replicate my Vim setup by simply copying init.vim into the right place:
"   curl -Lo ~/.config/nvim/init.vim --create-dirs http://dagrev.is/init.vim
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

" Text object for the same indent level.
Plug 'https://github.com/michaeljsmith/vim-indent-object'

" Easily delete, change and add such surroundings in pairs.
Plug 'https://github.com/tpope/vim-surround'

" Sneak motion and enchantments to f/F/t/T mappings.
Plug 'https://github.com/justinmk/vim-sneak'

" Highlight all pattern matches.
Plug 'https://github.com/haya14busa/incsearch.vim'

" Show number of search matches and index of a current match.
Plug 'https://github.com/google/vim-searchindex'

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

" GitHub bindings.
Plug 'https://github.com/tpope/vim-rhubarb'

" Illuminate other uses of the current word under the cursor.
Plug 'https://github.com/RRethy/vim-illuminate'

" Visualize Vim history tree.
Plug 'https://github.com/sjl/gundo.vim'

" Auto-adjust tabs vs spaces based on current buffer.
Plug 'https://github.com/tpope/vim-sleuth'

" Helpers for modifying word under the cursor.
Plug 'https://github.com/tpope/vim-abolish'

" Saves your Vim sessions.
Plug 'https://github.com/tpope/vim-obsession'

" Insert-mode completion with tab.
Plug 'https://github.com/ervandew/supertab'

" Interface with tree-sitter for more robust syntax highlighting and more.
Plug 'https://github.com/nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" IntelliSense engine.
Plug 'https://github.com/neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile --force'}

" VimL source.
Plug 'https://github.com/Shougo/neco-vim'
Plug 'https://github.com/neoclide/coc-neco'

" Linter source. Used with shellcheck.
Plug 'https://github.com/iamcco/coc-diagnostic', {'do': 'yarn install --frozen-lockfile --force && yarn build'}

" CSS source.
Plug 'https://github.com/neoclide/coc-css', {'do': 'yarn install --frozen-lockfile --force'}

" JSON source.
Plug 'https://github.com/neoclide/coc-json', {'do': 'yarn install --frozen-lockfile --force'}

" JavaScript and TypeScript source.
Plug 'https://github.com/neoclide/coc-tsserver', {'do': 'yarn install --frozen-lockfile --force'}

" ESLint source.
Plug 'https://github.com/neoclide/coc-eslint', {'do': 'yarn install --frozen-lockfile --force'}

" Prettier source.
Plug 'https://github.com/neoclide/coc-prettier', {'do': 'yarn install --frozen-lockfile --force'}

" Rust source.
Plug 'https://github.com/neoclide/coc-rls', {'do': 'yarn install --frozen-lockfile --force'}

" Lua source.
Plug 'https://github.com/josa42/coc-lua', {'do': 'yarn install --frozen-lockfile --force'}

" File explorer.
Plug 'https://github.com/weirongxu/coc-explorer', {'do': 'yarn install --frozen-lockfile --force'}

" Snippet engine.
Plug 'https://github.com/neoclide/coc-snippets', {'do': 'yarn install --frozen-lockfile --force'}

" Auto-close delimiters.
Plug 'https://github.com/Raimondi/delimitMate'

" Fuzzy finder for files, buffers and more.
Plug 'https://github.com/junegunn/fzf'
Plug 'https://github.com/junegunn/fzf.vim'

" Grepping tool with support for Ack.
Plug 'https://github.com/mhinz/vim-grepper'

Plug 'https://github.com/ryanoasis/vim-devicons'

" Syntax tree using coc.
Plug 'https://github.com/liuchengxu/vista.vim'

" Diffs via sign column.
Plug 'https://github.com/mhinz/vim-signify'

" Marks via sign column.
Plug 'https://github.com/kshenoy/vim-signature'

" Interface to DevDocs.io documentation.
Plug 'https://github.com/rhysd/devdocs.vim'

" Edit GPG encrypted files.
Plug 'https://github.com/jamessan/vim-gnupg'

" Handle line and column numbers in file names.
Plug 'https://github.com/kopischke/vim-fetch'

" Seamless management of tags file.
Plug 'https://github.com/ludovicchabant/vim-gutentags'

" Generate HTML by writing CSS.
Plug 'https://github.com/mattn/emmet-vim'

" Color text if it looks like a color (hex colors, CSS colors etc).
Plug 'https://github.com/chrisbra/Colorizer'

" Wrap and unwrap arguments.
Plug 'https://github.com/FooSoft/vim-argwrap'

" Switch segments of text with predefined replacements.
Plug 'https://github.com/AndrewRadev/switch.vim'

" Move arguments left and right.
Plug 'https://github.com/AndrewRadev/sideways.vim'

" Restores FocusGained & FocusLost auto-commands when running inside tmux.
Plug 'https://github.com/tmux-plugins/vim-tmux-focus-events'

" Colorful parentheses for lisp-like languages.
Plug 'https://github.com/junegunn/rainbow_parentheses.vim'

" Fave color-scheme.
Plug 'https://github.com/rakr/vim-one'

" Utility functions for converting colors.
Plug 'https://github.com/mgiuffrida/CSSMinister'

" Smooth scrolling in terminal.
Plug 'https://github.com/psliwka/vim-smoothie'

" File-type specific plugins below.

" Markdown preview in browser.
Plug 'https://github.com/iamcco/markdown-preview.nvim', {'do': 'cd app && yarn install --frozen-lockfile --force'}

Plug 'https://github.com/vim-pandoc/vim-pandoc'
Plug 'https://github.com/vim-pandoc/vim-pandoc-syntax'

Plug 'https://github.com/hynek/vim-python-pep8-indent', {'for': 'python'}

Plug 'https://github.com/kchmck/vim-coffee-script', {'for': 'coffee'}

Plug 'https://github.com/keith/swift.vim', {'for': 'swift'}

Plug 'https://github.com/chr4/nginx.vim', {'for': 'nginx'}

Plug 'https://github.com/tmux-plugins/vim-tmux', {'for': 'tmux'}

Plug 'https://github.com/dearrrfish/vim-applescript', {'for': 'applescript'}

Plug 'https://github.com/chrisbra/csv.vim', {'for': 'csv'}

Plug 'https://github.com/yaymukund/vim-haxe', {'for': 'haxe'}

Plug 'https://github.com/amadeus/vim-mjml', {'for': 'mjml'}

Plug 'https://github.com/pantharshit00/vim-prisma', {'for': 'prisma'}

call plug#end()

" }}}

" Functions {{{

" Highlights the screen column.
" Don't set color column when terminal is not wide enough.
function! SetColorColumn(v)
    if &columns > a:v
        exe 'set colorcolumn=' . a:v
    endif
endfunction

function g:Copy(text)
  let @* = a:text
  let @+ = a:text
endfunction

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
" Round indent to multiple.
set shiftround

" }}}

" Look and Feel {{{

" How often CursorHold auto-command is triggered.
set updatetime=500

" Do not create swap-files.
set noswapfile

" Persist undos/redos after closing Vim.
set undofile

" Forces to copy the file and overwrite the original one when writing.
" Some watchers might not see the change otherwise.
set backupcopy=yes

" Ignore patterns.
set wildignore=
set wildignore+=*.pyc

" Adds - to the list of keyword characters. Used for w and * mapping among
" other things.
set iskeyword+=-

" Show characters like Tab or trailing space differently.
set list listchars=tab:→\ ,trail:·,nbsp:·
set showbreak=↪

" Also shows line number relative to the cursor. This allows rapid movement in
" buffers with 10j, 17k or alike moves to get to the specific line.
set number relativenumber

" Keeps cursor at the center region of screen.
set scrolloff=25

" Highlights the screen line of the cursor. Helps finding the cursor.
set cursorline

" Always show sign column to avoid flickering.
set signcolumn=yes

" Enables mouse (super useful in rare situations).
set mouse=a

" Any action not typed will not cause the screen to redraw. Good for macros.
set lazyredraw

" Don't show startup message.
set shortmess+=I

" Don't show ins-completion-menu messages.
set shortmess+=c

" Always show status bar.
set laststatus=2

" Hide buffers instead of closing them.
set hidden

" Block cursor that doesn't blink.
set guicursor=a:block-blinkon0

" GUI colors for Neovim >= 0.1.5+ and Vim 8.
if (has("termguicolors"))
    set termguicolors
endif

" Incremental %s/ in split.
set inccommand=split

" Make it a bit wider.
let g:gundo_width = 60

" Character pairs to colorize in Lisp-like languages.
let g:rainbow#pairs = [['(', ')'], ['[', ']'], ['{', '}']]

let g:CSSMinisterCreateMappings = 0

" Disables creation of .netrwhist file.
let g:netrw_dirhistmax = 0
let g:loaded_netrw = 1

" Create directory of current file if it doesn't exist.
" https://vim.fandom.com/wiki/Mkdir_on_edit_if_needed
au BufNewFile * :exe ': !mkdir -p ' . escape(fnamemodify(bufname('%'),':p:h'),'#% \\')

" }}}

" Completion {{{

set complete=
" Scan the current buffer.
set complete+=.
" Scan other loaded buffers that are in the buffer list.
set complete+=b
" Tag completion.
set complete+=t

set completeopt=
" Use a popup menu to show the possible completions.
set completeopt+=menu
" Only insert the longest common text of the matches.
set completeopt+=longest

set dictionary=
set dictionary+=/usr/share/dict/words

" Dictionary completion.
inoremap <C-z> <C-x><C-k>

" Complete top to bottom.
let g:SuperTabDefaultCompletionType = '<C-n>'

" Match case when completing.
let g:SuperTabCompleteCase = 'match'

" Complete the longest common match.
let g:SuperTabLongestEnhanced = 1

" Confirm completion.
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" Expand snippet under the cursor.
imap <C-s> <Plug>(coc-snippets-expand)

call coc#config('snippets', {
      \ 'extends': {
      \   'javascript': ['typescriptreact'],
      \   'typescript': ['typescriptreact'],
      \ }})

" }}}

" Splits {{{

set splitbelow
set splitright

" }}}

" Tabline {{{

" J and K position is just too good for line joining and keyword lookup. I do
" switching between tabs much more often so it's a remap.
" NOTE: Join lines with <Leader>j.
nnoremap J gt
nnoremap K gT

" Go to tab 1-9.
function! MapGoToTab()
    let s:i = 1
    while s:i < 10
        exe 'nnoremap <Leader>' . s:i . ' :tabnext ' . s:i . '<CR>'
        let s:i += 1
    endwhile
endfunction
call MapGoToTab()

" Overrides how tab names are shown.
function! TabLine()
    let s = ''

    let t = tabpagenr()
    let tt = tabpagenr('$')

    for i in range(tt)
        let tab = i + 1
        let buflist = tabpagebuflist(tab)
        let winnr = tabpagewinnr(tab)
        let bufnr = buflist[winnr - 1]
        let bufname = bufname(bufnr)
        let buftype = getbufvar(bufnr, 'buftype')

        if bufname == ''
            let tabname = '[No Name]'
        elseif buftype == ''
            let tabname = fnamemodify(bufname, ':~:.')
            let tabname = matchstr(tabname, '[^\/]\+\/[^\/]\+$')
        endif

        if tabname == ''
            let tabname = bufname
        endif

        let s .= '%' . tab . 'T'
        let s .= (tab == t ? '%#TabLineSel#' : '%#TabLine#')
        let s .= ' ' . tab . ' ' . tabname . ' '
    endfor

    let s .= '%#TabLineFill#'

    return s
endfunction
set tabline=%!TabLine()

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

" }}}

" Spelling {{{

set spellfile+=$HOME/.config/nvim/spell/en.utf-8.add

" Suggest word under/after the cursor.
nnoremap <Leader>z :setlocal spell<CR>z=

" #PROTIP: Use =os mapping from vim-unimpaired to toggle spell-checker.

" }}}

" System Clipboard {{{

" Paste text.
cnoremap <C-v> <C-r>+
inoremap <C-v> <C-c>"+pi

" Copy text (also exits visual mode cause it's <C-c>).
vnoremap <C-c> "*ygv"+y

" }}}

" File Finder {{{

nnoremap <C-p> :Files<CR>

let g:fzf_layout = { 'down': '~40%' }
let g:fzf_preview_window = ''

" }}}

" File Explorer {{{

nnoremap <Tab> :CocCommand explorer<CR>

call coc#config('explorer', {
      \ 'position': 'left',
      \ 'keyMappings.global.<tab>': 'quit',
      \ 'keyMappings.global.<cr>': ["expandable?", ["expanded?", "collapse", "expand"], "open"],
      \ 'quitOnOpen': 1,
      \ 'sources': [{'name': 'file', 'expand': 1}],
      \ 'file.child.template': '[git | 2] [selection | clip | 1] [indent][icon | 1] [diagnosticError & 1][filename omitCenter 1][modified][readonly] [linkIcon & 1][link growRight 1 omitCenter 5]',
      \ 'file.showHiddenFiles': 1,
      \ 'width': 60,
      \ 'icon.enableNerdfont': 1,
      \ 'previewAction.onHover': 0,
      \ })

" }}}

" Syntax Tree {{{

nnoremap <Backspace> :Vista!!<CR>

let g:vista_default_executive = 'coc'
let g:vista_close_on_jump = 1
let g:vista_sidebar_width = 60

" }}}

" Tags {{{

let g:gutentags_enabled = 0

let g:gutentags_ctags_executable_javascript = 'jsctagsi'

" Open tag under the cursor in a new tab.
nnoremap <Leader>] <C-w><C-]><C-w>T

" }}}

" IntelliSense {{{

" Navigate diagnostics.
nmap <silent> [l <Plug>(coc-diagnostic-prev)
nmap <silent> ]l <Plug>(coc-diagnostic-next)

nmap <silent> gd :vsplit<CR><Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gf <Plug>(coc-references)
nmap <silent> gn <Plug>(coc-rename)

function! s:show_documentation()
  if &filetype == 'vim'
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

nnoremap <silent> gk :call <SID>show_documentation()<CR>

command! -nargs=0 Prettier :CocCommand prettier.formatFile

call coc#config('coc.preferences', {
      \ 'diagnostic.errorSign': 'E',
      \ 'diagnostic.warningSign': 'W',
      \ 'diagnostic.infoSign': 'I',
      \ 'diagnostic.hintSign': 'H',
      \ })

call coc#config('diagnostic', {
      \ 'refreshAfterSave': 0,
      \ 'maxWindowHeight': 16,
      \ })

call coc#config('tsserver', {
      \ 'enableJavascript': 0,
      \ })

call coc#config('eslint', {
      \ 'enable': 1,
      \ 'packageManager': 'yarn',
      \ })

call coc#config('languageserver.flow', {
      \ 'command': './node_modules/.bin/flow',
      \ 'args': ['lsp'],
      \ 'filetypes': ['javascript.flow.jsx'],
      \ 'initializationOptions': {},
      \ 'requireRootPattern': 1,
      \ 'settings': {},
      \ 'rootPatterns': ['.flowconfig']
      \ })

call coc#config('diagnostic-languageserver', {
      \ 'filetypes': { 'sh': 'shellcheck' },
      \ 'formatFiletypes': { 'sh': 'shfmt' },
      \ 'formatters': { 'shfmt': {
      \     'command': 'shfmt',
      \     'args': ['-i', '2', '-bn', '-ci', '-sr']
      \ }}
      \ })

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

function! CountMatches()
    exe ':%s///gn'
endfunction
command! CountMatches call CountMatches()

function! SearchForDiffMarker()
    exe '/\v[=><]{4,}'
endfunction
command! SearchForDiffMarker call SearchForDiffMarker()

function! SearchForNonAscii()
    exe '/[^\u0000-\u007F]+'
endfunction
command! SearchForNonAscii call SearchForNonAscii()

" }}}

" Grepping {{{

" Grep something.
nnoremap // :Grepper<CR>

" Enabled greppers sorted by priority.
" TODO: Maybe use location list, not quickfix list, as it's private.
let g:grepper = {
    \ 'tools': ['ack', 'git', 'grep'],
    \ 'simple_prompt': 1,
    \ 'highlight': 1,
    \ 'prompt_mapping_tool': '<leader>g',
    \ }

" Mappings like s, v, t, o, and O for quickfix window.
let g:qf_mapping_ack_style = 1

" }}}

" Diffs {{{

" The character to use when line was changed.
let g:signify_sign_change = '~'

let g:signify_update_on_focusgained = 1

" }}}

" Text Sharing {{{

" Make an anonymous gist from current buffer or selection. It uploads the gist and then yanks the
" gist link to system clipboard. Also tries to determine filename and filetype.
" Based on https://github.com/defunkt/gist/issues/195
function! ShareGist(line1, line2, ...) abort
    if executable('gist') == 0
        echom 'Install gist for sharing text (gem install gist)'
        return
    endif

    let l:args = ['-p']

    if index(a:000, '-f') == -1
        let l:fname = fnamemodify(expand('%'), ':t')
        if len(l:fname)
            let l:ext = fnamemodify(l:fname, ':e')
            if !len(l:ext)
                let l:fname .= '.' . &filetype
            endif
            let l:args += ['-f', l:fname]
        endif
    endif

    for l:a in a:000 | let l:args += [shellescape(l:a)] | endfor

    let l:output = systemlist('gist '.join(l:args, ' '), getline(a:line1, a:line2))

    if len(l:output) == 1
        call setreg('+', l:output[0])
        echom l:output[0]
    else
        for l:l in l:output
            echo l:l
        endfor
    endif
endfunction
command! -range=% -nargs=* ShareGist call ShareGist(<line1>, <line2>, <f-args>)

nnoremap <Leader>g :ShareGist
vnoremap <Leader>g :ShareGist

" }}}

" Status-line {{{

function! StatusLineGitHead()
    if winwidth(0) < 120
        return ''
    endif

    try
        let s:head = fugitive#head(7)
    catch
        return ''
    endtry

    if s:head == ''
        return ''
    endif

    return ' ' . s:head . ' '
endfunction

function! StatusLineDiagnostics()
    let info = get(b:, 'coc_diagnostic_info', {})
    if empty(info) | return '' | endif
    let msgs = []
    if get(info, 'error', 0)
      call add(msgs, 'E' . info['error'])
    endif
    if get(info, 'warning', 0)
      call add(msgs, 'W' . info['warning'])
    endif
    return join(msgs, ' ')
endfunction

function! StatusLineFileSize()
    if winwidth(0) < 120
        return ''
    endif

    let bytes = getfsize(expand("%:p"))
    if bytes <= 0
        return ""
    endif
    if bytes < 1024
        return bytes . 'B'
    elseif bytes < 1024 * 1024
        return (bytes / 1024) . 'K'
    else
        return (bytes / 1024 / 1024) . 'M'
    endif
endfunction

set statusline=
" Modified and read-only flags.
set statusline+=\ %m%r
" Current path.
set statusline+=%f\ 
" Start highlight.
set statusline+=%1*
" Git revision.
set statusline+=%{StatusLineGitHead()}
" End highlight.
set statusline+=%*

" Right align.
set statusline+=%=
set statusline+=%{StatusLineDiagnostics()}\ 
set statusline+=%{StatusLineFileSize()}\ 
set statusline+=%1*
" Position.
set statusline+=\ %l:%c/%L\ %p%%\ 
set statusline+=%*

" }}}

" Commands {{{

" Common typos.
command! Q q
command! Wqa wqa
command! Wq wq
command! Qa qa

" Remove whitespace from end of lines.
function! StripWhitespace()
    s/\s\+$//e
endfunction
command! -range=% StripWhitespace <line1>,<line2>call StripWhitespace()

" Update on new output similar to tail -f command.
function! TailF()
    while 1
        e
        normal G
        redraw
        sleep 1
    endwhile
endfunction
command! TailF call TailF()

function! S()
    let obsessions_dir = '~/.obsessions'

    exe ':!mkdir -p ' . obsessions_dir

    let path = expand(obsessions_dir) . '/' . fnamemodify(getcwd(), ':t') . '.vim'

    if !filereadable(path)
      exe ':Obsession ' . path
    else
      exe ':Obsession!'
    endif
endfunction
command! S call S()

" }}}

" Mappings {{{

" Move downward/upward with a respect to lines wrap.
nnoremap <expr> j v:count ? 'j' : 'gj'
nnoremap <expr> k v:count ? 'k' : 'gk'

" nnoremap <expr> h col('.') == match(getline('.'), '\S') + 1 ? 'k$' : 'h'
" nnoremap <expr> l col('.') == strlen(getline('.')) ? 'j^' : 'l'

" Join lines.
nnoremap <Leader>j :join<CR>
vnoremap <Leader>j :join<CR>

" Clear currently highlighted phrase and close all floating windows.
nnoremap <C-l> :nohlsearch \| :call coc#float#close_all()<CR>

" Goes to the first non-blank character of the line.
nnoremap H ^
vnoremap H ^
" Goes to the end of the line.
nnoremap L $
vnoremap L $h

" Yank till end of the line.
nnoremap Y y$

" Indent visually selected text.
vnoremap < <gv
vnoremap > >gv

" Select last yanked text.
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

" Character-wise marks.
nnoremap ' `

" Visually select word under the cursor without moving.
nnoremap * g*N
nnoremap # g#N

" Run macro called q.
nnoremap Q @q

" Yank X, delete Y, paste X with ""p.
" http://stackoverflow.com/a/1504373
nnoremap "" "0

" Yank selection to "0 register.
vmap ""y "0y

" Delete selection, but also yank it to "0 register.
vmap ""d "0ygvd

" Move through syntax tree.
" For example, <PageDown> goes to next method.
nmap <Home> [[
nmap <End> ]]
nmap <PageUp> [m
nmap <PageDown> ]m

function! ReloadTabs()
  let last_tab = tabpagenr()
  exe 'tabdo e!'
  exe 'tabn ' . last_tab
endfunction

" Juggling with buffers.
nnoremap <Leader>e :e<Space>
nnoremap <Leader>ee :e!<CR>
nnoremap <Leader>r :call ReloadTabs()<CR>
nnoremap <Leader>q ZZ
nnoremap <Leader>w :w<CR>

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

" Source Vimscript.
nnoremap <Leader>x :source %<CR>
vnoremap <Leader>x y:@"<CR>

" Replace in current buffer.
nnoremap <Leader>a :%s/\<<C-r><C-w>\>/
vnoremap <Leader>a y:%s/<C-r>"/

" Visually select current line without selecting newline at the end.
nnoremap <Leader>c ^v$h
" Visually select current line without selecting newline at the end.
nnoremap <Leader>v ggVG

" Copy path of current buffer to system clipboard.
function! CopyPath()
  call Copy(fnamemodify(expand("%"), ":~:."))
endfunction
noremap <Leader>d :call CopyPath()<CR>

" Format the current paragraph.
nnoremap gw vapgw

" Prompt to open file with same name, different extension.
nnoremap <Leader>y :tabe <C-r>=expand('%:h').'/'<CR>

" Open split in new tab.
noremap <Leader>o <C-W>T

" Close all but this split.
noremap <Leader>i :only<CR>

" Switch between tabs easily.
noremap <silent> gr :tabm +<CR>
noremap <silent> gR :tabm -<CR>

" Switch between splits easily.
nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
nnoremap <A-l> <C-w>l

" Switch case of the character under the cursor, but DON'T move to the right.
function! SwitchCase()
    normal! ~
    if strlen(getline('.')) != virtcol('.')
        normal! h
    endif
endfunction
nnoremap ~ :call SwitchCase()<CR>

" Just like standard <C-a> & <C-x>, but also works on letters and other characters.
" https://github.com/siers/dotfiles/blob/1fe5bfab8771f00ee463c01b811b943ca7402d5c/vim/.config/nvim/init.vim#L418-L426
function! s:CharacterDelta(delta) " Char analog of C-{x,a}
    normal! yl
    let c = nr2char(char2nr(getreg('"')) + a:delta)
    call setreg('"', c)
    normal! ""vP
endf
nnoremap <C-a> :call <SID>CharacterDelta(1)<CR>
nnoremap <C-x> :call <SID>CharacterDelta(-1)<CR>

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

" Wraps or unwraps under the cursor.
nnoremap <Leader>' :ArgWrap<CR>

" Moves the argument to left or right side.
nnoremap <Leader>, :SidewaysLeft<CR>
nnoremap <Leader>. :SidewaysRight<CR>

" Toggle Gundo for history tree.
nnoremap <Leader>u :GundoToggle<CR>

" Git blame current buffer.
nnoremap <Leader>b :Gblame<CR>

" Quickfix mappings for opening files.
autocmd FileType qf nnoremap <buffer><silent> o <CR><C-w>w :q<CR>
autocmd FileType qf nnoremap <buffer><silent> t <C-W>T<CR> :only<CR>
autocmd FileType qf nnoremap <buffer><silent> O <CR>
autocmd FileType qf nnoremap <buffer><silent> T <C-W>T<CR>

" Fix formatting with Prettier.
nmap <Leader>p :Prettier<CR>

" }}}

" Auto-commands (events) {{{

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
    exe ':checktime'
endfunction
autocmd vimrc FocusGained * call AuFocusGained()

function! AuBufEnter()
    exe ':checktime'
endfunction
autocmd vimrc BufEnter * call AuBufEnter()

function! AuFocusLost()
    " Save when losing focus.
    exe ':silent! update'

    " Go back to normal mode from insert mode.
    if mode() == 'i'
      exe ':stopinsert'
    endif

    if getbufvar(bufnr('%'), '&filetype') == 'fzf'
      exe ':q'
    endif
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

function! AuBufWritePost()
    exe ':checktime'
endfunction
autocmd vimrc BufWritePost * call AuBufWritePost()

function! AuInsertLeave()
    " https://github.com/neovim/neovim/issues/7994#issuecomment-388296360
    setlocal nopaste
endfunction
autocmd vimrc InsertLeave * call AuInsertLeave()

function! AuFileTypePo()
    setlocal commentstring=#~\ %s
endfunction
autocmd vimrc FileType po call AuFileTypePo()

function! AuFileTypeSql()
    setlocal commentstring=--\ %s
endfunction
autocmd vimrc FileType sql call AuFileTypeSql()

function! AuFileTypeNginx()
    setlocal commentstring=#\ %s
endfunction
autocmd vimrc FileType nginx call AuFileTypeNginx()

autocmd BufEnter *.nix :setlocal filetype=nix
autocmd BufEnter *.md :setlocal filetype=markdown

function! AuFileTypeSass()
    setlocal shiftwidth=4
endfunction
autocmd vimrc FileType sass call AuFileTypeSass()

function! AuFileTypeMarkdown()
    " :help fo-table
    setlocal formatoptions-=t
    setlocal textwidth=80
endfunction
autocmd vimrc FileType markdown call AuFileTypeMarkdown()

function! AuFileTypeSvg()
    setlocal nowrap
endfunction
autocmd vimrc FileType svg call AuFileTypeSvg()

function! AuFileTypeTwig()
    setlocal filetype=html
endfunction
autocmd vimrc FileType twig call AuFileTypeTwig()

function! AuFileTypeGitCommit()
    " Enables spell-checker for commit messages.
    setlocal spell

    " Don't be weird with colors.
    hi clear gitcommitSummary
    hi clear gitcommitOverflow
endfunction
autocmd vimrc FileType gitcommit call AuFileTypeGitCommit()

function! AuFileTypeVim()
    set textwidth=100
endfunction
autocmd vimrc FileType vim call AuFileTypeVim()

function! AuColorColumn()
  if &filetype == 'gitcommit'
    call SetColorColumn(51) " http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
  elseif &filetype == 'help'
    call SetColorColumn(79)
  elseif &filetype == 'markdown'
    call SetColorColumn(81)
  else
    call SetColorColumn(0)
  endif
endfunction
autocmd vimrc FileType * call AuColorColumn()

function! AuGrepper()
    " Sets Grepper window height to 20 lines.
    exe ':resize 20'
endfunction
autocmd vimrc User Grepper call AuGrepper()

function! AuFileTypeTagbar()
    nnoremap <buffer> <Backspace> :TagbarClose<CR>
endfunction
autocmd vimrc FileType tagbar call AuFileTypeTagbar()

function! AuVimEnter()
    autocmd vimrc BufReadPost * call AuBufReadPost()
endfunction
autocmd vimrc VimEnter * call AuVimEnter()

" }}}

" Colors {{{

set background=dark

let g:one_allow_italics = 1

colorscheme one

highlight Comment cterm=italic

let mono_1 = '#abb2bf'
let mono_3 = '#5c6370'
let syntax_bg = '#282c34'
let syntax_cursor = '#2c323c'
let syntax_accent = '#528bff'
let special_grey = '#3b4048'

exe 'hi TabLine guibg=' . syntax_cursor . ' guifg= ' . mono_1
exe 'hi TabLineFill guibg=' . syntax_bg . ' guifg= ' . mono_1
exe 'hi TabLineSel guibg=' . special_grey . ' guifg= ' . mono_1

exe 'hi QuickFixLine guibg=' . special_grey . ' guifg= ' . mono_1

exe 'hi SignatureMarkText guifg=' . syntax_accent

exe 'hi Sneak guibg= ' . syntax_accent

" }}}

" Experiments {{{

" Here be dragons!

autocmd vimrc VimResized * exe "redraw!"

" https://github.com/vim/vim/issues/4738
nmap gx yiW:!open <cWORD><CR><CR>

let g:mkdp_open_to_the_world = 1
let g:mkdp_port = '7777'
let g:mkdp_page_title = 'Md: ${name}'
let g:mkdp_browserfunc = 'g:Mkdp_browserfunc'

function g:Mkdp_browserfunc(url)
  echom a:url
  call Copy(a:url)
endfunction

function! Md()
    exe ':MarkdownPreview'
endfunction
command! Md call Md()

lua <<EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = {
    "bash",
    "c",
    "c_sharp",
    "clojure",
    "cmake",
    "comment",
    "cpp",
    "css",
    "dart",
    "dockerfile",
    "go",
    "html",
    "java",
    "javascript",
    "json",
    "lua",
    "nix",
    "php",
    "python",
    "regex",
    "rst",
    "ruby",
    "rust",
    "scss",
    "toml",
    "typescript",
    "yaml",
  },
  highlight = {
    enable = true,
  },
  indent = {
    enable = true
  }
}
EOF

" }}}

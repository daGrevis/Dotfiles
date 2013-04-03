" Current plugins:
"
" * Ack,
" * CoffeeScript,
" * Commentary,
" * CtrlP,
" * EasyMotion,
" * Fugitive,
" * Gitgutter,
" * MatchTag,
" * NERDTree,
" * Powerline,
" * Repeat,
" * Sensible,
" * Supertab,
" * Surround,
" * Syntastic,
" * Tagbar,
" * UltiSnips,
" * Zen-coding;
"
" Other dependencies
"
" * Color scheme,
" * Linux and these packages:
"   * `ctags` (for Tagbar),
"   * `ack` (for Ack),
"   * `vpaste.sh` (for pasting with <Leader>z),
"   * Code linters (for Syntastic),
"   * Patched font (for Powerline);
"
" Tested on Arch Linux.


" Loads plugins (in .vim/bundle/).
call pathogen#infect()

" Sets fave color scheme.
colorscheme hornet

" Sets limit of history.
set history=5000

" Disables things I don"t need yet.
map Q <Nop>
map K <Nop>

" Shows relative line numbers.
set relativenumber

" Highlights line which is active.
set cursorline

" Column after which coding is very bad.
set colorcolumn=160

" Fix broken Vim regexes.
nnoremap / /\v
vnoremap / /\v
nnoremap ? ?\v
vnoremap ? ?\v

" Always assume that it's global search and replace.
set gdefault

" Highlights all found results as you type in.
set hlsearch

" Ignore case when searching unless you type uppercase and lowercase letters.
set ignorecase
set smartcase

" Clears highlights for search results.
nnoremap <C-l> :let @/ = ""<CR>

" Wrap-friendly <j> and <k> keys.
nnoremap j gj
nnoremap k gk

" Mappings for controlling tabs.
noremap <M-a> :tabprevious<CR>
noremap <M-s> :tabnext<CR>

" Pastes contents to vpaste.net.
map <Leader>zz :exec "w !vpaste ft=".&ft<CR>
vmap <Leader>zz <ESC>:exec "'<,'>w !vpaste ft=".&ft<CR>

" Maps <S> key to toggling NERDTree.
nmap <Tab> :NERDTreeToggle<CR>

" Maps <S-Tab> to toggling Tagbar.
nmap <S-Tab> :TagbarToggle<CR> :wincmd b<CR>

" Disables spell-check by default, but allows to toggle with a function.
set nospell
function! SpellToggle()
    if(&spell == 1)
        set nospell
    else
        set spell
    endif
endfunc

" Maps <Leader>s to toggling spell-check.
noremap <Leader>s :call SpellToggle()<CR>

" Ignores files that match these patters.
set wildignore=*.pyc,*.png,*.gif,*.jpeg,*.jpg,*.ico

" Saves file when the focus is lost (for example, when buffers are changed).
autocmd BufLeave,FocusLost * silent! wall

" Maps <Leader>c to yanking whole file.
nmap <Leader>c ggVGy

" Maps <Leader>v to pasting all over previous file.
nmap <Leader>v ggdG"0PGdd

" Maps <Right> to indenting text to the right, but <Left> to the left. Works
" in mode and vmode.
nmap <Left> <<
nmap <Right> >>
vmap <Left> <gv
vmap <Right> >gv

" Maps <Up> to spawning blank line above, but <Down> -- below.
nmap <Up> O<Esc>j
nmap <Down> o<Esc>k

" Maps <Leader>l to toggling characters that are not printable (like new-lines
" or tabs).
set listchars=tab:▸\ ,eol:¬
nmap <leader>l :set list!<CR>

" Tells to use 4 spaces for indentation.
set et
set ts=4
set sw=4
set sts=4

" Deletes all trailing whitespace after save.
autocmd BufWritePre * :%s/\s\+$//e

" Maps <Leader>p in imode to go in pmode.
inoremap <leader>p <C-o>:set paste<CR>
" Unsets pmode when leaving imode.
au InsertLeave * :set nopaste
" Fixes that InsertLeave event doesn"t catch <C-c> mapping.
inoremap <C-c> <Esc>

" Enable mouse in all modes. Next line makes me a bad person.
set mouse=a

" Maps <Leader>r to calling :registers.
noremap <Leader>r :registers<CR>

" Disables folding at all.
set nofen

" Emacs ways to change cursor in cmode (<C-a> to get to the start, but <C-e>
" -- to the end).
cmap <C-a> <Home>
cmap <C-e> <End>

" Almost like in Emacs -- only in the M place there is the C key. So <C-b> to
" move a word backward, but <C-f> -- forward.
cmap <C-b> <S-Left>
cmap <C-f> <S-Right>

" Saves and sources files (meant to be used in `.vimrc` file, but you can be
" creative too!).
nmap <Leader>x :w<CR> :so %<CR>

" Toggles between no numbers, numbers and relative numbers.
function! NumberToggle()
    if(&number == 1)
        set nonumber
    elseif(&relativenumber == 1)
        set number
    else
        set relativenumber
    endif
endfunc
" Mapping for calling `NumberToggle`.
noremap <Leader>n :call NumberToggle()<CR>

" Allows to use splits more quickly (Alt-{h,j,k,l,q,w}).
noremap <M-h> <C-w>h
noremap <M-j> <C-w>j
noremap <M-k> <C-w>k
noremap <M-l> <C-w>l
noremap <M-q> <C-w>s
noremap <M-w> <C-w>v

" Allows to quickly set color column using <Leader>cc.
noremap <Leader>cc :set colorcolumn=

" Allows to save files w/ superuser permissions.
cmap w!! %!sudo tee > /dev/null %

" If it's Git commit, do some specific ations.
func SetGitCommitOptions()
    setlocal colorcolumn=72
    setlocal spell
endfunc
autocmd Filetype gitcommit call SetGitCommitOptions()

" Tells Powerline to use fancy symbols.
let g:Powerline_symbols = "fancy"

" Executes Syntastic when buffer is opened.
let g:syntastic_check_on_open=1

" Tells Syntastic to set line length to 160 symbols as maximum.
let g:syntatic_python_pyflakes_args="--max-line-length=160"

" Opens file in new tab when using CtrlP.
let g:ctrlp_prompt_mappings = {
    \ 'AcceptSelection("e")': ['<c-t>'],
    \ 'AcceptSelection("t")': ['<cr>', '<2-LeftMouse>'],
    \ }

" Shows CtrlP on top.
let g:ctrlp_match_window_bottom=0

noremap <Leader>q :SyntasticToggleMode<CR> :redraw!<CR>

" Allows to quickly change color schemes.
noremap <Leader>[ :StylishPrev<CR>
noremap <Leader>] :StylishNext<CR>
noremap <Leader>' :StylishRand<CR>

if has("gui_running")

    " Removes all GUI stuff.
    set guioptions=

    " Tells to always use block-style cursor.
    set guicursor=a:block

    " Allows copying/pasting in GVim using <C-c> and <C-p>.
    nmap <C-v> "+gp
    imap <C-v> <Esc><C-v>i
    vmap <C-c> "+y
    cmap <C-v> <C-r>*
    " To copy from cmode, type `q:` and copy a command from there.
    " To copy from smode, type `q/` and copy a phrase from there.

    " Sets font.
    set guifont=Andale\ Mono\ for\ Powerline\ 12px

    " I love extra whitespace!
    set linespace=6

    " Some fixes to color scheme.
    autocmd ColorScheme * hi TabLine guibg=#303030
    autocmd ColorScheme * hi TabLineFill guifg=#303030

endif

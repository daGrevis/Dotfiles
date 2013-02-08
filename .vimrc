" Current plugins:
"
" * Powerline,
" * Supertab,
" * Syntastic,
" * Commentary,
" * MatchTag,
" * Surround,
" * Fugitive,
" * NERDTree,
" * Tagbar,
" * Repeat,
" * Sensible;
"
" Other dependencies
"
" * Common sense,
" * Solarized (color scheme),
" * Linux and these packages:
"   * `vpaste` (for pasting with <Leader>vp),
"   * Code linters (for Syntastic),
"   * Patched font (for Powerline);
"
" Tested on Arch Linux.


" Loads plugins (in .vim/bundle/).
call pathogen#infect()

" Sets fave color scheme.
colorscheme solarized

" Sets limit of history.
set history=10000

" Disables things I don't need yet.
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
set smartcase

" Clears highlights for search results.
nnoremap <C-l> :let @/ = ""<CR>

" Wrap-friendly <j> and <k> keys.
nnoremap j gj
nnoremap k gk

" Unwanted help is bad. Lets assume that user wanted to press <ESC>.
map <F1> <ESC>

" I don't like to hold <S> key.
nore ; :

" Mappings for controlling tabs.
noremap <C-j> :tabprevious<CR>
noremap <C-k> :tabnext<CR>

" Pastes contents to vpaste.net.
map <Leader>vp :exec "w !vpaste ft=".&ft<CR>
vmap <Leader>vp <ESC>:exec "'<,'>w !vpaste ft=".&ft<CR>

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

" Emacs ways to change cursor in cmode (<C-a> to get to the start, but <C-e>
" -- to the end).
cmap <C-a> <Home>
cmap <C-e> <End>

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
" Fixes that InsertLeave event doesn't catch <C-c> mapping.
inoremap <C-c> <Esc>

" Enable mouse in all modes. Copy out from Vim holding <S> while highlighting
" text.
set mouse=a

" Maps <Leader>r to calling :registers.
noremap <Leader>r :registers<CR>

" Disables folding at all.
set nofen

" Tells Powerline to use fancy symbols.
let g:Powerline_symbols = "fancy"

" Tells Syntastic to set line length to 160 symbols as maximum.
let g:syntatic_python_pyflakes_args="--max-line-length=160"

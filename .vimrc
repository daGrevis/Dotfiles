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
" Other depencdencies:
"
" * Common sense,
" * Solarized (color scheme),
" * Linux and these packages:
"   * xclip (for `:Share`),
"   * Code linters (for Syntastic);
"
" Tested on Arch Linux.


" Loads plugins (in .vim/bundle/).
call pathogen#infect()

" Sets fave color schema.
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

" Ignore case when searching.
set ignorecase

" Clears highlights.
nnoremap <C-l> :let @/ = ""<CR>:redraw!<CR>

" Wrap-friendly <j> and <k> keys.
nnoremap j gj
nnoremap k gk

" Unwatned help is bad.
map <F1> <ESC>

" I don't like to hold <S> key.
nore ; :

" Mappings for controling tabs.
noremap <C-j> :tabprevious<CR>
noremap <C-k> :tabnext<CR>

" Pastes contents to vpaste.net.
map <Leader>vp :exec "w !vpaste ft=".&ft<CR>
vmap <Leader>vp <ESC>:exec "'<,'>w !vpaste ft=".&ft<CR>

" Maps <S> key to NERDTree.
nmap <Tab> :NERDTreeToggle<CR>

" Maps <S-Tab> to Tagbar.
nmap <S-Tab> :TagbarToggle<CR> :wincmd b<CR>

" Disables spell-check by default, but allows to toggle it w/ F2.
set nospell
function! SpellToggle()
    if(&spell == 1)
        set nospell
    else
        set spell
    endif
endfunc

" Maps \s to enabling or disabling spelling hints.
noremap <Leader>s :call SpellToggle()<CR>

" Ignores files that match these patters.
set wildignore=*.pyc

" Getting to beggining or end of the line in command mode like it's in terminal (Emacs way).
cmap <C-a> <Home>
cmap <C-e> <End>

" Saves file when the focus is lost.
autocmd BufLeave,FocusLost * silent! wall

" Maps \c to yanking whole file.
nmap <Leader>c ggVGy

" Maps \v to pasting all over previous file.
nmap <Leader>v ggdG"0PGdd

" Maps → to moving text to the right, but ← to the left.
nmap <Left> <<
nmap <Right> >>
vmap <Left> <gv
vmap <Right> >gv

" Maps ↑ to spawning blank line above, but ↓ below.
nmap <Up> O<Esc>j
nmap <Down> o<Esc>k

" Shows invisibles and adds mapping for toggling between showing invisibles or not.
set listchars=tab:▸\ ,eol:¬
nmap <leader>l :set list!<CR>

" Tells Vim to use 4 spaces for indentation.
set et
set ts=4
set sw=4
set sts=4

" Deletes all trailing whitespace after save.
autocmd BufWritePre * :%s/\s\+$//e

" Maps \p in imode to go in paste mode.
inoremap <leader>p <C-o>:set paste<CR>
" Unsets paste when leaving imode.
au InsertLeave * :set nopaste
" Fixes that InsertLeave event doesn't catch C-c binding.
inoremap <C-c> <Esc>

" Enable mouse in all modes.
set mouse=a

" Maps \r to :registers.
noremap <Leader>r :registers<CR>

" Disables folding.
set nofen

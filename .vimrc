" Current plugins:
"
" * Powerline,
" * Supertab,
" * Syntastic,
" * Commentary,
" * Rainbow parentheses,
" * MatchTag,
" * Surround,
" * Fugitive,
" * NERDTree,
" * Tagbar,
" * Repeat,
" * CtrlP,
" * Snipmate,
" * Dwm,
" * Sensible;
"
" Other depencdencies:
"
" * Common sense,
" * Tomorrow (color scheme),
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

" Clears highlights.
nnoremap <CR> :let @/ = ""<CR>

" Wrap-friendly <j> and <k> keys.
nnoremap j gj
nnoremap k gk

" Unwatned help is bad.
map <F1> <ESC>

" I don't like to hold <S> key.
nore ; :

" Mappings for controling tabs.
noremap <Esc>j gT
noremap <Esc>k gt

" Pastes contents to sprunge.us. Call it with :Share.P.S. Thanks, @laadinjsh!
let s:cmd = system("uname -s | tr -d '\n'") == "Darwin" ? "pbcopy" : "xclip"
exec 'command! -range=% Share :<line1>,<line2>write !curl -sF "sprunge=<-" http://sprunge.us|'.s:cmd

" Maps <S> key to NERDTree.
nmap <Tab> :NERDTreeToggle<CR>

" Maps <S-Tab> to Tagbar.
nmap <S-Tab> :TagbarToggle<CR> :wincmd b<CR>

" Auto sets filetype to HTML for *.html files.
au BufRead *.html set filetype=html

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

" Turn on spell-checking in text files.
au BufRead,BufNewFile *.txt,*.markdown,*.mdown,*.md,*.textile,*.rdoc,*.org,*.creole,*.mediawiki,*.rst,*.asciidoc,*.pod setlocal spell

" Don't add the comment prefix when I hit enter or o, O on a comment line.
set formatoptions-=or

" Maps → to moving text to the right, but ← to the left.
nmap <Left> <<
nmap <Right> >>
vmap <Left> <gv
vmap <Right> >gv

" Maps ↑ to spawning blank line above, but ↓ below.
nmap <Up> O<Esc>j
nmap <Down> o<Esc>k

" Faster ways to set numbers. relative numbers or no numbers. Press \n.
function! NumberToggle()
    if(&number == 1)
        set nonumber
    elseif(&relativenumber == 1)
        set number
    else
        set relativenumber
    endif
endfunc
nnoremap <Leader>n :call NumberToggle()<CR>

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

" Flake8 settings.
let g:syntastic_python_checker_args = "--max-line-length=160"
let g:syntastic_check_on_open = 1

" Conf for Rainbow plugin.
au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces
" Maps \r to toggling Rainbow and unicorns.
noremap <Leader>r :RainbowParenthesesToggle<CR>

" Maps \h to MRU split.
noremap <Leader>h :CtrlPMRUFiles<CR>

" Disables original Dwm mappings and remaps them. Done because by default Ctrl+c closed current split, but I use it to exit to normal mode.
let g:dwm_map_keys = 0
noremap <C-n> :call DWM_New()<CR>
noremap <C-l> :call DWM_GrowMaster()<CR>
noremap <C-h> :call DWM_ShrinkMaster()<CR>
noremap <Esc>l <C-w>l
noremap <Esc>h <C-w>h

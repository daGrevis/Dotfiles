nnoremap <Silent> <Buffer> ]] :call <SID>Custom_jump('/^\(class\)')<CR>
nnoremap <Silent> <Buffer> [[ :call <SID>Custom_jump('?^\(class\)')<CR>
nnoremap <Silent> <Buffer> ]m :call <SID>Custom_jump('/^\s*\([-=]>\)')<CR>
nnoremap <Silent> <Buffer> [m :call <SID>Custom_jump('?^\s*\([-=]>\)')<CR>

" Haskell
let g:necoghc_enable_detailed_browse = 1

" YouCompleteMe
let g:ycm_filetype_whitelist = { 'cpp':1, 'c':1, 'python':1 }
map <Leader>ycm <ESC>:let g:ycm_filetype_whitelist = {'*':1}<CR>:e<CR>
let g:ycm_global_ycm_extra_conf = $HOME . "/.vim/bin/ycm_extra_conf.py"

" Syntastic
let g:syntastic_mode_map = { 'mode' : 'passive', 'active_filetypes' : [], 'passive_filetypes' : [] }
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
map <Leader>c <ESC>:w<CR>:SyntasticCheck<CR>

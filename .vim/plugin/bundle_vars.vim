" YouCompleteMe
let g:ycm_global_ycm_extra_conf = $HOME . "/.vim/bin/ycm_extra_conf.py"
let g:ycm_filetype_whitelist = {
\   'c'      : 1,
\   'cpp'    : 1,
\   'python' : 1,
\   'rust'   : 1,
\   'haskell': 1,
\   'ocaml'  : 1,
\}
map <Leader>ycm <ESC>:let g:ycm_filetype_whitelist = {'*':1}<CR>:e<CR>
map <Leader>jd  <ESC>:YcmCompleter GoTo<CR>
map <Leader>x   <ESC>:YcmCompleter GetType<CR>

" ALE
let g:ale_enabled = 0
let g:ale_lint_on_enter = 0
let g:ale_lint_on_text_changed = 'never'
let g:ale_fixers = {
\   'c'    : ['clang-format'],
\   'cpp'  : ['clang-format'],
\   'rust' : ['rustfmt'],
\}
map <F5>        <Plug>(ale_toggle)
map <Leader>ale <Plug>(ale_toggle)
map <Leader>c   <Plug>(ale_lint)
map <Leader>f   <Plug>(ale_fix)
map <Leader>Jd  <Plug>(ale_go_to_definition)

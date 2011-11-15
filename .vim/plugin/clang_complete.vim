" To install clang_complete, run:
"   $> mkdir -p ~/.vim/opt && cd ~/.vim/opt && git clone https://github.com/Rip-Rip/clang_complete.git
"
" Make sure the clang compiler is installed.

let g:clang_complete_copen = 1
runtime! opt/clang_complete/plugin/clang_complete.vim


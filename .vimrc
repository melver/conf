
" Functions {{{
    function ToggleList()
      if !exists("b:toggle_list")
        let b:toggle_list = 1 " disable by default if not existing
      endif

      if b:toggle_list == 0
        set list
        let b:toggle_list = 1
        echo "List chars ON!"
      else
        set nolist
        let b:toggle_list = 0
        echo "List chars OFF!"
      endif
    endfunction

    function SetList(toset)
      if a:toset == 0
        set nolist
        let b:toggle_list = 0
      else
        set list
        let b:toggle_list = 1
      endif
    endfunction

    " Source: http://weevilgenius.net/2010/07/vim-tip-highlighting-long-rows/
    function ToggleOverLengthHi(silent)
      if exists("b:overlengthhi") && b:overlengthhi
        highlight clear OverLength
        let b:overlengthhi = 0

        if a:silent == 0
          echo "[ToggleOverLengthHi] OverLength highlight OFF"
        endif
      else
        " adjust colors/styles as desired
        highlight OverLength ctermbg=darkred gui=undercurl guisp=blue
        " change '81' to be 1+(number of columns)
        match OverLength /\%81v.\+/
        let b:overlengthhi = 1

        if a:silent == 0
          echo "[ToggleOverLengthHi] OverLength highlight ON"
        endif
      endif
    endfunction

    function ExecuteCursorFile()
      let l:file_name = expand(expand("<cfile>"))
      let l:is_url = stridx(l:file_name, "://") >= 0

      " If not existing, it might a file relative to file being edited but the
      " working directory is not the directory of the file being edited.
      if !l:is_url && !filereadable(l:file_name)
        let l:file_name = expand("%:p:h") . "/" . l:file_name
      endif

      if l:is_url || filereadable(l:file_name)
        execute "silent !xdg-open '" . l:file_name . "' &> /dev/null &"
        redraw!
        echo "[ExecuteCursorFile] Opened '" . l:file_name . "'"
      else
        echo "[ExecuteCursorFile] File '" . l:file_name . "' does not exist!"
      endif
    endfunction

    function FindTabStyle(prev_line_regex)
      let l:found = 0

      for line in getline(1, 500)
        if l:found
          " Check if valid line to test for indendation style
          if line =~ "^[ \t][ \t]*[^ \t]"
            if line =~ "^\t"
              set noet
              echo "[FindTabStyle] No expand tab!"
            else " must be space
              let l:spaces = 0
              while line[l:spaces] == " "
                let l:spaces += 1
              endwhile
              execute "set ts=" . l:spaces
              execute "set sw=" .  l:spaces
              execute "set sts=" . l:spaces
              set et

              echo "[FindTabStyle] Expand tabs with " . l:spaces . " spaces!"
            endif

            " done
            break
          else
            " continue search
            let l:found = 0
          endif
        endif

        if line =~ a:prev_line_regex
          let l:found = 1
        endif
      endfor
    endfunction
" }}}

" Basics {{{
    set nocompatible " get out of vi-compatible mode
    set noexrc " do not execute vimrc in local dir
    set cpoptions=aABceFs " vim defaults
    syntax on " syntax highlighting on
" }}}

" General {{{
    if has("autocmd")
      filetype plugin indent on
    else
      set autoindent
    endif " has("autocmd")

    set encoding=utf-8
    set backspace=indent,eol,start
    set fileformats=unix,dos,mac
    set hidden

    if has("mouse") && !exists("no_mouse_please")
      set mouse=a
    endif

    set noerrorbells
    set whichwrap=b,s,<,>

    if isdirectory($HOME . "/.vim")
      set spellfile=~/.vim/spellfile.add
    else
      set spellfile=~/.vimspellfile.add
    endif

    set spelllang=en
" }}}

" Vim UI {{{
    set laststatus=2

    set nolist " show unwanted chars
    let b:toggle_list = 0
    if v:version >= 700
      set listchars=tab:»·,trail:·
    else
      set listchars=tab:>-,trail:-
    endif

    " set showmatch
    " set matchtime=5
    set novisualbell
    set report=0
    set ruler
    set scrolloff=3
    set showcmd
    set statusline=%F%m%r%h%w[%L][%{&ff}]%y[%p%%][%04l,%04v]
    set titlestring=[%{hostname()}]%(\ %)%t%(\ %M%)%(\ (%{expand(\"%:.:h\")})%)%(\ %a%)%(\ -\ VIM%)
    set incsearch
    set hlsearch
" }}}

" Default Text Formatting {{{
    "set formatoptions=rq " Automatically insert comment leader on return
    set wrap
    "set tabstop=8
    "set shiftwidth=4
    "set softtabstop=4
    "set textwidth=0
    "set expandtab
" }}}

" Folding {{{
    set foldenable
    set foldmarker={{{,}}}
    set foldmethod=marker
    set foldlevel=0
" }}}

" Plugins {{{
    " NERDTree {{{
      let g:NERDTreeBookmarksFile = $HOME . "/.vim/.NERDTreeBookmarks"
      let g:NERDTreeWinSize=28
    " }}}
" }}}

" Mappings {{{
    " Fold toggle
    map <C-F> za

    " Fold close all - zR to unfold all
    "map <C-F> zM

    map <C-H> <ESC>:noh<CR>

    imap <S-CR> <ESC>

    " NERDTree plugin; redraw! hack required for gvim in tiling WM
    map <C-N> <ESC>:NERDTreeToggle<Bar>redraw!<Bar>redraw!<CR>

    " taglist plugin
    map <C-T> <ESC>:TlistToggle<CR>

    map <C-L> <ESC>:call ToggleOverLengthHi(0)<CR>

    " Function keys
    map <F5> <ESC>:call g:ClangUpdateQuickFix()<CR>
    map <F9> <ESC>:call ToggleList()<CR>
    map <F10> <ESC>:call ToggleList()<CR>

    " Open file under cursor with xdg-open
    map xf <ESC>:call ExecuteCursorFile()<CR>
" }}}

" Autocommands {{{
    augroup me_python
      au!
      au BufRead,BufNewFile *.py,*.pyw setf python
      au FileType python set ts=8 | set sw=4 | set sts=4 | set et | call SetList(1) | call ToggleOverLengthHi(1)
      au BufNewFile *.py,*.pyw set fileformat=unix
    augroup END

    augroup me_ccppobjc
      au!
      au FileType c    set ts=8 | set sw=8 | set sts=8 | set noet | call SetList(0) | call FindTabStyle("{$") | call ToggleOverLengthHi(1)
      au FileType cpp  set ts=4 | set sw=4 | set sts=4 | set noet | call SetList(0) | call FindTabStyle("{$") | call ToggleOverLengthHi(1)
      au FileType objc set ts=4 | set sw=4 | set sts=4 | set noet | call SetList(0) | call FindTabStyle("{$") | call ToggleOverLengthHi(1)
      au BufNewFile *.c,*.cpp,*.h,*.hpp set fileformat=unix
    augroup END

    augroup me_java
      au!
      au BufRead,BufNewFile *.java set ts=4 | set sw=4 | set sts=4 | set noet | call SetList(0) | call FindTabStyle("{$")
      au BufNewFile *.java set fileformat=unix
    augroup END

    augroup me_sh
      au!
      au FileType sh,bash,zsh set ts=4 | set sw=4 | set sts=4 | set noet | call SetList(0)
    augroup END

    augroup me_perl
      au!
      au FileType perl set ts=8 | set sw=4 | set sts=4 | set et | call SetList(0) | call FindTabStyle("{$") | call ToggleOverLengthHi(1)
      au BufNewFile *.pl set fileformat=unix
    augroup END

    augroup me_vim
      au!
      au FileType vim set ts=8 | set sw=2 | set sts=2 | set et | set ai | call SetList(1)
      au BufNewFile *.vim,*vimrc set fileformat=unix
    augroup END

    augroup me_dot
      au!
      au FileType dot set ts=4 | set sw=4 | set sts=4 | set noet | set ai | call SetList(0)
      au BufNewFile *.dot set fileformat=unix
    augroup END

    augroup me_tex
      au!
      au FileType tex,plaintex set ts=2 | set sw=2 | set sts=2 | set et | set ai | set tw=79 | set spell | call SetList(1) | call ToggleOverLengthHi(1)
      au BufNewFile *.tex set fileformat=unix
    augroup END

    augroup me_bibtex
      au!
      au FileType bib set ts=2 | set sw=2 | set sts=2 | set et | set ai | set tw=79 | set foldmarker=@,}. | call SetList(1)
      au BufNewFile *.bib set fileformat=unix
    augroup END

    augroup me_sql
      au!
      au FileType sql set ts=4 | set sw=2 | set sts=2 | set et | call SetList(1)
      au BufNewFile *.sql set fileformat=unix
    augroup END

    augroup me_text
      au!
      au BufRead,BufNewFile *README*,*INSTALL*,*TODO* set ts=4 | set sw=4 | set sts=4 | set tw=79 | set et | call SetList(0)
    augroup END

    augroup me_slice
      au!
      au FileType slice set ts=4 | set sw=4 | set sts=4 | set et | set ai | call SetList(0)
      au BufNewFile *.ice set fileformat=unix
    augroup END

    augroup me_haskell
      au!
      au FileType haskell set ts=8 | set sw=4 | set sts=4 | set et | call SetList(1) | call ToggleOverLengthHi(1)
      au BufNewFile *.hs set fileformat=unix
    augroup END

    augroup me_htmlcss
      au!
      au FileType html,xhtml,css set ts=2 | set sw=2 | set sts=2 | set tw=79 | set noet | call SetList(0)
      au BufNewFile *.htm,*.html,*.css set fileformat=unix
    augroup END

    augroup me_js
      au!
      au FileType javascript set ts=4 | set sw=4 | set sts=4 | set noet | call SetList(0) | call FindTabStyle("{$")
      au BufNewFile *.js set fileformat=unix
    augroup END

    augroup me_php
      au!
      " [fo]rmatoptions is set to allow text-wrap like in HTML files.
      au FileType php set ts=2 | set sw=2 | set sts=2 | set tw=79 | set fo=tqrowcb | set noet | call SetList(0)
      au BufNewFile *.php set fileformat=unix
    augroup END

    augroup me_xmlant
      au!
      au FileType xml,ant set ts=2 | set sw=2 | set sts=2 | set noet | call SetList(0)
      au BufNewFile *.xml set fileformat=unix
    augroup END

    augroup me_rst
      au!
      au FileType rst set ts=8 | set sw=4 | set sts=4 | set tw=79 | set et | set spell | call SetList(1) | call ToggleOverLengthHi(1)
      au BufNewFile *.rst set fileformat=unix
    augroup END

    augroup me_cmake
      au!
      au BufRead,BufNewFile *.cmake,CMakeLists.txt setf cmake
      au FileType cmake set ts=8 | set sw=4 | set sts=4 | set et | call SetList(1)
      au BufNewFile *.cmake,CMakeLists.txt set fileformat=unix
    augroup END

    augroup me_hdl
      au!
      au FileType verilog set ts=3 | set sw=3 | set sts=3 | set noet | call SetList(0) | call ToggleOverLengthHi(1)
      au BufNewFile *.v set fileformat=unix
    augroup END

    augroup me_lua
      au!
      au FileType lua set ts=4 | set sw=4 | set sts=4 | set et | call SetList(1)
    augroup END

" }}}

" GUI/Term Specific Settings {{{
    if has("gui_running")
      " GUI {{{
      " Set font, based on preference and if available:
      if exists("use_alt_font")
        set guifont=Inconsolata\ 13
      else
        set guifont=Monospace\ 11
      endif

      set columns=120
      set lines=45
      set mousehide

      "set guioptions=aegimrLt
      set guioptions=aegiLt

      "set background=dark
      colorscheme desertEx

      " GUI Mappings {
        " Toggle menubar
        nnoremap <C-F1> :if &go=~#'m'<Bar>set go-=m<Bar>else<Bar>set go+=m<Bar>endif<CR>

        " Toggle scrollbar
        nnoremap <C-F2> :if &go=~#'r'<Bar>set go-=r<Bar>else<Bar>set go+=r<Bar>endif<CR>

        " Toggle toolbar
        nnoremap <C-F3> :if &go=~#'T'<Bar>set go-=T<Bar>else<Bar>set go+=T<Bar>endif<CR>

        " Copy/Paste
        vmap <C-M-C> "+y
        nmap <C-M-V> "+gP
      " }
      " }}}
    else
      " Terminal {{{
      set background=dark

      " Terminal color palette; shouldn't need to set this, as vim detects
      " this properly if TERM=xterm-256color is set by terminal emulator.
      "set t_Co=256

      colorscheme wombat256 " Should override background if neccessary
      " }}}
    endif
" }}}

" Marco's .vimrc modeline {{{
"   vim: set ts=8 sw=2 sts=2 et ai foldmarker={{{,}}} foldlevel=0 fen fdm=marker:
" }}}


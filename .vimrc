" Marco's .vimrc Modline {
"   vim: set ts=8 sw=2 sts=2 et ai foldmarker={,} foldlevel=0 fen fdm=marker:
" }

" Functions {
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
" }

" Basics {
    set nocompatible " get out of vi-compatible mode
    set noexrc " do not execute vimrc in local dir
    set background=light
    set cpoptions=aABceFs " vim defaults
    syntax on " syntax highlighting on
" }

" General {
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
" }

" Vim UI {
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
    set incsearch
    set hlsearch
" }

" Default Text Formatting {
    "set formatoptions=rq " Automatically insert comment leader on return
    set wrap
    "set tabstop=8
    "set shiftwidth=4
    "set softtabstop=4
    "set textwidth=0
    "set expandtab
" }

" Folding {
    set foldenable
    set foldmarker=#[#,#]#
    set foldmethod=marker
    set foldlevel=100
" }

" Plugins {
    " MiniBufExplorer {
      let g:miniBufExplMapWindowNavArrows = 1
      let g:miniBufExplMapCTabSwitchBufs = 1
      let g:miniBufExplModSelTarget = 1
    " }
" }

" Mappings {
    map <C-T> <ESC>:Tlist<CR>
    map <C-N> <ESC>:NERDTreeToggle<CR>

    " Toggle list chars
    map <F12> <ESC>:call ToggleList()<CR>

    " Fold toggle
    map <C-F> za

    " Fold close all - zR to unfold all
    "map <C-F> zM

    map ä <ESC>:noh<CR>

    "imap ö #[#
    "imap ä #]#
" }

" Autocommands {
    augroup me_python
      au!
      au BufRead,BufNewFile *.py,*.pyw setf python
      au FileType python set ts=8 | set sw=4 | set sts=4 | set et | call SetList(1)
      au BufNewFile *.py,*.pyw set fileformat=unix
    augroup END

    augroup me_ccppobjc
      au!
      au BufRead,BufNewFile *.c,*.cpp,*.h,*.hpp set ts=4 | set sw=4 | set sts=4 | set noet | call SetList(0)
      au FileType objc                          set ts=4 | set sw=4 | set sts=4 | set noet | call SetList(0)
      au BufNewFile *.c,*.cpp,*.h,*.hpp set fileformat=unix
    augroup END

    augroup me_java
      au!
      au BufRead,BufNewFile *.java set ts=4 | set sw=4 | set sts=4 | set noet | call SetList(0)
      au BufNewFile *.java set fileformat=unix
    augroup END

    augroup me_sh
      au!
      au FileType sh,bash,zsh set ts=4 | set sw=4 | set sts=4 | set noet | call SetList(0)
    augroup END

    augroup me_perl
      au!
      au FileType perl set ts=4 | set sw=4 | set sts=4 | set et | call SetList(0)
      au BufNewFile *.pl set fileformat=unix
    augroup END

    augroup me_vim
      au!
      " Unmap ö and ä so it can be used in vimrc, list is on by default
      "au BufRead,BufNewFile *vimrc iunmap ö| iunmap ä| call SetList(1)
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
      au FileType tex,bib,plaintex set ts=4 | set sw=4 | set sts=4 | set et | set tw=79 | set spell | call SetList(1)
      au BufNewFile *.tex set fileformat=unix
    augroup END

    augroup me_sql
      au!
      au FileType sql set ts=4 | set sw=2 | set sts=2 | set et | call SetList(1)
      au BufNewFile *.sql set fileformat=unix
    augroup END

    augroup me_text
      au!
      au BufRead,BufNewFile *.txt,README*,INSTALL*,*TODO set ts=4 | set sw=4 | set sts=4 | set tw=79 | set et | call SetList(0)
    augroup END

    augroup me_slice
      au!
      au FileType slice set ts=4 | set sw=4 | set sts=4 | set et | set ai | call SetList(0)
      au BufNewFile *.ice set fileformat=unix
    augroup END

    augroup me_haskell
      au!
      au FileType haskell set ts=8 | set sw=4 | set sts=4 | set et | call SetList(1)
      au BufNewFile *.hs set fileformat=unix
    augroup END

    augroup me_htmlcssjs
      au!
      au FileType html,xhtml,css,javascript set ts=2 | set sw=2 | set sts=2 | set noet | call SetList(0)
      au BufNewFile *.htm,*.html,*.css,*.js set fileformat=unix
    augroup END

    augroup me_xmlant
      au!
      au FileType xml,ant set ts=2 | set sw=2 | set sts=2 | set noet | call SetList(0)
      au BufNewFile *.xml set fileformat=unix
    augroup END

    augroup me_rst
      au!
      au FileType rst set ts=8 | set sw=4 | set sts=4 | set tw=79 | set et | set spell | call SetList(1)
      au BufNewFile *.rst set fileformat=unix
    augroup END

" }

" GUI Settings {
    if has("gui_running")
      set guifont=Monospace\ 12
      set columns=100
      set lines=35
      set mousehide
      set guioptions=aegimrLt
      "colorscheme soso
    endif
" }


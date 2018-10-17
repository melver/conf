"
" .vimrc
" Maintainer: Marco Elver <me AT marcoelver.com>
"

" Functions {{{
    function ToggleList()
      if !exists("b:toggle_list")
        let b:toggle_list = 0 " disabled by default if not existing
      endif

      if b:toggle_list == 0
        setlocal list
        let b:toggle_list = 1
        echo "List chars ON!"
      else
        setlocal nolist
        let b:toggle_list = 0
        echo "List chars OFF!"
      endif
    endfunction

    function SetList(toset)
      if a:toset == 0
        setlocal nolist
        let b:toggle_list = 0
      else
        setlocal list
        let b:toggle_list = 1
      endif
    endfunction

    function OverLengthHiOff()
      highlight clear OverLength
      let b:overlengthhi = 0

      " Remove autocommands
      execute "augroup OverLength_" . expand("%")
      execute "au!"
      execute "augroup END"
      execute "augroup! OverLength_" . expand("%")
    endfunction

    function OverLengthHiOn(length)
      if !exists("b:over_length")
        if a:length == 0
          let b:over_length = &textwidth
        else
          let b:over_length = a:length
        endif
      endif

      " adjust colors/styles as desired
      highlight OverLength ctermbg=darkred gui=undercurl guisp=blue
      " change '81' to be 1+(number of columns)
      let l:match_cmd = "match OverLength /\\%" . (str2nr(b:over_length)+1) . "v.\\+/"
      execute l:match_cmd

      let b:overlengthhi = 1

      " This is to ensure the highlighting is buffer-local, as match defaults
      " to window-local.
      execute "augroup OverLength_" . expand("%")
      execute "au!"
      execute "au BufWinEnter " . expand("%") . " highlight OverLength ctermbg=darkred gui=undercurl guisp=blue | " . l:match_cmd
      execute "au BufWinLeave " . expand("%") . " highlight clear OverLength"
      execute "augroup END"
    endfunction

    function ToggleOverLengthHi(length)
      if exists("b:overlengthhi") && b:overlengthhi
        call OverLengthHiOff()
        echo "[ToggleOverLengthHi] OverLength highlight OFF"
      else
        call OverLengthHiOn(a:length)
        echo "[ToggleOverLengthHi] OverLength highlight ON"
      endif
    endfunction

    function ToggleNumber()
      if !exists("b:toggle_number")
        let b:toggle_number = 0 " disabled by default if not existing
      endif

      if b:toggle_number == 0
        setlocal number
        setlocal relativenumber
        let b:toggle_number = 1
        echo "Line numbers ON!"
      else
        setlocal nonumber
        setlocal norelativenumber
        let b:toggle_number = 0
        echo "Line numbers OFF!"
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

        " If variale b:xf_cp set, will copy opened file to path.
        if !l:is_url && exists("b:xf_cp") && b:xf_cp != ""
          execute "!cp -v '" . l:file_name . "' '" . expand(b:xf_cp) . "'"
        endif
      else
        echo "[ExecuteCursorFile] File '" . l:file_name . "' does not exist!"
      endif
    endfunction

    function FindTabStyle2(prev_line_regex, ignore_line_regex)
      " Do not do anything if there is a modeline which includes tabstop
      if getline("$") =~ '[vV][iI][mM] *:.*\(ts\|tabstop\).*:' | return | endif

      let l:found = 0
      for line in getline(1, 500)
        if l:found
          " Check if valid line to test for indendation style
          if (a:ignore_line_regex == "" || line !~ a:ignore_line_regex)
                \ && line =~ "^[ \t][ \t]*[^ \t]"
            if line =~ "^\t"
              setlocal noet
              echom "[FindTabStyle] No expand tab!"
            else " must be space
              let l:spaces = 0
              while line[l:spaces] == " "
                let l:spaces += 1
              endwhile

              execute "setlocal ts=" . l:spaces
              execute "setlocal sw=" .  l:spaces
              execute "setlocal sts=" . l:spaces
              setlocal et

              echom "[FindTabStyle] Expand tabs with " . l:spaces . " spaces!"
            endif

            " done
            break
          else
            " If this is an empty line, try next one.
            if line !~ "^[ \t]*$"
              " continue search
              let l:found = 0
            endif
          endif
        endif

        if line =~ a:prev_line_regex
          let l:found = 1
        endif
      endfor
    endfunction

    function FindTabStyle(prev_line_regex)
      call FindTabStyle2(a:prev_line_regex, "")
    endfunction
" }}}

" Plugins {{{
    " Pathogen {{{
      if v:version < 800
        runtime! autoload/pathogen.vim
        if exists("*pathogen#infect")
          call pathogen#infect()
        endif
      endif
    " }}}

    " NERDTree {{{
      let g:NERDTreeBookmarksFile = $HOME . "/.vim/.NERDTreeBookmarks"
      let g:NERDTreeWinSize=28
    " }}}

    " UltiSnips {{{
      " Remap UltiSnips expand trigger, to free up TAB for autocompleters.
      let g:UltiSnipsExpandTrigger="<c-j>"
      let g:UltiSnipsJumpForwardTrigger="<c-j>"
      let g:UltiSnipsJumpBackwardTrigger="<c-k>"
    " }}}
" }}}

" General {{{
    set nocompatible " get out of vi-compatible mode
    set noexrc " do not execute vimrc in local dir
    set cpoptions=aABceFs " vim defaults

    set encoding=utf-8
    set backspace=indent,eol,start
    set fileformats=unix,dos,mac
    set hidden

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
    if has("mouse") && !exists("no_mouse_please")
      set mouse=a
    endif

    syntax on " syntax highlighting on

    " Show unwanted chars
    set nolist
    if v:version >= 700
      set listchars=tab:»·,trail:·
    else
      set listchars=tab:>-,trail:-
    endif

    "set showmatch
    "set matchtime=5
    set novisualbell
    set report=0
    set scrolloff=3
    set showcmd
    set ruler
    set laststatus=2
    set incsearch
    set hlsearch

    " Autocompletion
    set completeopt=menuone

    " Filename completion
    set wildmode=longest,list,full
    set wildmenu
" }}}

" Default Text Formatting {{{
    if has("autocmd")
      filetype plugin indent on
    else
      set autoindent
    endif " has("autocmd")

    "set formatoptions=rq " Automatically insert comment leader on return
    set wrap
" }}}

" Folding {{{
    set foldenable
    set foldmarker={{{,}}}
    set foldmethod=marker
    set foldlevel=0
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
    map <C-P> <ESC>:TlistToggle<CR>

    map <C-L> <ESC>:call ToggleOverLengthHi(80)<CR>

    " Function keys
    map <F8> <ESC>:call ToggleNumber()<CR>
    map <F9> <ESC>:call ToggleList()<CR>
    map <F10> <ESC>:echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
          \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
          \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

    " Open file under cursor with xdg-open
    map xf <ESC>:call ExecuteCursorFile()<CR>
" }}}

" GUI/Term Specific Settings {{{
    if !exists("disable_italic")
      let disable_italic = 0
    endif

    if has("gui_running")
      " GUI {{{
      " Set font, based on preference and if available:
      if has("win32")
        set guifont=Consolas:h11:cANSI
      else
        if exists("use_alt_font")
          set guifont=Monospace\ 11
        else
          set guifont=Terminus\ 12
          set linespace=1

          let disable_italic = 1
        endif
      endif

      set columns=120
      set lines=45
      set mousehide

      "set guioptions=aegimrLt
      set guioptions=aegit

      "set background=dark
      try
        colorscheme desertEx

        " Modify colorscheme
        hi Normal guifg=#f6f3e8 guibg=#242424 gui=none

        if disable_italic
          hi Comment gui=none
        endif

      catch /^Vim\%((\a\+)\)\=:E185/
        echo "WARNING: Preferred GUI colorscheme not found!"
        colorscheme desert
      endtry

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

      " With GUI, upon resize, make all windows equally high and wide.
      autocmd VimResized * wincmd =
    else
      " Terminal {{{
      set background=dark

      " Terminal color palette; shouldn't need to set this, as vim detects
      " this properly if TERM=xterm-256color is set by terminal emulator.
      "set t_Co=256

      colorscheme wombat256 " Should override background if neccessary
      " }}}
    endif

    set titlestring=[%{hostname()}]%(\ %)%t%(\ %M%)%(\ (%{expand(\"%:.:h\")})%)%(\ %a%)%(\ -\ VIM%)
    "set statusline=%F%m%r%h%w[%L][%{&ff}]%y[%p%%][%04l,%04v]

    " Inspired by:
    " http://stackoverflow.com/questions/5375240/a-more-useful-statusline-in-vim
    set statusline=
    set statusline+=%4*\ %n\                                  "buffernr
    set statusline+=%5*\ %<%F\                                "File+path
    set statusline+=%6*\ %y\                                  "FileType
    set statusline+=%7*\ %{''.(&fenc!=''?&fenc:&enc).''}      "Encoding
    set statusline+=%7*%{(&bomb?\",BOM\":\"\")}\              "Encoding2
    set statusline+=%8*\ %{&ff}\                              "FileFormat (dos/unix..)
    set statusline+=%9*\ %{&spelllang}\                       "Spellanguage
    set statusline+=%9*\ %=\ R:%l/%L\ (%p%%)\                 "Rownumber/total (%)
    set statusline+=%8*\ C:%c\                                "Colnr
    set statusline+=%7*\ \ %m%r%w\ %P\ \                      "Modified? Readonly? Top/bot.

    hi User4 guifg=#878700 guibg=#00005f ctermfg=100 ctermbg=17 gui=bold cterm=bold
    hi User5 guifg=#c6c6c6 guibg=#303030 ctermfg=251 ctermbg=236 gui=bold cterm=bold
    hi User6 guifg=#c6c6c6 guibg=#262626 ctermfg=251 ctermbg=235 gui=bold cterm=bold
    hi User7 guifg=#c6c6c6 guibg=#1c1c1c ctermfg=251 ctermbg=234 gui=bold cterm=bold
    hi User8 guifg=#c6c6c6 guibg=#121212 ctermfg=251 ctermbg=233 gui=bold cterm=bold
    hi User9 guifg=#c6c6c6 guibg=#080808 ctermfg=251 ctermbg=232 gui=bold cterm=bold
" }}}

" Autocommands {{{
    augroup ftgroup_agda
      au!
      au BufRead,BufNewFile *.agda,*.lagda setf agda
      au FileType agda call unicodekeys#setup() | setlocal ts=4 sw=2 sts=2 et ai | call SetList(1) | call OverLengthHiOn(80)
      au BufNewFile *.agda,*.lagda setlocal fileformat=unix
    augroup END

    augroup ftgroup_alloy
      au!
      au BufRead,BufNewFile *.als setf alloy
      au BufNewFile *.als setlocal fileformat=unix
      au FileType alloy setlocal ts=2 sw=2 sts=2 et ai
    augroup END

    augroup ftgroup_bibtex
      au!
      au FileType bib setlocal ts=2 sw=2 sts=2 et ai tw=109 foldmarker=@,}\ \ \  | call SetList(1)
      au BufNewFile *.bib setlocal fileformat=unix
    augroup END

    augroup ftgroup_ccppobjc
      au!
      au BufRead,BufNewFile *.cppm,*.ixx setf cpp
      au FileType c    setlocal ts=8 sw=8 sts=8 noet | call SetList(0) | call FindTabStyle("{$") | call OverLengthHiOn(80)
      au FileType cpp  setlocal ts=4 sw=4 sts=4 noet | call SetList(0)
            \ | call FindTabStyle2('\(private:\|protected:\|public:\|{\)$', '\(private:\|protected:\|public:\)$')
            \ | call OverLengthHiOn(80)
      au FileType objc setlocal ts=4 sw=4 sts=4 noet | call SetList(0) | call FindTabStyle("{$") | call OverLengthHiOn(80)
      au BufNewFile *.c,*.cpp,*.h,*.hpp setlocal fileformat=unix
    augroup END

    augroup ftgroup_cmake
      au!
      au BufRead,BufNewFile *.cmake,CMakeLists.txt setf cmake
      au FileType cmake setlocal ts=8 sw=4 sts=4 et | call SetList(1)
      au BufNewFile *.cmake,CMakeLists.txt setlocal fileformat=unix
    augroup END

    augroup ftgroup_d
      au!
      au FileType d setlocal ts=4 sw=4 sts=4 et | call SetList(0) | call FindTabStyle("{$") | call OverLengthHiOn(80)
      au BufNewFile *.d setlocal fileformat=unix
    augroup END

    augroup ftgroup_dot
      au!
      au FileType dot setlocal ts=4 sw=4 sts=4 noet ai | call SetList(0)
      au BufNewFile *.dot setlocal fileformat=unix
    augroup END

    augroup ftgroup_erlang
      au!
      au FileType erlang setlocal ts=4 sw=4 sts=4 et | call SetList(0) | call FindTabStyle("->$") | call OverLengthHiOn(92)
      au BufNewFile *.erl setlocal fileformat=unix
    augroup END

    augroup ftgroup_gitcommit
      au!
      au FileType gitcommit setlocal spell
    augroup END

    augroup ftgroup_go
      au!
      au FileType go setlocal ts=4 sw=4 sts=4 noet | call SetList(0) | call FindTabStyle("{$") | call OverLengthHiOn(80)
      au BufNewFile *.go setlocal fileformat=unix
    augroup END

    augroup ftgroup_haskell
      au!
      au FileType haskell setlocal ts=8 sw=4 sts=4 et | call SetList(1) | call OverLengthHiOn(80)
      au BufNewFile *.hs setlocal fileformat=unix
    augroup END

    augroup ftgroup_hdl
      au!
      au FileType verilog,systemverilog setlocal ts=2 sw=2 sts=2 et | call SetList(0) | call OverLengthHiOn(80) | call FindTabStyle("^module ")
      au BufNewFile *.v,*.sv setlocal fileformat=unix
    augroup END

    augroup ftgroup_htmlcss
      au!
      au FileType html,xhtml,css setlocal ts=2 sw=2 sts=2 tw=79 noet | call SetList(0)
      au BufNewFile *.htm,*.html,*.css setlocal fileformat=unix
    augroup END

    augroup ftgroup_java
      au!
      au BufRead,BufNewFile *.java setlocal ts=4 sw=4 sts=4 noet | call SetList(0) | call FindTabStyle("{$")
      au BufNewFile *.java setlocal fileformat=unix
    augroup END

    augroup ftgroup_js
      au!
      au FileType javascript setlocal ts=4 sw=4 sts=4 noet | call SetList(0) | call FindTabStyle("{$")
      au BufNewFile *.js setlocal fileformat=unix
    augroup END

    augroup ftgroup_lua
      au!
      au FileType lua setlocal ts=4 sw=4 sts=4 et | call SetList(1)
    augroup END

    augroup ftgroup_mail
      au!
      au FileType mail setlocal tw=72 spell | call OverLengthHiOn(72)
    augroup END

    augroup ftgroup_makefile
      au!
      au FileType automake,make setlocal noet
      au BufNewFile Makefile* setlocal fileformat=unix
    augroup END

    augroup ftgroup_ml
      au!
      au FileType ocaml setlocal ts=2 sw=2 sts=2 et | call SetList(1) | call OverLengthHiOn(80)
      au FileType sml   setlocal ts=2 sw=2 sts=2 et | call SetList(1) | call OverLengthHiOn(80)
      au BufNewFile *.ml,*.mli,*.mly,*.sml setlocal fileformat=unix
      au BufRead,BufNewFile *.lem setf ocaml
    augroup END

    augroup ftgroup_murphi
      au!
      au FileType murphi setlocal ts=8 sw=2 sts=2 et ai | call SetList(1) | call OverLengthHiOn(80)
    augroup END

    augroup ftgroup_perl
      au!
      au FileType perl setlocal ts=8 sw=4 sts=4 et | call SetList(0) | call FindTabStyle("{$") | call OverLengthHiOn(80)
      au BufNewFile *.pl setlocal fileformat=unix
    augroup END

    augroup ftgroup_python
      au!
      au BufRead,BufNewFile *.py,*.pyw setf python
      au FileType python setlocal ts=8 sw=4 sts=4 et | call SetList(1) | call OverLengthHiOn(80)
      au BufNewFile *.py,*.pyw setlocal fileformat=unix
    augroup END

    augroup ftgroup_php
      au!
      " [fo]rmatoptions is set to allow text-wrap like in HTML files.
      au FileType php setlocal ts=2 sw=2 sts=2 tw=79 fo=tqrowcb noet | call SetList(0)
      au BufNewFile *.php setlocal fileformat=unix
    augroup END

    augroup ftgroup_promela
      au!
      au FileType promela setlocal ts=4 sw=2 sts=2 et ai | call SetList(1) | call FindTabStyle("{$") | call OverLengthHiOn(80)
      au BufNewFile *.pml setlocal fileformat=unix
    augroup END

    augroup ftgroup_puppet
      au!
      au FileType puppet setlocal ts=4 sw=4 sts=4 et | call SetList(1)
    augroup END

    augroup ftgroup_rstmd
      au!
      au FileType rst,markdown setlocal ts=8 sw=4 sts=4 tw=79 et spell | call SetList(1) | call OverLengthHiOn(80)
      au BufNewFile *.rst,*.md setlocal fileformat=unix

      if disable_italic
        au FileType rst hi rstEmphasis term=none cterm=none gui=none
      endif
    augroup END

    augroup ftgroup_ruby
      au!
      au FileType ruby setlocal ts=4 sw=2 sts=2 et | call SetList(1) | call OverLengthHiOn(80)
      au BufNewFile *.rb setlocal fileformat=unix
    augroup END

    augroup ftgroup_rust
      au!
      au FileType rust setlocal ts=4 sw=4 sts=4 et | call SetList(1) | call OverLengthHiOn(0)
      au BufNewFile *.rs setlocal fileformat=unix
    augroup END

    augroup ftgroup_sh
      au!
      au FileType sh,bash,zsh setlocal ts=4 sw=4 sts=4 noet | call SetList(0)
    augroup END

    augroup ftgroup_smv
      au!
      au FileType nusmv setlocal ts=4 sw=2 sts=2 et ai | call SetList(1)
      au BufNewFile *.smv setlocal fileformat=unix
    augroup END

    augroup ftgroup_sql
      au!
      au FileType sql setlocal ts=4 sw=2 sts=2 et | call SetList(1)
      au BufNewFile *.sql setlocal fileformat=unix
    augroup END

    augroup ftgroup_tex
      au!
      au FileType tex,plaintex setlocal ts=2 sw=2 sts=2 et ai tw=79 spell | call SetList(1) | call OverLengthHiOn(80)
      au BufNewFile *.tex setlocal fileformat=unix

      if disable_italic
        au FileType tex,plaintex hi texItalStyle gui=none cterm=none | hi texBoldItalStyle gui=bold cterm=bold | hi texItalBoldStyle gui=bold cterm=bold
      endif
    augroup END

    augroup ftgroup_text
      au!
      au BufRead,BufNewFile *README*,*INSTALL*,*TODO* setlocal ts=4 sw=4 sts=4 tw=79 et | call SetList(0)
    augroup END

    augroup ftgroup_tla
      au!
      au BufRead,BufNewFile *.tla setf tla
      au FileType tla setlocal ts=4 sw=2 sts=2 et ai | call SetList(1)
      au BufNewFile *.tla setlocal fileformat=unix
    augroup END

    augroup ftgroup_vim
      au!
      au FileType vim setlocal ts=8 sw=2 sts=2 et ai | call SetList(1)
      au BufNewFile *.vim,*vimrc setlocal fileformat=unix
    augroup END

    augroup ftgroup_xmlant
      au!
      au FileType xml,ant setlocal ts=2 sw=2 sts=2 noet | call SetList(0)
      au BufNewFile *.xml setlocal fileformat=unix
    augroup END

    augroup ftgroup_yaml
      au!
      au FileType yaml setlocal ts=2 sw=2 sts=2 et | call SetList(1)
      au BufNewFile *.yml,*.yaml setlocal fileformat=unix
    augroup END

    " PLAN: last, override existing settings, use my taskman script.
    augroup ftgroup_PLAN
      au!
      au BufRead,BufNewFile *PLAN*,*/gtd/*.rst call taskman#setup() | setlocal tw=109 | call OverLengthHiOn(110)
    augroup END
" }}}

" vim: set ts=8 sw=2 sts=2 et ai foldmarker={{{,}}} foldlevel=0 fen fdm=marker:

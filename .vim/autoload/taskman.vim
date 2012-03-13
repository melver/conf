"
" taskman.vim: Manage tasks from within VIM
" Author: Marco Elver <me AT marcoelver.com>
" Date: Tue Mar 13 21:39:09 GMT 2012
"
" It is intended to be used with any file type, as an additional addon
" enabling the use of my task-entries.
"
" Example entry:
" [+2] 2011-12-12 > Task description : @context +tag1 +tag2
"     - Note
"     x Completed subtask
"     + Subtask
"
" TODO:
"   - Command to insert new task
"   - Timetracking with statistics
"   - Sorting by priority and DUE date
"   - Purge completed tasks
"   - Keybindings

" Call this from your .vimrc for the default setup
function! taskman#setup()
  call s:SetupSyntax()
endfunction

function! s:SetupSyntax()
  syn match  tmPrioRegular  "^\[[^\]]*\]"    contained
  syn match  tmPrioLow      "^\[[^\]]*-[^\]]*\]" contained
  syn match  tmPrioHigh     "^\[[^\]]*+[^\]]*\]" contained

  syn region tmStartDate    start="("                     end=")" contained contains=@NoSpell
  syn region tmTags         start=":\s*\(@\|+\)"          end="$" contained contains=tmStartDate,@NoSpell
  syn region tmDueDate      start="\s*\(\d\d\d\d-\d\d-\d\d\|DUE\)" end=">" contained contains=@NoSpell
  syn region tmTask         start="^\(\[[^\]]*\]\|\d\d\d\d-\d\d-\d\d.*>\|DUE.*>\)" end="$" contains=tmTags,tmDueDate,tmPrioHigh,tmPrioLow,tmPrioRegular
  syn region tmDone         start="^\[x[^\]]*\]"          end="^\s*$\|^\S" contains=tmTags,tmDueDate
  syn region tmSubTask      start="^\s\+\(+\|- (+)\)\s"   end="$"
  syn region tmSubDone      start="^\s\+\(x\|- (x)\)\s"   end="$"

  " Fold rule last. Keep start rule same as for tmTask!
  syn region tmFold         start="^\(\[[^\]]*\]\|\d\d\d\d-\d\d-\d\d.*>\|DUE.*>\)" end="^\s*$\|^\S" fold keepend transparent

  hi def link tmDone        Comment
  hi def link tmSubDone     Comment
  hi def link tmSubTask     Special
  hi def      tmTask        term=bold cterm=bold gui=bold,italic
  hi def link tmPrioRegular Special
  hi def link tmPrioHigh    Todo
  hi def link tmPrioLow     PreProc
  hi def link tmTags        Keyword
  hi def link tmDueDate     Keyword
  hi def link tmStartDate   String

  set foldmethod=syntax
endfunction

" vim: set ts=2 sts=2 sw=2 et :

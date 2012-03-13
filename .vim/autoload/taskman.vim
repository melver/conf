"
" taskman.vim: Manage tasks from within VIM
" Author: Marco Elver <me AT marcoelver.com>
"
" It is intended to be used with any file type, as an additional addon
" enabling the use of my task-entries.
"
" Example entry:
" [+2] 2011-12-12 > Task description : @context +tag1 +tag2
"     - Note
"     x Completed subtask
"     + Subtask

function! taskman#setup()
  call s:SetupSyntax()
endfunction

function! s:SetupSyntax()
  syn region tmStartDate    start="("                     end=")" contained contains=@NoSpell
  syn region tmTags         start=":\s*\(@\|+\)"          end="$" contained contains=tmStartDate,@NoSpell
  syn region tmDueDate      start="\s*\(\d\d\d\d-\d\d-\d\d\|@@\)" end="\s*>" contained contains=@NoSpell
  syn region tmPrioRegular  start="^\[.*\]"               end="$" contains=tmTags,tmDueDate
  syn region tmPrioLow      start="^\[.*-.*\]"            end="$" contains=tmTags,tmDueDate
  syn region tmPrioHigh     start="^\[.*+.*\]"            end="$" contains=tmTags,tmDueDate
  syn region tmDone         start="^\[x.*\]"              end="^\s*$\|^\S" contains=tmTags,tmDueDate
  syn region tmSubTask      start="^\s\++\s"              end="$"
  syn region tmSubDone      start="^\s\+x\s"              end="$"
  syn region tmFold         start="^\[.*\]"               end="^\s*$\|^\S" fold keepend transparent

  hi def link tmDone        Comment
  hi def link tmSubDone     Comment
  hi def link tmSubTask     Special
  hi def link tmPrioRegular Special
  hi def link tmPrioHigh    Todo
  hi def link tmPrioLow     PreProc
  hi def link tmTags        Keyword
  hi def link tmDueDate     Keyword
  hi def link tmStartDate   Comment

  set foldmethod=syntax
endfunction

" vim: set ts=2 sts=2 sw=2 et :

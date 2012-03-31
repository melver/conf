"
" taskman.vim: Manage tasks from within VIM
" Author: Marco Elver <me AT marcoelver.com>
" Date Created: Tue Mar 13 21:39:09 GMT 2012
"
" It is intended to be used with any file type, as an additional add-on
" enabling the use of the specified task-entry format (rather personalized).
" Other existing solutions (see taskpaper.vim, todotxt, etc.) were limiting,
" in either that I had to use an external program or could not continue using
" the existing format which I had gotten used to for in-task notes (in my
" case, ReST -- VIM has nice syntax highlighting for ReST) or even the rather
" extensive format I came up with. In addition, I was not able to find an
" existing solution, that works well, in VIM.
"
" In the future, I may somehow package it nicely, but for now, it works as is,
" as a single self contained file.
"
" If you find it useful, contact me.
"
" Usage:
" Add something like this to your .vimrc (or ftplugin) file:
"
" augroup my_PLAN
"   au!
"   au BufRead,BufNewFile PLAN* call taskman#setup()
" augroup END
"
"
" Example entry:
" [+2] 2011-12-12 > Task description : @context +tag1 +tag2
"     - Note
"     x Completed subtask
"     + Subtask
"
"
" taskman TODO:
"   + Purge completed tasks (synIDattr should make this easy)
"   + Sorting by priority and DUE date, tracking time
"     + Implement MakeTaskStringFromDict (replace maketask), GetTaskDictFromString

let s:save_cpo = &cpo
set cpo&vim

" Variables {{{

" Tags
let s:tag_timetracking      = "+Ttracking"
let s:tag_timetracked       = "+T"

" Search due date options
let s:search_dueyearsback   = 3
let s:search_duedaysahead   = 5
let s:onsetup_focusduesoon  = 1

" Date format; this should NOT be modified, unless the other hardcoded bits
" that depend on this format are changed accordingly.
let s:format_date           = "%Y-%m-%d"
let s:format_datetime       = "%Y-%m-%d@%H:%M.%Z"

" }}}

" Interface functions {{{

" Call this for the filetypes you want this enabled
function! taskman#setup()
  if exists("g:taskman_do_not_load")
    return
  endif

  call s:SetupSyntax()

  if !exists("b:taskman_mappings")
    call s:SetupMappings()
  endif

  call s:SetupOptions()


  if s:onsetup_focusduesoon
    call taskman#search_duesoon()
  endif
endfunction

function! taskman#foldtext()
  let l:lines = v:foldend - v:foldstart
  return getline(v:foldstart) . " | " . l:lines . (l:lines > 1 ? " lines " : " line ")
endfunction

function! taskman#maketask()
  "TODO: use input auto-completion option here
  let l:task_prio = input("Priority: ")
  let l:task_due = input("Due: ")
  let l:task_name = input("Description/Name: ")
  let l:task_contexttags = input("Contexts/Tags: ")
  let l:task_estwork = input("Estimated work-load (HH:MM): ")

  let l:result = ""

  if strlen(l:task_prio) != 0 || strlen(l:task_due) == 0
    let l:result = l:result . "[" . l:task_prio . "] "
  endif

  if strlen(l:task_due) != 0
    if l:task_due =~ "^\\d\\d\\d\\d-\\d\\d-\\d\\d"
      let l:result = l:result . l:task_due . " > "
    else
      let l:result = l:result . "DUE " . l:task_due . " > "
    endif
  endif

  let l:result = l:result . l:task_name . " :"

  if strlen(l:task_contexttags) != 0
    let l:result = l:result . " " . l:task_contexttags
  endif

  let l:result = l:result . " (" . strftime(s:format_datetime)
  if strlen(l:task_estwork) != 0
    let l:result = l:result . ",~" . l:task_estwork
  endif
  let l:result = l:result . ")"

  " TODO: insert sorted
  call setline(line("."), getline(".") . l:result)
endfunction

function! taskman#start_timetrack()
  if !exists("b:taskman_trackstart")
    if s:RestartTracking()
      let b:taskman_savestatusline = &statusline
      execute "setlocal statusline=%([Tracked\\ time:\\ %{taskman#get_track_time()}]\\ %)" . b:taskman_savestatusline
    endif
  else
    call s:UpdateTracked()
    if !s:RestartTracking()
      execute "setlocal statusline=" . b:taskman_savestatusline
      unlet b:taskman_trackstart
    endif
  endif
endfunction

function! taskman#stop_timetrack()
  if exists("b:taskman_trackstart")
    call s:UpdateTracked()
    execute "setlocal statusline=" . b:taskman_savestatusline
    unlet b:taskman_trackstart
  else
    echo "[taskman] Tracking not in progress!"
  endif
endfunction

function! taskman#get_track_time()
  if exists("b:taskman_trackstart")
    let l:track_time = localtime() - b:taskman_trackstart
    let l:track_totaltime = l:track_time + b:taskman_trackpast

    let l:result = "+" . s:FormatTrackTime(l:track_time) . "=" . s:FormatTrackTime(l:track_totaltime)
    if b:taskman_estwork == 0
      return l:result
    else
      return l:result . "(" . ((l:track_totaltime * 100) / b:taskman_estwork) . "%)"
    endif
  endif

  return "Tracking not in progress!"
endfunction

function! taskman#focus_tracking()
  if exists("b:taskman_trackstart")
    let l:result = search(b:taskman_trackline)

    if l:result == 0
      " Fallback. May not be accurate if there is a similar tag.
      return search(s:tag_timetracking)
    endif

    return l:result
  endif

  echo "[taskman] Tracking not in progress!"
  return 0
endfunction

function! taskman#mark_done()
  let l:done_marker = "[x!" . strftime(s:format_datetime) . "]"

  let l:indendation = matchstr(getline("."), "^\\s*")
  let l:syn_name = synIDattr(synID(line("."), strlen(l:indendation)+1, 1), 'name')

  if l:syn_name == "tmTaskDone"
    echo "[taskman] Already marked done."
    return
  endif

  if l:syn_name =~ "^tmPrio"
    call setline(line("."), substitute(getline("."), "\\[[^\\]]*\\]", l:done_marker, ''))
  else
    if l:indendation != ""
      call setline(line("."), substitute(getline("."), l:indendation, l:indendation . l:done_marker . " ", ''))
    else
      call setline(line("."), l:done_marker . " " . getline("."))
    endif
  endif
endfunction

function! taskman#search_duesoon()
  let l:cur_pos = getpos(".")
  let l:regex_due_date = s:GetRegexDueDate(s:search_duedaysahead)
  let l:result = searchpos(l:regex_due_date)

  " Update the syntax match rule
  execute "syn match  tmDueDateSoon '" . l:regex_due_date . "' contained"

  if l:result[0] == 0
    return l:result
  endif

  let l:nextres = l:result
  while synIDattr(synID(l:nextres[0], l:nextres[1], 1), 'name') !~ "^tmDueDate"
    let l:nextres = searchpos(l:regex_due_date)
    if l:nextres == l:result
      echo "[taskman] No items due soon."
      call setpos(".", l:cur_pos)
      return 0
    endif
  endwhile

  return l:nextres
endfunction

" }}}

" Private functions {{{

function! s:RestartTracking()
  let l:current_line = getline(".")
  if l:current_line =~ "^\\s*$"
    echo "[taskman] Not a trackable item!"
    return 0
  endif

  let l:past_tracked = matchstr(getline("."), s:tag_timetracked . "{[^}]\\+}")
  let b:taskman_trackstart = localtime()

  if l:past_tracked != ""
    let l:current_line = substitute(l:current_line, l:past_tracked, s:tag_timetracking, '')
    let l:past_time = matchstr(l:past_tracked, "=\\d\\+:\\d\\d:\\d\\d")
    if l:past_time != ""
      let b:taskman_trackpast = s:GetTrackTimeSec(l:past_time[1:])
    else
      echo "[taskman] WARNING: Could not find past tracking information!"
      let b:taskman_trackpast = 0 " fallback
    endif
  else
    let l:current_line = l:current_line . " " . s:tag_timetracking
    let b:taskman_trackpast = 0
  endif

  let l:est_work = matchstr(l:current_line, "\\~[0-9:]\\+)")
  if l:est_work != ""
    let b:taskman_estwork = s:GetTrackTimeSec(l:est_work[1:-2] . ":00")
  else
    let b:taskman_estwork = 0
  endif

  call setline(line("."), l:current_line)

  let b:taskman_trackline = escape(l:current_line, '[]\.*~')

  return 1
endfunction

function! s:UpdateTracked()
  let l:cur_pos = getpos(".")
  let l:new_tracking_info = s:tag_timetracked . "{" . strftime(s:format_date) . "," . taskman#get_track_time() . "}"

  let l:tracked_line = taskman#focus_tracking()
  if l:tracked_line != 0
    call setline(l:tracked_line, substitute(getline(l:tracked_line), s:tag_timetracking, l:new_tracking_info, ''))
  else
    echom "[taskman] WARNING: Could not update entry ('" . b:taskman_trackline . "') with: " . l:new_tracking_info
  endif

  call setpos(".", l:cur_pos)
endfunction

function! s:FormatTrackTime(timesec)
  let l:mins  = a:timesec / 60
  let l:hours = l:mins / 60
  let l:mins  = l:mins % 60
  let l:secs  = a:timesec % 60

  return  l:hours . ":" . (l:mins < 10 ? ("0" . l:mins) : l:mins) . ":" . (l:secs < 10 ? ("0" . l:secs) : l:secs)
endfunction

function! s:GetTrackTimeSec(timestr)
  let l:parts = split(a:timestr, ":")
  return (str2nr(l:parts[0])*60 + str2nr(l:parts[1]))*60 + str2nr(l:parts[2])
endfunction

function! s:GetRegexDueDate(days_from_today)
  let l:due = strftime(s:format_date, localtime() + (a:days_from_today * 24 * 60 * 60))

  let l:day   = str2nr(l:due[8:9])
  let l:year  = str2nr(l:due[0:3])

  if l:day < 10
    let l:regex_day_part = "0" . join(range(1, l:day), "\\|0")
  else
    let l:regex_day_part = "0" . join(range(1, 9), "\\|0") . "\\|" . join(range(10, l:day), "\\|")
  endif

  let l:regex_day    = l:due[0:7] . "\\(" . l:regex_day_part . "\\)"
  let l:regex_month  = l:due[0:4] . "0*\\(" . join(range(1, str2nr(l:due[5:6])-1), "\\|") . "\\)-\\d\\d"
  let l:regex_year = "\\(" . join(range(l:year-s:search_dueyearsback, l:year-1), "\\|") . "\\)-\\d\\d-\\d\\d"

  return l:regex_day . "\\|" . l:regex_month . "\\|" . l:regex_year
endfunction

function! s:SetupMappings()
  " Reparse file to get accuarte folding
  map <buffer> <unique> <Leader>tf :syn sync fromstart<CR>
  map <buffer> <unique> <Leader>tm :call taskman#maketask()<CR>
  map <buffer> <unique> <Leader>tts :call taskman#start_timetrack()<CR>
  map <buffer> <unique> <Leader>ttp :call taskman#stop_timetrack()<CR>
  map <buffer> <unique> <Leader>ttg :call taskman#focus_tracking()<CR>
  map <buffer> <unique> <Leader>td  :call taskman#mark_done()<CR>
  map <buffer> <unique> <Leader>tu  :call taskman#search_duesoon()<CR>

  let b:taskman_mappings = 1
endfunction

function! s:SetupSyntax()
  " Task priorities
  syn match  tmPrioRegular  "\[[^\]]*\]"        contained
  syn match  tmPrioLow      "\[[^\]]*-[^\]]*\]" contained
  syn match  tmPrioHigh     "\[[^\]]*+[^\]]*\]" contained
  syn cluster tmPriority    contains=tmPrioRegular,tmPrioLow,tmPrioHigh

  " Meta information
  syn region tmStartTime    start="("                     end=")"           contained contains=@NoSpell
  syn match  tmTags         "\(@\|+\)\S\+"                                  contained contains=@NoSpell
  syn region tmMetaInfo     start=" : "                   end="$"           contained contains=tmStartDate,tmTags keepend
  syn region tmDueDate      start="\s*\(\d\d\d\d-\d\d-\d\d\|DUE\)" end=">"  contained contains=@NoSpell,tmDueDateSoon

  " Simple sub-tasks
  syn region tmSubDone      start="^\s\+\(x\|- (x)\)"     end="$"
  syn region tmSubTask      start="^\s\+\(+\|- (+)\)"     end="$"           contains=tmMetaInfo,tmDueDate keepend

  " Task + folding fulres and completed task
  syn region tmTask         start="^\z(\s*\)\(\[[^\]x]*\]\|\d\d\d\d-\d\d-\d\d.*>\|DUE.*>\)" end="$" contains=tmMetaInfo,tmDueDate,@tmPriority keepend
  syn region tmTaskFold     start="^\z(\s*\)\(\[[^\]x]*\]\|\d\d\d\d-\d\d-\d\d.*>\|DUE.*>\)" end="^\s*$\|^\z1\S"me=s-1 fold keepend transparent
  syn region tmTaskDone     start="^\z(\s*\)\[x[^\]]*\]"       end="^\s*$\|^\z1\S"me=s-1 contains=tmMetaInfo fold keepend

  hi def link tmTaskDone    Comment
  hi def link tmSubDone     Comment
  hi def link tmSubTask     Special
  hi def      tmTask        term=bold cterm=bold gui=bold,italic
  hi def link tmPrioRegular Special
  hi def link tmPrioHigh    Todo
  hi def link tmPrioLow     Comment
  hi def link tmMetaInfo    Keyword
  hi def link tmTags        Keyword
  hi def link tmDueDate     PreProc
  hi def link tmDueDateSoon WarningMsg
  hi def link tmStartDate   String

  syn sync fromstart
endfunction

function! s:SetupOptions()
  setlocal foldmethod=syntax
  setlocal foldtext=taskman#foldtext()
endfunction

" }}}

let &cpo = s:save_cpo

" vim: set ts=2 sts=2 sw=2 et :

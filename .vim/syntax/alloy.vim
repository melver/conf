if exists("b:current_syntax")
  finish
endif

syn keyword alloyConstant univ iden
syn keyword alloyExecute run check
syn keyword alloyFunDecl fun
syn keyword alloyModifier set lone private one abstract
syn keyword alloyModule module
syn keyword alloyOpen open as
syn keyword alloyOperator all sum some no none disj not in iff implies and or for else exactly but let
syn keyword alloyConstraint fact pred assert
syn keyword alloySigDecl enum sig extends

syn region alloyComment start="/\*" end="\*/" contains=@alloyInComment
syn region alloyComment start="\-\-" end="\n" contains=@alloyInComment
syn region alloyComment start="//" end="\n" contains=@alloyInComment
syn cluster alloyInComment    contains=alloyTODO,alloyFIXME,alloyXXX
syn keyword alloyTODO         contained TODO
syn keyword alloyFIXME        contained FIXME
syn keyword alloyXXX          contained XXX

hi def link alloyConstant   Constant
hi def link alloyExecute    Statement
hi def link alloyFunDecl    Macro
hi def link alloyModifier   Typedef
hi def link alloyModule     Structure
hi def link alloyOpen       Include
hi def link alloyOperator   Operator
hi def link alloyConstraint Function
hi def link alloySigDecl    Structure

hi def link alloyComment    Comment
hi def link alloyTODO       Todo
hi def link alloyFIXME      Todo
hi def link alloyXXX        Todo

let b:current_syntax = "alloy"

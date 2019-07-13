" CmdlineSpecialEdits/Literal.vim: Insert literal register into command-line.
"
" DEPENDENCIES:
"
" Copyright: (C) 2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	001	14-Jul-2019	file creation
let s:save_cpo = &cpo
set cpo&vim

function! CmdlineSpecialEdits#Literal#Register() abort
    let [l:cmdlineBeforeCursor, l:cmdlineAfterCursor] = CmdlineSpecialEdits#GetCurrentCmdline()
    let l:registerContents = getreg(ingo#query#get#Register('\'))

    if getcmdtype() =~# '^[/?]$'
	let l:escapedRegister = ingo#regexp#EscapeLiteralText(l:registerContents, getcmdtype())
	let l:veryNoMagicRegister = '\V' . escape(l:registerContents, '\' . getcmdtype())
	let l:literalRegister = (len(l:escapedRegister) <= len(l:veryNoMagicRegister) ?
	\   l:escapedRegister :
	\   l:veryNoMagicRegister
	\)

	call setcmdpos(strlen(l:cmdlineBeforeCursor . l:literalRegister) + 1)
	return l:cmdlineBeforeCursor . l:literalRegister . l:cmdlineAfterCursor
    endif
    return l:cmdlineBeforeCursor . l:cmdlineAfterCursor
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :

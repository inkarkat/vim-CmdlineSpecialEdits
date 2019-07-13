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

function! CmdlineSpecialEdits#Literal#Register() abort
    let [l:cmdlineBeforeCursor, l:cmdlineAfterCursor] = CmdlineSpecialEdits#GetCurrentCmdline()

    if getcmdtype() =~# '^[/?]$'
	let l:escapedRegister = '\V' . escape(getreg(ingo#query#get#Register('\')), '\' . getcmdtype())
	call setcmdpos(strlen(l:cmdlineBeforeCursor . l:escapedRegister) + 1)
	return l:cmdlineBeforeCursor . l:escapedRegister . l:cmdlineAfterCursor
    endif
    return l:cmdlineBeforeCursor . l:cmdlineAfterCursor
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :

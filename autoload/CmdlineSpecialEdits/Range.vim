" CmdlineSpecialEdits/Range.vim: Toggle between symbolic and numbered ranges.
"
" DEPENDENCIES:
"
" Copyright: (C) 2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	001	25-Dec-2014	file creation

function! CmdlineSpecialEdits#Range#ToggleSymbolic()
    let [l:cmdlineBeforeCursor, l:cmdlineAfterCursor] = CmdlineSpecialEdits#GetCurrentOrPreviousCmdline()
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :

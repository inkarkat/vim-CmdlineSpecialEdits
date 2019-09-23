" CmdlineSpecialEdits/SpecialRange.vim: Insert special ranges.
"
" DEPENDENCIES:
"
" Copyright: (C) 2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	001	24-Sep-2019	file creation

function! CmdlineSpecialEdits#SpecialRange#LastChange() abort
    return (getcmdtype() ==# ':' && strpart(getcmdline(), 0, getcmdpos() - 1) =~# '\%(^\|\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!|\)\s*$' ? "'[,']" : '#')
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :

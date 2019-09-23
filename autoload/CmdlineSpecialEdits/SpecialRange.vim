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

function! s:GetRange( startMark, endMark ) abort
    let l:lineDiff = line(a:endMark) - line(a:startMark)
    return (l:lineDiff > 0 ? '.,.+' . l:lineDiff : '.')
endfunction
function! CmdlineSpecialEdits#SpecialRange#LastChange() abort
    if getcmdtype() !=# ':'
	return '#'
    endif

    let l:textBeforeCursor = strpart(getcmdline(), 0, getcmdpos() - 1)
    if l:textBeforeCursor =~# '\%(^\|\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!|\)\s*''\[,''\]$'
	" Turn ## into a range the same size as the last changed range.
	return "\<BS>\<BS>\<BS>\<BS>\<BS>" . s:GetRange("'[", "']")
    endif
    return (l:textBeforeCursor =~# '\%(^\|\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!|\)\s*$' ? "'[,']" : '#')
endfunction
function! CmdlineSpecialEdits#SpecialRange#LastSelection() abort
    if getcmdtype() !=# ':'
	return '*'
    endif

    let l:textBeforeCursor = strpart(getcmdline(), 0, getcmdpos() - 1)
    if l:textBeforeCursor =~# '\%(^\|\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!|\)\s*\*$'
	" Turn ** into a range the same size as the last changed range.
	return "\<BS>" . s:GetRange("'<", "'>")
    endif
    return '*'
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :

" CmdlineSpecialEdits/Range.vim: Toggle between symbolic and numbered ranges.
"
" DEPENDENCIES:
"   - CmdlineSpecialEdits.vim autoload script
"   - ingo/cmdargs/range.vim autoload script
"   - ingo/range/lines.vim autoload script
"
" Copyright: (C) 2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	001	25-Dec-2014	file creation
let s:save_cpo = &cpo
set cpo&vim

function! CmdlineSpecialEdits#Range#ToggleSymbolic()
    let [l:cmdlineBeforeCursor, l:cmdlineAfterCursor] = CmdlineSpecialEdits#GetCurrentOrPreviousCmdline()

    let l:commandParse = ingo#cmdargs#range#Parse(l:cmdlineBeforeCursor)
    let [l:fullCommandUnderCursor, l:combiner, l:commandCommands, l:range, l:remainder] = l:commandParse

    let l:commandWithToggledRange = join([l:combiner, l:commandCommands, s:ToggleRange(l:range), l:remainder], '')

    let l:previousCommands = strpart(l:cmdlineBeforeCursor, 0, strridx(l:cmdlineBeforeCursor, l:fullCommandUnderCursor))
    let l:cmdlineWithoutArguments = l:previousCommands . l:commandWithToggledRange
    call setcmdpos(strlen(l:cmdlineWithoutArguments) + 1)
    return l:cmdlineWithoutArguments . l:cmdlineAfterCursor
endfunction
function! s:ToggleRange( range )
    if a:range =~# '^\d\+\%(,\d*\)\?$'
	return join(
	\   map(
	\       split(a:range, ','),
	\       's:FindMark(v:val, 0)'
	\   ),
	\   ','
	\)
    else
	let l:save_view = winsaveview()
	    let [l:recordedLnums, l:startLnums, l:endLnums, l:didClobberSearchHistory] = ingo#range#lines#Get(1, line('$'), a:range, 0)
	call winrestview(l:save_view)
	if len(l:startLnums) == 1 && len(l:endLnums) == 1
	    if l:startLnums[0] == l:endLnums[0]
		return printf('%d', l:startLnums[0])
	    else
		return printf('%d,%d', l:startLnums[0], l:endLnums[0])
	    endif
	else
	    " Couldn't determine the line numbers; maybe a mark wasn't set.
	    return a:range
	endif
    endif
endfunction
function! s:FindMark( lnum, offset )
    for l:mark in split('abcdefghijklmnopqrstuvwxyz', '\zs') +
    \   filter(
    \       split('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', '\zs'),
    \       'getpos("''" . v:val)[0] == ' . bufnr('')
    \   ) +
    \   split(g:CmdlineSpecialEdits_SymbolicRangeMaximumOffset, '\zs')
	let l:markLnum = line("'" . l:mark)
	if l:markLnum > 0
	    if l:markLnum + a:offset == a:lnum
		return "'" . l:mark . (a:offset > 0 ? '+' . a:offset : '')
	    elseif l:markLnum - a:offset == a:lnum
		return "'" . l:mark . (a:offset > 0 ? '-' . a:offset : '')
	    endif
	endif
    endfor

    if a:offset <= g:CmdlineSpecialEdits_SymbolicRangeMaximumOffset
	return s:FindMark(a:lnum, a:offset + 1)
    endif

    " Also support the current line ".", even though it's not a mark.
    return s:FindRelativeLine(a:lnum, 0)
endfunction
function! s:FindRelativeLine( lnum, offset )
    if line('.') + a:offset == a:lnum
	return '.' . (a:offset > 0 ? '+' . a:offset : '')
    elseif line('.') - a:offset == a:lnum
	return '.' . (a:offset > 0 ? '-' . a:offset : '')
    endif

    if a:offset <= g:CmdlineSpecialEdits_SymbolicRangeMaximumOffset
	return s:FindRelativeLine(a:lnum, a:offset + 1)
    endif
    return a:lnum
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :

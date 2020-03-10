" CmdlineSpecialEdits/Range.vim: Toggle between symbolic and numbered ranges.
"
" DEPENDENCIES:
"   - ingo-library.vim plugin
"
" Copyright: (C) 2014-2020 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

function! s:ChangeRange( Changer )
    let [l:cmdlineBeforeCursor, l:cmdlineAfterCursor] = CmdlineSpecialEdits#GetCurrentOrPreviousCmdline()

    let l:commandParse = ingo#cmdargs#range#Parse(l:cmdlineBeforeCursor)
    if empty(l:commandParse) | return getcmdline() | endif
    let [l:fullCommandUnderCursor, l:combiner, l:commandCommands, l:range, l:remainder] = l:commandParse

    let l:commandWithToggledRange = join([l:combiner, l:commandCommands, call(a:Changer, [l:range]), l:remainder], '')

    let l:previousCommands = strpart(l:cmdlineBeforeCursor, 0, strridx(l:cmdlineBeforeCursor, l:fullCommandUnderCursor))
    let l:cmdlineWithoutArguments = l:previousCommands . l:commandWithToggledRange
    call setcmdpos(strlen(l:cmdlineWithoutArguments) + 1)
    return l:cmdlineWithoutArguments . l:cmdlineAfterCursor
endfunction

function! CmdlineSpecialEdits#Range#ToggleSymbolic()
    return s:ChangeRange(function('s:ToggleRange'))
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
    for l:mark in
    \   filter(
    \       split(g:CmdlineSpecialEdits_SymbolicRangeConsideredMarks, '\zs'),
    \       'index([0, ' . bufnr('.') . '], getpos("''" . v:val)[0]) != -1'
    \   )
	if l:mark ==# '#'
	    " Also support the current line "." (configurable via the special
	    " mark "#"), even though it's not a mark.
	    let l:markRange = '.'
	else
	    let l:markRange = "'" . l:mark
	endif
	let l:markLnum = line(l:markRange)

	if l:markLnum > 0
	    if l:markLnum + a:offset == a:lnum
		return l:markRange . (a:offset > 0 ? '+' . a:offset : '')
	    elseif l:markLnum - a:offset == a:lnum
		return l:markRange . (a:offset > 0 ? '-' . a:offset : '')
	    endif
	endif
    endfor

    if a:offset <= g:CmdlineSpecialEdits_SymbolicRangeMaximumOffset
	return s:FindMark(a:lnum, a:offset + 1)
    endif

    return a:lnum   " Nothing found.
endfunction

function! CmdlineSpecialEdits#Range#ToggleRelative()
    return s:ChangeRange(function('s:ToggleRelative'))
endfunction
function! s:ToggleRelative( range )
    let l:parse = matchlist(a:range, '^\(\.\?\)\([+-]\?\)\(\d*\)\%(,\(\.\?\)\([+-]\?\)\(\d*\)\)\?$')
    if empty(l:parse)
	return a:range
    endif

    let [l:startLnum, l:wasStartRelative] = s:ParseAddress(l:parse[1], l:parse[2], l:parse[3])
    let [l:endLnum, l:wasEndRelative]     = s:ParseAddress(l:parse[4], l:parse[5], l:parse[6])

    if l:endLnum && l:startLnum > l:endLnum
	" Correct backwards range.
	let [l:startLnum, l:endLnum] = [l:endLnum, l:startLnum]
    endif

    if l:wasStartRelative && (! l:endLnum || l:wasEndRelative)
	return l:startLnum . (l:endLnum ? ',' . l:endLnum : '')
    else
	return s:LnumToRelative(l:startLnum) . (l:endLnum ? ',' . s:LnumToRelative(l:endLnum) : '')
    endif
endfunction
function! s:ParseAddress( base, sigil, number )
    if empty(a:base) && empty(a:sigil) && empty(a:number)
	return [0, 0]
    endif

    let l:isRelative = ! empty(a:base) || ! empty(a:sigil)
    let l:lnum = (l:isRelative ?
    \   line('.') + (a:sigil ==# '-' ? -1 : 1) * a:number :
    \   (empty(a:number) ? line('.') : a:number)
    \)

    " Correct out-of-bounds line number.
    return [min([line('$'), max([1, l:lnum])]), l:isRelative]
endfunction
function! s:LnumToRelative( lnum )
    let l:offset = a:lnum - line('.')

    return (l:offset == 0 ?
    \   '.' :
    \   (l:offset > 0 ?
    \       '.+' . l:offset :
    \       '.' . l:offset
    \   )
    \)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :

" CmdlineSpecialEdits/Simplify.vim: Simplify command-line.
"
" DEPENDENCIES:
"   - CmdlineSpecialEdits.vim autoload script
"   - ingo/collections.vim autoload script
"   - ingo/collections/find.vim autoload script
"   - ingo/compat.vim autoload script
"   - ingo/list/lcs.vim autoload script
"   - ingo/regexp/collection.vim autoload script
"
" Copyright: (C) 2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	003	31-Oct-2017	DWIM: Always recall from search history, not
"				command-line history.
"	002	29-Jul-2017	Fix problems in algorithm.
"				Get alternatives for 1..3 common length, and
"				choose the shortest one; prefering longer common
"				length among equals.
"	001	24-Jul-2017	file creation
let s:save_cpo = &cpo
set cpo&vim

function! CmdlineSpecialEdits#Simplify#Branches()
    let [l:cmdlineBeforeCursor, l:cmdlineAfterCursor] = CmdlineSpecialEdits#GetCurrentOrPreviousCmdline('/')
    let l:searchPattern = l:cmdlineBeforeCursor . l:cmdlineAfterCursor
    let l:branches = split(l:searchPattern, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\|', 1)
    if len(l:branches) < 2
	return l:searchPattern
    endif

    " Try minimum common lengths of 1..3, with minimum distinct lengths of
    " either 1 or 0.
    let l:commonLengthAlternatives =
    \   map(range(1, 3), "ingo#list#lcs#FindAllCommon(l:branches, v:val, 1)") +
    \   map(range(1, 3), "ingo#list#lcs#FindAllCommon(l:branches, v:val, 0)")

    " Remove those alternatives that have no common substrings; there would be
    " no change to the original.
    call filter(l:commonLengthAlternatives, '! empty(v:val[1])')

    let l:alternativeBranches = map(l:commonLengthAlternatives, 'call("s:SimplifyBranches", v:val)')

    " Use the alternative that yields the shortest regexp.
    return get(ingo#collections#find#Lowest(l:commonLengthAlternatives, 'ingo#compat#strchars(v:val)'), -1, '') " -1: Prefer longer common length and no distinct length in case there are alternatives with equal length.
endfunction
function! s:SimplifyBranches( distinctLists, commons )
    " For pattern branches, we only need to specify each branch once.
    call map(a:distinctLists, 'ingo#collections#UniqueStable(v:val)')

    let l:result = []
    while ! empty(a:distinctLists) || ! empty(a:commons)
	if ! empty(a:distinctLists)
	    let l:distinctList = remove(a:distinctLists, 0)
	    let l:originalLen = len(l:distinctList)
	    call filter(l:distinctList, '! empty(v:val)')
	    let l:hadEmptyRemoved = (len(l:distinctList) < l:originalLen)

	    if len(l:distinctList) == 0
		let l:distinct = ''
	    elseif len(l:distinctList) == 1
		let l:distinct = l:distinctList[0]
		if l:hadEmptyRemoved
		    let l:distinct = '\%(' . l:distinct . '\)'
		endif
	    elseif max(map(copy(l:distinctList), 'len(v:val)')) == 1
		" Use collection.
		let l:distinct = ingo#regexp#collection#LiteralToRegexp(join(l:distinctList, ''))
	    else
		" Use branches.
		let l:distinct = '\%(' . join(l:distinctList, '\|') . '\)'
	    endif
	    call add(l:result, l:distinct . (l:hadEmptyRemoved ? '\?' : ''))
	endif

	if ! empty(a:commons)
	    call add(l:result, remove(a:commons, 0))
	endif
    endwhile

    return join(l:result, '')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :

" CmdlineSpecialEdits/Simplify.vim: Simplify command-line.
"
" DEPENDENCIES:
"   - CmdlineSpecialEdits.vim autoload script
"
" Copyright: (C) 2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	001	24-Jul-2017	file creation

function! CmdlineSpecialEdits#Simplify#Branches()
    let [l:cmdlineBeforeCursor, l:cmdlineAfterCursor] = CmdlineSpecialEdits#GetCurrentOrPreviousCmdline()
    let l:searchPattern = l:cmdlineBeforeCursor . l:cmdlineAfterCursor
    let l:branches = split(l:searchPattern, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\|', 1)
    if len(l:branches) < 2
	return l:searchPattern
    endif

    return s:SimplifyBranches(l:branches)
endfunction
function! s:SimplifyBranches( branches )
    let [l:distinctLists, l:commons] = ingo#list#lcs#FindAllCommon(a:branches, 1, 1)

    " For pattern branches, we only need to specify each branch once.
    call map(l:distinctLists, 'ingo#collections#UniqueStable(v:val)')

    let l:result = []
    while ! empty(l:distinctLists) || ! empty(l:commons)
	if ! empty(l:distinctLists)
	    let l:distinctList = filter(remove(l:distinctLists, 0), '! empty(v:val)')

	    if len(l:distinctList) <= 1
		let l:distinct = get(l:distinctList, 0, '')
	    elseif max(map(copy(l:distinctList), 'len(v:val)')) == 1
		" Use collection.
		let l:distinct = '[' . ingo#regexp#collection#LiteralToRegexp(join(l:distinctList, '')) . ']'
	    else
		" Use branches.
		let l:distinct = '\%(' . join(l:distinctList, '\|') . '\)'
	    endif
	    call add(l:result, l:distinct)
	endif

	if ! empty(l:commons)
	    call add(l:result, remove(l:commons, 0))
	endif
    endwhile

    return join(l:result, '')
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :

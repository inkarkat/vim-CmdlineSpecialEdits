" CmdlineSpecialEdits/IgnoreCase.vim: Ignore case in pattern.
"
" DEPENDENCIES:
"   - ingo-library.vim plugin
"
" Copyright: (C) 2020 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! CmdlineSpecialEdits#IgnoreCase#Mixed() abort
    let [l:cmdlineBeforePattern, l:searchPattern, l:cmdlineAfterPattern] = CmdlineSpecialEdits#ParseCurrentOrPreviousPattern('/')
    if l:searchPattern !~# '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\c'
	return l:cmdlineBeforePattern . l:searchPattern . l:cmdlineAfterPattern
    endif

    return l:cmdlineBeforePattern . s:PartialIgnoreCase(l:searchPattern) . l:cmdlineAfterPattern
endfunction

function! s:PartialIgnoreCase( pattern )
    let [l:ordinaryAtoms, l:atomsMultisAndSoOn] = ingo#collections#SeparateItemsAndSeparators(ingo#regexp#magic#Normalize(a:pattern), ingo#regexp#parse#NonOrdinaryAtomExpr(), 1)

    let l:isCurrentCaseSensitive = ! &ignorecase
    let l:caseInsensitiveOrdinaryAtoms = []
    let l:caseSensitiveOrdinaryAtoms = []
    let l:isSwitchedCase = 0
    for l:i in range(len(l:ordinaryAtoms))
	if l:i >= 1
	    let l:caseSigil = matchstr(get(l:atomsMultisAndSoOn, l:i - 1, ''), '^.*\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\\zs[cC]')
	    if ! empty(l:caseSigil)
		let l:isSwitchedCase = 1
		let l:isCurrentCaseSensitive = (l:caseSigil ==# 'C')

		let l:atomsMultisAndSoOn[l:i - 1] = substitute(l:atomsMultisAndSoOn[l:i - 1], '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\[cC]', '', 'g')
	    endif
	endif

	call add(l:caseSensitiveOrdinaryAtoms, l:isCurrentCaseSensitive ? l:ordinaryAtoms[l:i] : '')
	call add(l:caseInsensitiveOrdinaryAtoms, l:isCurrentCaseSensitive ? '' : l:ordinaryAtoms[l:i])
    endfor

    if ! l:isSwitchedCase
	return a:pattern
    endif

    call map(l:caseInsensitiveOrdinaryAtoms, 's:MakeCaseInsensitive(v:val)')

    let l:transformedOrdinaryAtoms = ingo#list#merge#Distinct(l:caseInsensitiveOrdinaryAtoms, l:caseSensitiveOrdinaryAtoms)

    return (&ignorecase ? '\C' : '') . join(ingo#list#Join(l:transformedOrdinaryAtoms, l:atomsMultisAndSoOn), '')
endfunction
function! s:MakeCaseInsensitive( pattern ) abort
    return substitute(a:pattern, '\a', '[\l&\u&]', 'g')
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :

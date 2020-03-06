" CmdlineSpecialEdits/IgnoreCase.vim: Ignore case in pattern.
"
" DEPENDENCIES:
"   - ingo-library.vim plugin
"
" Copyright: (C) 2020 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! s:CaseAtomExpr( ... ) abort
    return '^.*\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\' . (a:0 >= 2 ? a:1 . (empty(a:2) ? '[cC]' : '') : (a:0 ? a:1 : '[cC]'))
endfunction
function! CmdlineSpecialEdits#IgnoreCase#Mixed() abort
    let [l:cmdlineBeforePattern, l:searchPattern, l:cmdlineAfterPattern] = CmdlineSpecialEdits#ParseCurrentOrPreviousPattern('/')
    if l:searchPattern !~# s:CaseAtomExpr('c')
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
	    let l:caseSigil = matchstr(get(l:atomsMultisAndSoOn, l:i - 1, ''), s:CaseAtomExpr('\zs', ''))
	    if ! empty(l:caseSigil)
		let l:isSwitchedCase = 1
		let l:isCurrentCaseSensitive = (l:caseSigil ==# 'C')

		let l:atomsMultisAndSoOn[l:i - 1] = substitute(l:atomsMultisAndSoOn[l:i - 1], s:CaseAtomExpr(), '', 'g')
	    endif
	endif

	call add(l:caseSensitiveOrdinaryAtoms, l:isCurrentCaseSensitive ? l:ordinaryAtoms[l:i] : '')
	call add(l:caseInsensitiveOrdinaryAtoms, l:isCurrentCaseSensitive ? '' : l:ordinaryAtoms[l:i])
    endfor

    if ! l:isSwitchedCase
	return a:pattern
    endif

    let l:transformedCaseInsensitiveOrdinaryAtoms = ingo#list#merge#Distinct(
    \   map(copy(l:caseInsensitiveOrdinaryAtoms), 's:MakeCaseInsensitive(v:val)'),
    \   l:caseSensitiveOrdinaryAtoms
    \)

    let l:transformedCaseInsensitivePattern = (&ignorecase ? '\C' : '') . join(ingo#list#Join(l:transformedCaseInsensitiveOrdinaryAtoms, l:atomsMultisAndSoOn), '')
    return l:transformedCaseInsensitivePattern
endfunction
function! s:MakeCaseInsensitive( pattern ) abort
    return substitute(a:pattern, '\a', '[\l&\u&]', 'g')
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :

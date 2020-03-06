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

let s:transformedCaseInsensitivePattern = ''
let s:transformedCaseSensitivePattern = ''
function! CmdlineSpecialEdits#IgnoreCase#Mixed() abort
    let [l:cmdlineBeforePattern, l:searchPattern, l:cmdlineAfterPattern] = CmdlineSpecialEdits#ParseCurrentOrPreviousPattern('/')

    if l:searchPattern ==# s:transformedCaseInsensitivePattern
	return s:transformedCaseSensitivePattern
    elseif l:searchPattern ==# s:transformedCaseSensitivePattern
	return s:transformedCaseInsensitivePattern
    elseif l:searchPattern !~# s:CaseAtomExpr('c')
	return l:cmdlineBeforePattern . l:searchPattern . l:cmdlineAfterPattern
    else
	" As the transformation cannot be undone, add the original command-line
	" to the history, so that it can later be recalled.
	call histadd(getcmdtype(), l:cmdlineBeforePattern . l:searchPattern . l:cmdlineAfterPattern)

	return l:cmdlineBeforePattern . s:PartialIgnoreCase(l:searchPattern) . l:cmdlineAfterPattern
    endif
endfunction

function! s:PartialIgnoreCase( pattern )
    let l:result = s:Separate(a:pattern)
    if empty(l:result)
	return a:pattern
    endif

    let s:transformedCaseInsensitivePattern = s:TransformToCaseInsensitivePattern(l:result)
    let s:transformedCaseSensitivePattern = s:TransformToCaseSensitivePattern(l:result)
    return (ingo#collections#CharacterCountAscSort(s:transformedCaseInsensitivePattern, s:transformedCaseSensitivePattern) == 1 ?
    \   s:transformedCaseSensitivePattern :
    \   s:transformedCaseInsensitivePattern
    \)
endfunction
function! s:Separate( pattern )
    let [l:ordinaryAtoms, l:atomsMultisAndSoOn] =
    \   ingo#collections#SeparateItemsAndSeparators(ingo#regexp#magic#Normalize(a:pattern), ingo#regexp#parse#NonOrdinaryAtomExpr(), 1)

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

    return (l:isSwitchedCase ?
    \   {
    \       'caseInsensitiveOrdinaryAtoms': l:caseInsensitiveOrdinaryAtoms,
    \       'caseSensitiveOrdinaryAtoms': l:caseSensitiveOrdinaryAtoms,
    \       'atomsMultisAndSoOn': l:atomsMultisAndSoOn
    \   } :
    \   []
    \)
endfunction

function! s:TransformToCaseInsensitivePattern( o ) abort
    let l:transformedCaseInsensitiveOrdinaryAtoms = ingo#list#merge#Distinct(
    \   map(copy(a:o.caseInsensitiveOrdinaryAtoms), 's:MakeCaseInsensitive(v:val)'),
    \   a:o.caseSensitiveOrdinaryAtoms
    \)
    return (&ignorecase ? '\C' : '') .
    \   join(ingo#list#Join(l:transformedCaseInsensitiveOrdinaryAtoms, a:o.atomsMultisAndSoOn), '')
endfunction
function! s:TransformToCaseSensitivePattern( o ) abort
    let l:transformedCaseSensitiveOrdinaryAtoms = ingo#list#merge#Distinct(
    \   a:o.caseInsensitiveOrdinaryAtoms,
    \   map(copy(a:o.caseSensitiveOrdinaryAtoms), 's:MakeCaseSensitive(v:val)')
    \)
    return (&ignorecase ? '' : '\c') .
    \   join(ingo#list#Join(l:transformedCaseSensitiveOrdinaryAtoms, a:o.atomsMultisAndSoOn), '')
endfunction

function! s:MakeCaseInsensitive( pattern ) abort
    return substitute(a:pattern, '\a', '[\l&\u&]', 'g')
endfunction

function! s:MakeCaseSensitive( text ) abort
    let [l:other, l:runs] = ingo#collections#SeparateItemsAndSeparators(a:text, '\u\%(\L*\u\)\?\|\l\%(\U*\l\)\?', 1)

    let l:upperRuns = map(copy(l:runs), 'v:val =~# "^\\u" ? v:val : ""')
    let l:lowerRuns = map(copy(l:runs), 'v:val =~# "^\\l" ? v:val : ""')

    call map(l:upperRuns, 's:AddCaseAssertion(v:val, "u")')
    call map(l:lowerRuns, 's:AddCaseAssertion(v:val, "l")')

    let l:transformedRuns = ingo#list#merge#Distinct(
    \   l:upperRuns,
    \   l:lowerRuns
    \)

    return join(ingo#list#Join(l:transformedRuns, l:other), '')
endfunction
function! s:AddCaseAssertion( text, case ) abort
    let l:charCnt = ingo#compat#strchars(a:text)
    let l:caseAtom = '\' . a:case

    let l:runAssertion = printf('\%%(%s\{%d}\&%s\)', l:caseAtom, l:charCnt, a:text)
    let l:individualAssertions = substitute(a:text, '\a', '\=printf("\\%%(%s\\&%s\\)", l:caseAtom, submatch(0))', 'g')

    return (ingo#collections#CharacterCountAscSort(l:runAssertion, l:individualAssertions) == 1 ?
    \   l:individualAssertions :
    \   l:runAssertion
    \)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :

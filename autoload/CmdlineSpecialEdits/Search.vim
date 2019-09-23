" CmdlineSpecialEdits/Search.vim: Manipulate searches.
"
" DEPENDENCIES:
"   - ingo-library.vim plugin
"
" Copyright: (C) 2017-2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	003	24-Sep-2019	Integrate ** overload.
"	002	03-Nov-2017	Add CmdlineSpecialEdits#Search#ToggleGrouping().
"				Extend
"				CmdlineSpecialEdits#Search#ToggleWholeWord() to
"				also account for capture groups in pattern.
"	001	24-Jul-2017	file creation from ingomappings.vim

function! CmdlineSpecialEdits#Search#SwitchSearchMode()
    return s:modifiedSearchPattern
endfunction
function! s:StripSearchMode( mode, searchPattern )
    let l:flexibleWhitespacePattern = ingo#regexp#comments#GetFlexibleWhitespaceAndCommentPrefixPattern(0)
    let l:flexibleWhitespaceOrEmptyPattern = ingo#regexp#comments#GetFlexibleWhitespaceAndCommentPrefixPattern(1)
    if a:mode ==# '\V'
	" Toggle literal search.
	return substitute(a:searchPattern, '^\(\\c\)\?\\V', '\1', 'g')
    elseif a:mode ==# '\c'
	" Toggle case-insensitive search.
	return substitute(a:searchPattern, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\[cC]', '', 'g')
    elseif a:mode ==# l:flexibleWhitespacePattern
	if ingo#str#Contains(a:searchPattern, a:mode)
	    return substitute(a:searchPattern, '\V' . escape(a:mode, '\'), ' ', 'g')
	else
	    return substitute(a:searchPattern, a:mode, escape(a:mode, '\'), 'g')
	endif
    elseif a:mode ==# l:flexibleWhitespaceOrEmptyPattern
	if ingo#str#Contains(a:searchPattern, a:mode)
	    return substitute(a:searchPattern, '\V' . escape(a:mode, '\'), ' ', 'g')
	else
	    " Note: Cannot use a:mode == l:flexibleWhitespaceOrEmptyPattern
	    " here, as this would match between every character! Use the
	    " not-empty variant instead.
	    return substitute(a:searchPattern, l:flexibleWhitespacePattern, escape(a:mode, '\'), 'g')
	endif
    else
	throw 'ASSERT: Unknown mode ' . a:mode
    endif
endfunction
function! s:ToggleSearchModeExpression( modifierPattern, searchPattern )
    let l:strippedSearchPattern = s:StripSearchMode(a:modifierPattern, a:searchPattern)
    let s:modifiedSearchPattern = (l:strippedSearchPattern ==# a:searchPattern ? a:modifierPattern : '') . l:strippedSearchPattern
    return "\<C-\>e(CmdlineSpecialEdits#Search#SwitchSearchMode())\<CR>"
endfunction
function! CmdlineSpecialEdits#Search#SpecialSearchMode( key )
    if stridx('/?', getcmdtype()) == -1
	" Integrate with ** overload.
	if getcmdtype() ==# ':' && a:key ==# '*'
	    return CmdlineSpecialEdits#SpecialRange#LastSelection()
	endif

	return a:key
    endif

    if a:key ==# '_'
	let l:modifierPattern = ingo#regexp#comments#GetFlexibleWhitespaceAndCommentPrefixPattern(0)
    elseif a:key ==# '*'
	let l:modifierPattern = ingo#regexp#comments#GetFlexibleWhitespaceAndCommentPrefixPattern(1)
    else
	let l:modifierPattern = (a:key ==# getcmdtype() ? '\V' : '\c')
    endif
    if empty(getcmdline()) && stridx('/?', a:key) != -1 && a:key !=# getcmdtype()
	" Only trigger this branch for the [/?] keys that correspond to search
	" commands. The _ key is more likely to start a search pattern, and its
	" application at the start of the pattern makes far less sense.
	" If one wants to start a search with the opposite search command, one
	" has to enter it literally: /<C-v>? or ?<C-v>/, resp.
	return l:modifierPattern
    elseif getcmdpos() == 2 && getcmdline() ==# getcmdtype()
	return s:ToggleSearchModeExpression(l:modifierPattern, histget('search', -1))
    elseif getcmdpos() > 2 && strpart(getcmdline(), 0, getcmdpos() - 1) =~# '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!' . getcmdtype() . '$'
	let l:searchPattern = strpart(getcmdline(), 0, getcmdpos() - 2) . strpart(getcmdline(), getcmdpos() - 1)
	return s:ToggleSearchModeExpression(l:modifierPattern, l:searchPattern)
    endif

    return a:key
endfunction



function! CmdlineSpecialEdits#Search#ToggleMode( searchPattern )
    let l:strippedSearchPattern = s:StripSearchMode('\c', a:searchPattern)
    if a:searchPattern !=# l:strippedSearchPattern
	return '\V' . l:strippedSearchPattern
    endif

    let l:strippedSearchPattern = s:StripSearchMode('\V', a:searchPattern)
    if a:searchPattern !=# l:strippedSearchPattern
	return l:strippedSearchPattern
    endif

    return '\c' . a:searchPattern
endfunction
function! CmdlineSpecialEdits#Search#ToggleWholeWord( mode, searchPattern )
    if empty(a:searchPattern) && a:mode ==# 'c'
	call setcmdpos(3)
	return '\<\>'
    endif

    let l:strippedSearchPattern = substitute(a:searchPattern, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\[<>]', '', 'g')
    if a:searchPattern ==# l:strippedSearchPattern
	let [l:prefixAtoms, l:searchPattern] = matchlist(a:searchPattern, '^\(\%(\\[cCvVmM]\)*\)\(.*\)$')[1:2]
	let [l:groupingStart, l:groupedSearchPattern, l:groupingEnd] = matchlist(l:searchPattern, '^\(\%(\\%\?(\)*\)\(.\{-}\)\(\%(\\)\)\)*$')[1:3]
	return l:prefixAtoms . ingo#regexp#MakeWholeWordSearch(l:groupedSearchPattern, l:searchPattern)
    else
	return l:strippedSearchPattern
    endif
endfunction
function! CmdlineSpecialEdits#Search#ToggleGrouping( mode, searchPattern )
    if empty(a:searchPattern) && a:mode ==# 'c'
	call setcmdpos(3)
	return '\(\)'
    endif

    let l:strippedSearchPattern = substitute(a:searchPattern, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\[()]', '', 'g')
    if a:searchPattern ==# l:strippedSearchPattern
	let [l:prefixAtoms, l:searchPattern] = matchlist(a:searchPattern, '^\(\%(\\[cCvVmM]\)*\)\(.*\)$')[1:2]
	return l:prefixAtoms . '\(' . l:searchPattern . '\)'
    else
	return l:strippedSearchPattern
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :

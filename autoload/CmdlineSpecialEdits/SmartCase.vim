" CmdlineSpecialEdits/SmartCase.vim: Toggle normal / SmartCase.
"
" DEPENDENCIES:
"   - ingo-library.vim plugin
"
" Copyright: (C) 2014-2021 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! CmdlineSpecialEdits#SmartCase#ToggleCommand()
    let [l:cmdlineBeforeCursor, l:cmdlineAfterCursor] = CmdlineSpecialEdits#GetCurrentOrPreviousCmdline()

    let l:commandParse = ingo#cmdargs#range#Parse(l:cmdlineBeforeCursor, {'isAllowEmptyCommand': 0})  " Ensure that there's a command after the range.
    if empty(l:commandParse)
	return getcmdline()
    else
	let l:toggleSubstituteCommand = substitute(l:commandParse[4], '^s\%[ubstitute]\w\@!', '', '')
	let l:newCommand = 'SmartCase'
	let l:PatternConverter = function('ingo#smartcase#FromPattern')
	if l:toggleSubstituteCommand ==# l:commandParse[4]
	    " Try converting back: SmartCase -> normal pattern.
	    let l:toggleSubstituteCommand = substitute(l:commandParse[4], '^S\%[martCase]\w\@!', '', '')
	    let l:newCommand = 's'
	    let l:PatternConverter = function('ingo#smartcase#Undo')
	endif
	if l:toggleSubstituteCommand ==# l:commandParse[4]
	    return getcmdline()
	endif

	" Also convert the search pattern.
	let [l:separator, l:pattern, l:replacement, l:flags, l:count] = ingo#cmdargs#substitute#Parse(l:toggleSubstituteCommand, {'emptyPattern': @/, 'emptyReplacement': '', 'emptyFlags': ['', '']})
	if empty(l:pattern)
	    let l:toggleSubstituteCommand = l:newCommand . l:toggleSubstituteCommand
	else
	    let l:tail = (empty(l:flags) && empty(l:count) && ! ingo#str#EndsWith(l:cmdlineBeforeCursor, l:separator) ? '' : l:separator . l:flags . l:count)
	    let l:toggleSubstituteCommand = l:newCommand . l:separator . call(l:PatternConverter, [l:pattern]) . l:separator . l:replacement . l:tail
	endif

	let l:upToCommand = join(l:commandParse[1:3], '')
	let l:afterCommand = join(l:commandParse[5:7], '')
	let l:toggled = l:upToCommand . l:toggleSubstituteCommand . l:afterCommand
	call setcmdpos(strlen(l:toggled) + 1)
	return l:toggled . l:cmdlineAfterCursor
    endif
endfunction
function! CmdlineSpecialEdits#SmartCase#TogglePattern()
    let l:search = getcmdline()
    if empty(l:search)
	let l:search = histget('search', -1)
    endif

    if ingo#smartcase#IsSmartCasePattern(l:search)
	return ingo#smartcase#Undo(l:search)
    else
	return ingo#smartcase#FromPattern(l:search)
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :

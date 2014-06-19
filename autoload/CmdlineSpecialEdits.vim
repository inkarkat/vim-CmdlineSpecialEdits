" CmdlineSpecialEdits.vim: Useful replacements of parts of the cmdline.
"
" DEPENDENCIES:
"   - ingo/cmdargs/command.vim autoload script
"   - ingo/cmdargs/range.vim autoload script
"   - ingo/cmdargs/substitute.vim autoload script
"   - ingo/smartcase.vim autoload script
"
" Copyright: (C) 2012-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	004	20-Jun-2014	Add toggling between :substitute and :SmartCase
"				variants, and the corresponding search patterns.
"	003	08-Jul-2013	Move ingoexcommands.vim into ingo-library.
"	002	31-May-2013	Move the parsing of the command range back to
"				ingoexcommands.vim where we originally took the
"				pattern from.
"				Add recall of history commands regardless of the
"				range.
"	001	19-Jun-2012	file creation

function! s:GetCurrentOrPreviousCmdline()
    if empty(getcmdline())
	return [histget('cmd', -1), '']
    else
	return [strpart(getcmdline(), 0, getcmdpos() - 1), strpart(getcmdline(), getcmdpos() - 1)]
    endif
endfunction


function! CmdlineSpecialEdits#RemoveAllButRange()
    let [l:cmdlineBeforeCursor, l:cmdlineAfterCursor] = s:GetCurrentOrPreviousCmdline()

    let l:commandParse = ingo#cmdargs#range#Parse(l:cmdlineBeforeCursor, {'isAllowEmptyCommand': 0})  " Ensure that there's a command after the range.
    if empty(l:commandParse)
	return getcmdline()
    else
	let l:upToRange = join(l:commandParse[1:3], '')
	call setcmdpos(strlen(l:upToRange) + 1)
	return l:upToRange . l:cmdlineAfterCursor
    endif
endfunction
function! CmdlineSpecialEdits#RemoveCommandArguments()
    let [l:cmdlineBeforeCursor, l:cmdlineAfterCursor] = s:GetCurrentOrPreviousCmdline()

    let l:commandParse = ingo#cmdargs#command#Parse(l:cmdlineBeforeCursor, '\%([^|]\|\\|\)*$')
    if empty(l:commandParse)
	return getcmdline()
    else
	let [l:fullCommandUnderCursor, l:combiner, l:range, l:commandCommands, l:commandName, l:commandBang, l:commandDirectArgs, l:commandArgs] = l:commandParse
	let l:commandWithoutArgs = join([l:combiner, l:range, l:commandCommands, l:commandName, l:commandBang], '')

	let l:previousCommands = strpart(l:cmdlineBeforeCursor, 0, strridx(l:cmdlineBeforeCursor, l:fullCommandUnderCursor))
	let l:cmdlineWithoutArguments = l:previousCommands . l:commandWithoutArgs . (empty(l:commandArgs) ? '' : ' ')
	call setcmdpos(strlen(l:cmdlineWithoutArguments) + 1)
	return l:cmdlineWithoutArguments . l:cmdlineAfterCursor
    endif
endfunction
function! CmdlineSpecialEdits#RemoveCommandName()
    let [l:cmdlineBeforeCursor, l:cmdlineAfterCursor] = s:GetCurrentOrPreviousCmdline()

    let l:commandParse = ingo#cmdargs#command#Parse(l:cmdlineBeforeCursor, '\%([^|]\|\\|\)*$')
    if empty(l:commandParse)
	return getcmdline()
    else
	let [l:fullCommandUnderCursor, l:combiner, l:range, l:commandCommands, l:commandName, l:commandBang, l:commandDirectArgs, l:commandArgs] = l:commandParse
	let l:commandWithoutCommand = join([l:combiner, l:range, l:commandCommands], '')
	let l:commandArguments = join([l:commandDirectArgs, l:commandArgs], '')

	let l:previousCommands = strpart(l:cmdlineBeforeCursor, 0, strridx(l:cmdlineBeforeCursor, l:fullCommandUnderCursor))
	let l:cmdlineUpToCommand = l:previousCommands . l:commandWithoutCommand
	call setcmdpos(strlen(l:cmdlineUpToCommand) + 1)
	return l:cmdlineUpToCommand . l:commandArguments . l:cmdlineAfterCursor
    endif
endfunction

function! s:RecallHistoryWithoutRange( type, prefix, historyStartCnt )
    let l:cnt = a:historyStartCnt
    while 1
	let l:entry = histget(a:type, -1 * l:cnt)
	if empty(l:entry)
	    break
	endif
"****D echomsg '****' l:cnt string(l:entry)
	let l:commandParse = ingo#cmdargs#range#Parse(l:entry, {'isParseFirstRange': 1})
	if empty(l:commandParse) | continue | endif " Should not happen.
	let l:entryWithoutRange = l:commandParse[4]
	if strpart(l:entryWithoutRange, 0, len(a:prefix)) ==# a:prefix
	    " Since we parse the first found range, the combiner may only be
	    " whitespace, which we discard.
	    return [l:cnt, l:commandParse[1], l:entryWithoutRange]
	endif

	let l:cnt += 1
    endwhile

    " No matching items.
    return [0, '', '']
endfunction
let s:originalRangeCmdlineBeforeCursor = ''
let s:recalledRangeCmdlineBeforeCursor = ''
function! CmdlineSpecialEdits#RecallAnyRange()
    let [l:cmdlineBeforeCursor, l:cmdlineAfterCursor] = s:GetCurrentOrPreviousCmdline()

    let l:historyStartCnt = 1
    if l:cmdlineBeforeCursor ==# s:recalledRangeCmdlineBeforeCursor && s:historyCnt > 0
	" The recall mapping is executed with the same command line before the
	" cursor. To search further in the history, don't take the current
	" command line, but use the stored one and its recalled last history
	" index, and continue searching from there.
	let l:cmdlineBeforeCursor = s:originalRangeCmdlineBeforeCursor
	let l:historyStartCnt = s:historyCnt + 1
"****D echomsg '**** recall from' l:historyStartCnt string(l:cmdlineBeforeCursor)
    else
	let s:originalRangeCmdlineBeforeCursor = l:cmdlineBeforeCursor
	let s:recalledCommandWithoutRange = ''
    endif

    let l:commandParse = ingo#cmdargs#range#Parse(l:cmdlineBeforeCursor)
    let [l:combiner, l:commandCommands, l:upToRange, l:commandWithoutRange] = l:commandParse[1:4]
    while 1
	let [s:historyCnt, l:recalledCommandCommands, l:recalledCommandWithoutRange ]= s:RecallHistoryWithoutRange(getcmdtype(), l:commandWithoutRange, l:historyStartCnt)
	if s:historyCnt == 0
	    execute "normal! \<C-\>\<C-n>\<Esc>" | " Beep.
	    return getcmdline()
	endif
	if l:recalledCommandWithoutRange ==# s:recalledCommandWithoutRange
	    " The history may contain entries that only differ in their ranges,
	    " which here would appear as identical. Continue searching until we
	    " find a different command.
	    let l:historyStartCnt = s:historyCnt + 1
	else
	    break
	endif
    endwhile
    let s:recalledCommandWithoutRange = l:recalledCommandWithoutRange
"****D echomsg '****' string(l:upToRange) string(l:commandWithoutRange) '=>' string(l:recalledCommandWithoutRange)
    " Use commandCommands (e.g. :verbose) from the recalled history unless one
    " is given in the current command line.
    let s:recalledRangeCmdlineBeforeCursor = (empty(l:commandCommands) ? l:recalledCommandCommands : l:commandCommands) . l:upToRange . l:recalledCommandWithoutRange
    call setcmdpos(strlen(s:recalledRangeCmdlineBeforeCursor) + 1)
    return s:recalledRangeCmdlineBeforeCursor . l:cmdlineAfterCursor
endfunction



function! CmdlineSpecialEdits#ToggleSmartCaseCommand()
    let [l:cmdlineBeforeCursor, l:cmdlineAfterCursor] = s:GetCurrentOrPreviousCmdline()

    let l:commandParse = ingo#cmdargs#range#Parse(l:cmdlineBeforeCursor, {'isAllowEmptyCommand': 0})  " Ensure that there's a command after the range.
    if empty(l:commandParse)
	return getcmdline()
    else
	let l:toggleSubstituteCommand = substitute(l:commandParse[4], '^s\%[ubstitute]\w\@!', 'SmartCase', '')
	if l:toggleSubstituteCommand ==# l:commandParse[4]
	    " Try converting back: SmartCase -> normal pattern.
	    let l:toggleSubstituteCommand = substitute(l:commandParse[4], '^S\%[martCase]\w\@!', 's', '')
	else
	    " Also convert the search pattern.
	    let [l:separator, l:pattern, l:replacement, l:flags, l:count] = ingo#cmdargs#substitute#Parse(l:toggleSubstituteCommand[9:], {'emptyPattern': @/, 'emptyReplacement': '', 'emptyFlags': ['', '']})
	    if ! empty(l:pattern)
		let l:toggleSubstituteCommand = 'SmartCase' . l:separator . ingo#smartcase#FromPattern(l:pattern) . l:separator . l:replacement . l:separator . l:flags . l:count
	    endif
	endif
	if l:toggleSubstituteCommand ==# l:commandParse[4]
	    return getcmdline()
	endif

	let l:upToCommand = join(l:commandParse[1:3], '')
	let l:afterCommand = join(l:commandParse[5:7], '')
	let l:toggled = l:upToCommand . l:toggleSubstituteCommand . l:afterCommand
	call setcmdpos(strlen(l:toggled) + 1)
	return l:toggled . l:cmdlineAfterCursor
    endif
endfunction
function! CmdlineSpecialEdits#ToggleSmartCasePattern()
    let l:search = getcmdline()
    if ingo#smartcase#IsSmartCasePattern(l:search)
	return ingo#smartcase#Undo(l:search)
    else
	return ingo#smartcase#FromPattern(l:search)
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :

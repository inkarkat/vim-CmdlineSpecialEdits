" CmdlineSpecialEdits.vim: Useful replacements of parts of the cmdline.
"
" DEPENDENCIES:
"   - ingoexcommands.vim autoload script
"
" Copyright: (C) 2012 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
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

    let l:commandParse = ingoexcommands#ParseRange(l:cmdlineBeforeCursor, {'isAllowEmptyCommand': 0})  " Ensure that there's a command after the range.
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

    let l:commandParse = ingoexcommands#ParseCommand(l:cmdlineBeforeCursor, '\%([^|]\|\\|\)*$')
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

    let l:commandParse = ingoexcommands#ParseCommand(l:cmdlineBeforeCursor, '\%([^|]\|\\|\)*$')
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
	let l:commandParse = ingoexcommands#ParseRange(l:entry, {'isParseFirstRange': 1})
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
	" command line, but use the stored one and recalled history index, and
	" continue searching from there.
	let l:cmdlineBeforeCursor = s:originalRangeCmdlineBeforeCursor
	let l:historyStartCnt = s:historyCnt + 1
echomsg '**** recall from' l:historyStartCnt string(l:cmdlineBeforeCursor)
    else
	let s:originalRangeCmdlineBeforeCursor = l:cmdlineBeforeCursor
    endif

    let l:commandParse = ingoexcommands#ParseRange(l:cmdlineBeforeCursor)
    let [l:combiner, l:commandCommands, l:upToRange, l:commandWithoutRange] = l:commandParse[1:4]
    let [s:historyCnt, l:recalledCommandCommands, l:recalledCommandWithoutRange ]= s:RecallHistoryWithoutRange(getcmdtype(), l:commandWithoutRange, l:historyStartCnt)
echomsg '****' string(l:upToRange) string(l:commandWithoutRange) '=>' string(l:recalledCommandWithoutRange)
    if s:historyCnt == 0
	return getcmdline()
    endif

    " Use commandCommands (e.g. :verbose) from the recalled history unless one
    " is given in the current command line.
    let s:recalledRangeCmdlineBeforeCursor = (empty(l:commandCommands) ? l:recalledCommandCommands : l:commandCommands) . l:upToRange . l:recalledCommandWithoutRange
    call setcmdpos(strlen(s:recalledRangeCmdlineBeforeCursor) + 1)
    return s:recalledRangeCmdlineBeforeCursor . l:cmdlineAfterCursor
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :

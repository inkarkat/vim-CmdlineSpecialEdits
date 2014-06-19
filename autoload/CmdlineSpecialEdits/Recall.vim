" CmdlineSpecialEdits/Recall.vim: Recall command-line from history.
"
" DEPENDENCIES:
"   - CmdlineSpecialEdits.vim autoload script
"   - ingo/cmdargs/range.vim autoload script
"   - ingo/cmdargs/substitute.vim autoload script
"
" Copyright: (C) 2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	001	20-Jun-2014	file creation

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
function! CmdlineSpecialEdits#Recall#AnyRange()
    let [l:cmdlineBeforeCursor, l:cmdlineAfterCursor] = CmdlineSpecialEdits#GetCurrentOrPreviousCmdline()

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

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :

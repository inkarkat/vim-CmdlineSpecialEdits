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

    " Regexp modeled after the one in ingoexcommands#ParseCommand().
    let l:upToRangeExpr =
    \	'^\%(.*\\\@<!|\)\?\s*' .
    \	'\%(' . ingoexcommands#GetCommandCommandsExpr() . '\)\?' .
    \   ingoexcommands#RangeExpr() . '\ze\s*\h'
    let l:upToRange = matchstr(l:cmdlineBeforeCursor, l:upToRangeExpr)
    if empty(l:upToRange)
	return getcmdline()
    else
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

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :

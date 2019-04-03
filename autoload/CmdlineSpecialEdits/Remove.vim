" CmdlineSpecialEdits/Remove.vim: Remove part of the command-line.
"
" DEPENDENCIES:
"   - CmdlineSpecialEdits.vim autoload script
"   - ingo/cmdargs/command.vim autoload script
"   - ingo/cmdargs/range.vim autoload script
"
" Copyright: (C) 2014-2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	002	24-Jul-2017	Add CmdlineSpecialEdits#Remove#Backspacing() and
"				CmdlineSpecialEdits#Remove#LastPathComponent()
"				from ingomappings.vim
"	001	20-Jun-2014	file creation

function! CmdlineSpecialEdits#Remove#AllButRange()
    let [l:cmdlineBeforeCursor, l:cmdlineAfterCursor] = CmdlineSpecialEdits#GetCurrentOrPreviousCmdline()

    let l:commandParse = ingo#cmdargs#range#Parse(l:cmdlineBeforeCursor, {'isAllowEmptyCommand': 0})  " Ensure that there's a command after the range.
    if empty(l:commandParse)
	return getcmdline()
    else
	let l:upToRange = join(l:commandParse[1:3], '')
	call setcmdpos(strlen(l:upToRange) + 1)
	return l:upToRange . l:cmdlineAfterCursor
    endif
endfunction
function! CmdlineSpecialEdits#Remove#CommandArguments()
    let [l:cmdlineBeforeCursor, l:cmdlineAfterCursor] = CmdlineSpecialEdits#GetCurrentOrPreviousCmdline()

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
function! CmdlineSpecialEdits#Remove#CommandName()
    let [l:cmdlineBeforeCursor, l:cmdlineAfterCursor] = CmdlineSpecialEdits#GetCurrentOrPreviousCmdline()

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

function! CmdlineSpecialEdits#Remove#Backspacing( cmdline )
    let l:translatedCmdline = substitute(a:cmdline, '.kb', '\=char2nr(submatch(0)[0]) == 128 ? nr2char(8) : submatch(0)', 'g')
    while 1
	let l:oldLen = len(l:translatedCmdline)
	let l:translatedCmdline = substitute(l:translatedCmdline, '[^]', '', 'g')
	if len(l:translatedCmdline) == l:oldLen
	    break
	endif
    endwhile
    return l:translatedCmdline
endfunction

function! CmdlineSpecialEdits#Remove#LastPathComponent()
    let l:cmdlineBeforeCursor = strpart(getcmdline(), 0, getcmdpos() - 1)
    let l:cmdlineAfterCursor = strpart(getcmdline(), getcmdpos() - 1)

    let l:cmdlineRoot = fnamemodify(cmdlineBeforeCursor, ':r')
    let l:result = (l:cmdlineBeforeCursor ==# l:cmdlineRoot ? substitute(l:cmdlineBeforeCursor, '\%(\\ \|[\\/]\@!\f\)\+[\\/]\=$\|.$', '', '') : l:cmdlineRoot)
    call setcmdpos(strlen(l:result) + 1)
    return l:result . l:cmdlineAfterCursor
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :

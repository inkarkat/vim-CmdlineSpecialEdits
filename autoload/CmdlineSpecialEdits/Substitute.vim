" CmdlineSpecialEdits/Substitute.vim: Manipulate substitutions.
"
" DEPENDENCIES:
"   - ingo-library.vim plugin
"
" Copyright: (C) 2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	001	08-Jul-2019	file creation
let s:save_cpo = &cpo
set cpo&vim

function! CmdlineSpecialEdits#Substitute#ChangeSeparator() abort
    let l:newSeparator = ingo#query#get#Char({'validExpr': '[[:alnum:]\\"|]\@![\x00-\xFF]'})

    let [l:cmdlineBeforeCursor, l:cmdlineAfterCursor] = CmdlineSpecialEdits#GetCurrentOrPreviousCmdline()
    let l:cmdline = l:cmdlineBeforeCursor . l:cmdlineAfterCursor

    let l:commandParse = ingo#cmdargs#command#Parse(l:cmdline, '.*$')
    if empty(l:commandParse)
	return getcmdline()
    else
	let [l:fullCommandUnderCursor, l:combiner, l:range, l:commandCommands, l:commandName, l:commandBang, l:commandDirectArgs, l:commandArgs] = l:commandParse
	let l:commandWithoutArgs = join([l:combiner, l:range, l:commandCommands, l:commandName, l:commandBang], '')
	let l:previousCommands = strpart(l:cmdline, 0, strridx(l:cmdline, l:fullCommandUnderCursor))
	let l:args = l:commandDirectArgs . l:commandArgs
	if empty(l:args)
	    return getcmdline()
	endif

	let [l:separator, l:pattern, l:replacement, l:flags, l:count] = ingo#cmdargs#substitute#Parse(l:args)
	if empty(l:separator)
	    return getcmdline()
	endif

	let l:separatorCnt = ingo#matches#CountMatches(l:args, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\C\V' . escape(l:separator, '\'))
	if l:separatorCnt == 0
	    return getcmdline()
	endif

	let l:args =
	\   l:newSeparator .
	\   s:Reescape(l:separator, l:newSeparator, l:pattern) .
	\   (l:separatorCnt >= 2 ? l:newSeparator : '') .
	\   s:Reescape(l:separator, l:newSeparator, l:replacement) .
	\   (l:separatorCnt >= 3 ? l:newSeparator : '') .
	\   l:flags . l:count

	return l:previousCommands . l:commandWithoutArgs . l:args
    endif
endfunction
function! s:Reescape( oldSep, newSep, string ) abort
    return ingo#escape#OnlyUnescaped(ingo#escape#Unescape(a:string, a:oldSep), a:newSep)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :

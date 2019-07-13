" CmdlineSpecialEdits.vim: Useful replacements of parts of the cmdline.
"
" DEPENDENCIES:
"   - ingo/cmdargs/command.vim autoload script
"   - ingo/cmdargs/pattern.vim autoload script
"
" Copyright: (C) 2012-2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	007	21-Nov-2017	Add
"				CmdlineSpecialEdits#ParseCurrentOrPreviousPattern()
"				variant for pattern extraction, also from a
"				(:substitute et al.) Ex command-line.
"	006	31-Oct-2017	Allow overriding cmdtype used for history
"				recall.
"	005	30-Mar-2015	Use current command-line type instead of
"				always Ex command history.
"	004	20-Jun-2014	Add toggling between :substitute and :SmartCase
"				variants, and the corresponding search patterns.
"	003	08-Jul-2013	Move ingoexcommands.vim into ingo-library.
"	002	31-May-2013	Move the parsing of the command range back to
"				ingoexcommands.vim where we originally took the
"				pattern from.
"				Add recall of history commands regardless of the
"				range.
"	001	19-Jun-2012	file creation

function! CmdlineSpecialEdits#GetCurrentCmdline() abort
    return [strpart(getcmdline(), 0, getcmdpos() - 1), strpart(getcmdline(), getcmdpos() - 1)]
endfunction

function! CmdlineSpecialEdits#GetCurrentOrPreviousCmdline( ... )
    if empty(getcmdline())
	let l:cmdtype = (a:0 ? a:1 : getcmdtype())
	return [histget(l:cmdtype, -1), '']
    else
	return [strpart(getcmdline(), 0, getcmdpos() - 1), strpart(getcmdline(), getcmdpos() - 1)]
    endif
endfunction

function! CmdlineSpecialEdits#ParseCurrentOrPreviousPattern( ... )
    let l:cmdline = join(call('CmdlineSpecialEdits#GetCurrentOrPreviousCmdline', a:000), '')

    if getcmdtype() !~# '^[:>]$' | return ['', l:cmdline, ''] | endif

    let l:commandParse = ingo#cmdargs#command#Parse(l:cmdline, '.*$')
    if empty(l:commandParse) | return ['', l:cmdline, ''] | endif

    let [l:separator, l:escapedPattern, l:flags] = ingo#cmdargs#pattern#RawParse(l:commandParse[6] . l:commandParse[7], '', '\(.*\)')
    if empty(l:escapedPattern) | return ['', l:cmdline, ''] | endif

    let l:previousCommands = strpart(l:cmdline, 0, len(l:cmdline) - len(l:commandParse[0]))
    return [
    \   l:previousCommands . join(l:commandParse[1:5], '') . l:separator,
    \   l:escapedPattern,
    \   l:separator . l:flags
    \]
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :

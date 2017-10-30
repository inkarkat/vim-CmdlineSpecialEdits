" CmdlineSpecialEdits.vim: Useful replacements of parts of the cmdline.
"
" DEPENDENCIES:
"
" Copyright: (C) 2012-2015 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
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

function! CmdlineSpecialEdits#GetCurrentOrPreviousCmdline()
    if empty(getcmdline())
	return [histget(getcmdtype(), -1), '']
    else
	return [strpart(getcmdline(), 0, getcmdpos() - 1), strpart(getcmdline(), getcmdpos() - 1)]
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :

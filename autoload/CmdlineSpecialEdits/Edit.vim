" CmdlineSpecialEdits/Edit.vim: Edit the command-line.
"
" DEPENDENCIES:
"   - CmdlineSpecialEdits.vim autoload script
"
" Copyright: (C) 2015-2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	003	31-Oct-2017	DWIM: Always recall from search history, not
"				command-line history.
"	002	24-Jul-2017	Add CmdlineSpecialEdits#Edit#YankCommandLine().
"	001	30-Mar-2015	file creation

function! CmdlineSpecialEdits#Edit#AddPrefix()
    let [l:cmdlineBeforeCursor, l:cmdlineAfterCursor] = CmdlineSpecialEdits#GetCurrentOrPreviousCmdline('/')

    let [l:startAnchor, l:pattern] = matchlist(l:cmdlineBeforeCursor . l:cmdlineAfterCursor, '^\(\^\|\\%\^\)\?\(.*\)$')[1:2]
    if l:pattern !~# '^\\%\?(.*\\)$'
	let l:pattern = '\%(' . l:pattern . '\)'
    endif

    call setcmdpos(strlen(l:startAnchor) + 1)
    return l:startAnchor . l:pattern
endfunction
function! CmdlineSpecialEdits#Edit#AddSuffix()
    let [l:cmdlineBeforeCursor, l:cmdlineAfterCursor] = CmdlineSpecialEdits#GetCurrentOrPreviousCmdline('/')

    let [l:pattern, l:endAnchor] = matchlist(l:cmdlineBeforeCursor . l:cmdlineAfterCursor, '^\(.\{-}\)\(\$\|\\%\$\)\?$')[1:2]
    if l:pattern !~# '^\\%\?(.*\\)$'
	let l:pattern = '\%(' . l:pattern . '\)'
    endif

    call setcmdpos(strlen(l:pattern) + 1)
    return l:pattern . l:endAnchor
endfunction

function! CmdlineSpecialEdits#Edit#YankCommandLine( cmdline )
    let @" = a:cmdline
    return a:cmdline
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :

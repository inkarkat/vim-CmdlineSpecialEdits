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
"	004	21-Nov-2017	ENH: Use new
"				CmdlineSpecialEdits#ParseCurrentOrPreviousPattern()
"				to also handle patterns within Ex commands.
"	003	31-Oct-2017	DWIM: Always recall from search history, not
"				command-line history.
"	002	24-Jul-2017	Add CmdlineSpecialEdits#Edit#YankCommandLine().
"	001	30-Mar-2015	file creation

function! CmdlineSpecialEdits#Edit#AddPrefix()
    let [l:cmdlineBeforePattern, l:searchPattern, l:cmdlineAfterPattern] = CmdlineSpecialEdits#ParseCurrentOrPreviousPattern('/')

    let [l:startAnchor, l:pattern] = matchlist(l:searchPattern, '^\(\^\|\\%\^\)\?\(.*\)$')[1:2]
    if l:pattern !~# '^\\%\?(.*\\)$'
	let l:pattern = '\%(' . l:pattern . '\)'
    endif

    call setcmdpos(strlen(l:cmdlineBeforePattern . l:startAnchor) + 1)
    return l:cmdlineBeforePattern . l:startAnchor . l:pattern . l:cmdlineAfterPattern
endfunction
function! CmdlineSpecialEdits#Edit#AddSuffix()
    let [l:cmdlineBeforePattern, l:searchPattern, l:cmdlineAfterPattern] = CmdlineSpecialEdits#ParseCurrentOrPreviousPattern('/')

    let [l:pattern, l:endAnchor] = matchlist(l:searchPattern, '^\(.\{-}\)\(\$\|\\%\$\)\?$')[1:2]
    if l:pattern !~# '^\\%\?(.*\\)$'
	let l:pattern = '\%(' . l:pattern . '\)'
    endif

    call setcmdpos(strlen(l:cmdlineBeforePattern . l:pattern) + 1)
    return l:cmdlineBeforePattern . l:pattern . l:endAnchor . l:cmdlineAfterPattern
endfunction

function! CmdlineSpecialEdits#Edit#YankCommandLine( cmdline )
    let @" = a:cmdline
    return a:cmdline
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :

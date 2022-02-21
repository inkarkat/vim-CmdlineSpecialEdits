" CmdlineSpecialEdits/Edit.vim: Edit the command-line.
"
" DEPENDENCIES:
"
" Copyright: (C) 2015-2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

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

function! CmdlineSpecialEdits#Edit#RegisterYankCommandLine( cmdline )
    let l:register = ingo#query#get#WritableRegister()
    if empty(l:register)
	execute "normal! \<C-\>\<C-n>\<Esc>" | " Beep.
	return a:cmdline
    endif

    call setreg(l:register, a:cmdline)
    return a:cmdline
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :

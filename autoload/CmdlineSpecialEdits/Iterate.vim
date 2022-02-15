" CmdlineSpecialEdits/Iterate.vim: Prepend buffer iteration command to command.
"
" DEPENDENCIES:
"
" Copyright: (C) 2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! CmdlineSpecialEdits#Iterate#Prepend( iterationCommand ) abort
    let [l:cmdlineBeforeCursor, l:cmdlineAfterCursor] = CmdlineSpecialEdits#GetCurrentOrPreviousCmdline()

    call setcmdpos(strlen(l:cmdlineBeforeCursor) + len(a:iterationCommand) + 1)
    return a:iterationCommand . ' ' . l:cmdlineBeforeCursor . l:cmdlineAfterCursor
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :

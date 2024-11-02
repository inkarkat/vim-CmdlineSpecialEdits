" CmdlineSpecialEdits/Iterate.vim: Prepend buffer iteration command to command.
"
" DEPENDENCIES:
"   - ingo-library.vim plugin
"
" Copyright: (C) 2022-2023 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! s:AddErrorSuppressionFlag( cmdline ) abort
    let l:cmdline = a:cmdline
    let l:commandParse = ingo#cmdargs#command#Parse(l:cmdline, '.*$')
    if empty(l:commandParse)
	return a:cmdline
    endif

    let [l:lastFullCommand, l:combiner, l:commandCommands, l:range, l:commandName, l:commandBang, l:commandDirectArgs, l:commandArgs] = l:commandParse
    let l:changedCommand = l:lastFullCommand
    if l:commandName !~# '^s\%[ubstitute]$' . (empty(g:CmdlineSpecialEdits_SubstitutionCommandsExpr) ? '' : '\|' . g:CmdlineSpecialEdits_SubstitutionCommandsExpr)
	return a:cmdline
    endif

    " :substitute or an alike custom command.
    let [l:commandArgsWhitespace, l:commandArgs] = matchlist(l:commandArgs, '^\(\s*\)\(.*\)$')[1:2] " Need to remove the preceding whitespace, as ingo#cmdargs#substitute#Parse() would treat it as a separator.
    let [l:separator, l:pattern, l:replacement, l:flags, l:count] =
    \	ingo#cmdargs#substitute#Parse(l:commandDirectArgs . l:commandArgs, {'emptyReplacement': '', 'emptyFlags': ['', '']})
    if l:flags =~# 'e'
	return a:cmdline
    endif

    let l:changedCommand = l:combiner . l:commandCommands . l:range . l:commandName . l:commandBang . l:commandArgsWhitespace .
    \   l:separator . l:pattern . l:separator . l:replacement . l:separator .
    \   l:flags . 'e' . l:count

    return ingo#str#remove#Trailing(l:cmdline, l:lastFullCommand) . l:changedCommand
endfunction

function! CmdlineSpecialEdits#Iterate#Prepend( iterationCommand ) abort
    let [l:cmdlineBeforeCursor, l:cmdlineAfterCursor] = CmdlineSpecialEdits#GetCurrentOrPreviousCmdline()

    call setcmdpos(len(l:cmdlineBeforeCursor) + len(a:iterationCommand) + 2)
    return a:iterationCommand . ' ' . s:AddErrorSuppressionFlag(l:cmdlineBeforeCursor . l:cmdlineAfterCursor)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :

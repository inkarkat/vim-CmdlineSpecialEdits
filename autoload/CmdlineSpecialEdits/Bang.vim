" CmdlineSpecialEdits/Bang.vim: Toggle bang of command.
"
" DEPENDENCIES:
"
" Copyright: (C) 2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! CmdlineSpecialEdits#Bang#Toggle() abort
    let [l:cmdlineBeforeCursor, l:cmdlineAfterCursor] = CmdlineSpecialEdits#GetCurrentOrPreviousCmdline()

    let l:commandParse = ingo#cmdargs#command#Parse(l:cmdlineBeforeCursor, '.*$')
    if empty(l:commandParse)
	return getcmdline()
    endif

    let [l:fullCommandUnderCursor, l:combiner, l:range, l:commandCommands, l:commandName, l:commandBang, l:commandDirectArgs, l:commandArgs] = l:commandParse

    let [l:commandBang, l:cursorOffset] = (empty(l:commandBang) ? ['!', 1] : ['', -1])

    let l:commandWithToggledBang = join([l:combiner, l:range, l:commandCommands, l:commandName, l:commandBang, l:commandDirectArgs, l:commandArgs], '')
    let l:previousCommands = strpart(l:cmdlineBeforeCursor, 0, strridx(l:cmdlineBeforeCursor, l:fullCommandUnderCursor))

    call setcmdpos(strlen(l:cmdlineBeforeCursor) + 1 + l:cursorOffset)
    return l:previousCommands . l:commandWithToggledBang . l:cmdlineAfterCursor
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :

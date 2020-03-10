" CmdlineSpecialEdits.vim: Useful replacements of parts of the cmdline.
"
" DEPENDENCIES:
"   - ingo-library.vim plugin
"
" Copyright: (C) 2012-2020 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

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

" CmdlineSpecialEdits/Literal.vim: Insert literal register into command-line.
"
" DEPENDENCIES:
"   - ingo-library.vim plugin
"
" Copyright: (C) 2019-2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

function! s:AppendLiteralPattern( existingPattern, registerContents, separator ) abort
    let l:veryNoMagicRegister = escape(a:registerContents, '\' . a:separator)

    let l:isVeryNoMagicSearch = (a:existingPattern =~# '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\V\%(.*\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\m\)\@!')
    if l:isVeryNoMagicSearch
	" If we already have a "very nomagic" search, stay in that mode (and
	" don't prepend another \V).
	let l:literalPattern = l:veryNoMagicRegister
    else
	" Use very nomagic, or escaping of individual characters, whatever
	" is shorter.
	let l:escapedRegister = ingo#regexp#EscapeLiteralText(a:registerContents, a:separator)
	let l:literalPattern = (len(l:escapedRegister) <= len(l:veryNoMagicRegister) ?
	    \l:escapedRegister :
	    \'\V' . l:veryNoMagicRegister
	\)
    endif
    return a:existingPattern . l:literalPattern
endfunction
function! s:LiteralSubstitute( existingCommand, registerContents, args ) abort
    " Determine where we are (pattern or replacement) by appending (i.e. at the
    " current cursor position) a <Nul> character and searching for it.
    let l:sentinel = "\<Nul>"
    let [l:separator, l:pattern, l:replacement, l:flags, l:count] =
    \   ingo#cmdargs#substitute#Parse(a:args . l:sentinel, {'emptyReplacement': '', 'emptyFlags': ['', '']})

    if l:replacement =~# l:sentinel
	return a:existingCommand . ingo#regexp#EscapeLiteralReplacement(a:registerContents, l:separator)
    else
	" This is also the fallback for any other location.
	return s:AppendLiteralPattern(a:existingCommand, a:registerContents, l:separator)
    endif
endfunction
function! s:LiteralPut( existingCommand, registerContents, args ) abort
    let l:sigil = (a:args =~# '^\s*$' ? '=' : '')
    return a:existingCommand . l:sigil . '\"' . substitute(escape(escape(a:registerContents, '\"|'), '\'), '\n', '\\n', 'g') . '\"'
endfunction
function! CmdlineSpecialEdits#Literal#Register() abort
    let [l:cmdlineBeforeCursor, l:cmdlineAfterCursor] = CmdlineSpecialEdits#GetCurrentCmdline()
    let l:registerContents = getreg(ingo#query#get#Register({'errorRegister': '\'}))

    if getcmdtype() =~# '^[:>]$'
	let l:commandParse = ingo#cmdargs#command#Parse(l:cmdlineBeforeCursor, '.*$')
	if ! empty(l:commandParse)
	    let [l:fullCommandUnderCursor, l:combiner, l:range, l:commandCommands, l:commandName, l:commandBang, l:commandDirectArgs, l:commandArgs] = l:commandParse

	    if l:commandName =~# '^pu\%[t]$'
		let l:resultBeforeCursor = s:LiteralPut(l:cmdlineBeforeCursor, l:registerContents, l:commandDirectArgs . l:commandArgs)
		call setcmdpos(strlen(l:resultBeforeCursor) + 1)
		return l:resultBeforeCursor . l:cmdlineAfterCursor
	    elseif l:commandName =~# '^s\%[ubstitute]$' . (empty(g:CmdlineSpecialEdits_SubstitutionCommandsExpr) ? '' : '\|' . g:CmdlineSpecialEdits_SubstitutionCommandsExpr) ||
	    \   ingo#str#Trim(l:commandDirectArgs . l:commandArgs . l:cmdlineAfterCursor) =~# '^' . ingo#cmdargs#pattern#PatternExpr() . '$'
		" :substitute or an alike custom command.
		let l:resultBeforeCursor =  s:LiteralSubstitute(l:cmdlineBeforeCursor, l:registerContents, l:commandDirectArgs . l:commandArgs)
		call setcmdpos(strlen(l:resultBeforeCursor) + 1)
		return l:resultBeforeCursor . l:cmdlineAfterCursor
	    endif
	endif

	" Fall back to inserting as a literal Vimscript String.
	let l:resultBeforeCursor = l:cmdlineBeforeCursor . string(l:registerContents)
	call setcmdpos(strlen(l:resultBeforeCursor) + 1)
	return l:resultBeforeCursor . l:cmdlineAfterCursor
    endif

    " Fall back to regexp pattern escaping.
    let l:resultBeforeCursor = s:AppendLiteralPattern(l:cmdlineBeforeCursor, l:registerContents, matchstr(getcmdtype(), '[/?]'))
    call setcmdpos(strlen(l:resultBeforeCursor) + 1)
    return l:resultBeforeCursor . l:cmdlineAfterCursor
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :

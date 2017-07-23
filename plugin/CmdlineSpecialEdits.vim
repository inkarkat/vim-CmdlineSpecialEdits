" CmdlineSpecialEdits.vim: Useful replacements of parts of the cmdline.
"
" DEPENDENCIES:
"   - Requires Vim 7.0 or higher.
"   - CmdlineSpecialEdits/*.vim autoload scripts
"
" Copyright: (C) 2012-2015 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	006	30-Mar-2015	Add mappings for adding regexp prefix / suffix.
"	005	28-Dec-2014	Allow to configure all considered marks via
"				g:CmdlineSpecialEdits_SymbolicRangeConsideredMarks.
"	004	26-Dec-2014	Add configuration for symbolic ranges.
"	003	25-Dec-2014	Add toggling between symbolic and number ranges.
"	002	20-Jun-2014	Add toggling between :substitute and :SmartCase
"				variants, and the corresponding search patterns.
"	001	19-Jun-2012	file creation

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_CmdlineSpecialEdits') || (v:version < 700)
    finish
endif
let g:loaded_CmdlineSpecialEdits = 1

"- configuration ---------------------------------------------------------------

if ! exists('g:CmdlineSpecialEdits_SymbolicRangeConsideredMarks')
    let g:CmdlineSpecialEdits_SymbolicRangeConsideredMarks = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789<>[]`"^.#'
endif
if ! exists('g:CmdlineSpecialEdits_SymbolicRangeMaximumOffset')
    let g:CmdlineSpecialEdits_SymbolicRangeMaximumOffset = 3
endif


"- mappings --------------------------------------------------------------------

cnoremap <Plug>(CmdlineSpecialRemoveAllButRange) <C-\>e(CmdlineSpecialEdits#Remove#AllButRange())<CR>
if ! hasmapto('<Plug>(CmdlineSpecialRemoveAllButRange)', 'c')
    cmap <C-g><C-u> <Plug>(CmdlineSpecialRemoveAllButRange)
endif

cnoremap <Plug>(CmdlineSpecialRemoveCommandArguments) <C-\>e(CmdlineSpecialEdits#Remove#CommandArguments())<CR>
if ! hasmapto('<Plug>(CmdlineSpecialRemoveCommandArguments)', 'c')
    cmap <C-g><C-a> <Plug>(CmdlineSpecialRemoveCommandArguments)
endif

cnoremap <Plug>(CmdlineSpecialRemoveCommandName) <C-\>e(CmdlineSpecialEdits#Remove#CommandName())<CR>
if ! hasmapto('<Plug>(CmdlineSpecialRemoveCommandName)', 'c')
    cmap <C-g><C-c> <Plug>(CmdlineSpecialRemoveCommandName)
endif

cnoremap <Plug>(CmdlineSpecialRecallAnyRange) <C-\>e(CmdlineSpecialEdits#Recall#AnyRange())<CR>
if ! hasmapto('<Plug>(CmdlineSpecialRecallAnyRange)', 'c')
    cmap <C-g><C-o> <Plug>(CmdlineSpecialRecallAnyRange)
endif

cnoremap <expr> <Plug>(CmdlineSpecialToggleSmartCase) (stridx('/?', getcmdtype()) == -1 ? (getcmdtype() ==# ':' ? '<C-\>e(CmdlineSpecialEdits#SmartCase#ToggleCommand())<CR>' : '<C-s>') : '<C-\>e(CmdlineSpecialEdits#SmartCase#TogglePattern())<CR>')
if ! hasmapto('<Plug>(CmdlineSpecialToggleSmartCase)', 'c')
    cmap <C-g><C-s> <Plug>(CmdlineSpecialToggleSmartCase)
endif

cnoremap <Plug>(CmdlineSpecialToggleSymbolicRange) <C-\>e(CmdlineSpecialEdits#Range#ToggleSymbolic())<CR>
if ! hasmapto('<Plug>(CmdlineSpecialToggleSymbolicRange)', 'c')
    cmap <C-g>' <Plug>(CmdlineSpecialToggleSymbolicRange)
endif

cnoremap <Plug>(CmdlineSpecialAddPrefix) <C-\>e(CmdlineSpecialEdits#Edit#AddPrefix())<CR>
if ! hasmapto('<Plug>(CmdlineSpecialAddPrefix)', 'c')
    cmap <C-g>I <Plug>(CmdlineSpecialAddPrefix)
endif
cnoremap <Plug>(CmdlineSpecialAddSuffix) <C-\>e(CmdlineSpecialEdits#Edit#AddSuffix())<CR>
if ! hasmapto('<Plug>(CmdlineSpecialAddSuffix)', 'c')
    cmap <C-g>A <Plug>(CmdlineSpecialAddSuffix)
endif

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :

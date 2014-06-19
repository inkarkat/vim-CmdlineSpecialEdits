" CmdlineSpecialEdits.vim: Useful replacements of parts of the cmdline.
"
" DEPENDENCIES:
"   - Requires Vim 7.0 or higher.
"   - CmdlineSpecialEdits.vim autoload script
"
" Copyright: (C) 2012-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	002	20-Jun-2014	Add toggling between :substitute and :SmartCase
"				variants, and the corresponding search patterns.
"	001	19-Jun-2012	file creation

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_CmdlineSpecialEdits') || (v:version < 700)
    finish
endif
let g:loaded_CmdlineSpecialEdits = 1

cnoremap <Plug>(CmdlineSpecialRemoveAllButRange) <C-\>e(CmdlineSpecialEdits#RemoveAllButRange())<CR>
if ! hasmapto('<Plug>(CmdlineSpecialRemoveAllButRange)', 'c')
    cmap <C-g><C-u> <Plug>(CmdlineSpecialRemoveAllButRange)
endif

cnoremap <Plug>(CmdlineSpecialRemoveCommandArguments) <C-\>e(CmdlineSpecialEdits#RemoveCommandArguments())<CR>
if ! hasmapto('<Plug>(CmdlineSpecialRemoveCommandArguments)', 'c')
    cmap <C-g><C-a> <Plug>(CmdlineSpecialRemoveCommandArguments)
endif

cnoremap <Plug>(CmdlineSpecialRemoveCommandName) <C-\>e(CmdlineSpecialEdits#RemoveCommandName())<CR>
if ! hasmapto('<Plug>(CmdlineSpecialRemoveCommandName)', 'c')
    cmap <C-g><C-c> <Plug>(CmdlineSpecialRemoveCommandName)
endif

cnoremap <Plug>(CmdlineSpecialRecallAnyRange) <C-\>e(CmdlineSpecialEdits#RecallAnyRange())<CR>
if ! hasmapto('<Plug>(CmdlineSpecialRecallAnyRange)', 'c')
    cmap <C-g><C-o> <Plug>(CmdlineSpecialRecallAnyRange)
endif

cnoremap <expr> <Plug>(CmdlineSpecialToggleSmartCase) (stridx('/?', getcmdtype()) == -1 ? (getcmdtype() ==# ':' ? '<C-\>e(CmdlineSpecialEdits#ToggleSmartCaseCommand())<CR>' : '<C-s>') : '<C-\>e(CmdlineSpecialEdits#ToggleSmartCasePattern())<CR>')
if ! hasmapto('<Plug>(CmdlineSpecialToggleSmartCase)', 'c')
    cmap <C-g><C-s> <Plug>(CmdlineSpecialToggleSmartCase)
endif

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :

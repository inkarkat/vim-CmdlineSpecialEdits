" after/plugin/CmdlineSpecialEdits.vim: Useful replacements of parts of the cmdline.
"
" DEPENDENCIES:
"
" Copyright: (C) 2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

if (v:version < 700) || ! g:loaded_CmdlineSpecialEdits
    finish
endif

if exists(':Argdo') == 2
    cnoremap <Plug>(CmdlineSpecialIterateArgdo) <C-\>e(CmdlineSpecialEdits#Iterate#Prepend('Argdo'))<CR>
    if ! hasmapto('<Plug>(CmdlineSpecialIterateArgdo)', 'c')
	cmap <C-g>ad <Plug>(CmdlineSpecialIterateArgdo)
    endif
    cnoremap <Plug>(CmdlineSpecialIterateArgdoWrite) <C-\>e(CmdlineSpecialEdits#Iterate#Prepend('ArgdoWrite'))<CR>
    if ! hasmapto('<Plug>(CmdlineSpecialIterateArgdoWrite)', 'c')
	cmap <C-g>aw <Plug>(CmdlineSpecialIterateArgdoWrite)
    endif
    cnoremap <Plug>(CmdlineSpecialIterateBufdo) <C-\>e(CmdlineSpecialEdits#Iterate#Prepend('Bufdo'))<CR>
    if ! hasmapto('<Plug>(CmdlineSpecialIterateBufdo)', 'c')
	cmap <C-g>bd <Plug>(CmdlineSpecialIterateBufdo)
    endif
    cnoremap <Plug>(CmdlineSpecialIterateBufdoWrite) <C-\>e(CmdlineSpecialEdits#Iterate#Prepend('BufdoWrite'))<CR>
    if ! hasmapto('<Plug>(CmdlineSpecialIterateBufdoWrite)', 'c')
	cmap <C-g>bw <Plug>(CmdlineSpecialIterateBufdoWrite)
    endif
    cnoremap <Plug>(CmdlineSpecialIterateWinbufdo) <C-\>e(CmdlineSpecialEdits#Iterate#Prepend('Winbufdo'))<CR>
    if ! hasmapto('<Plug>(CmdlineSpecialIterateWinbufdo)', 'c')
	cmap <C-g>wd <Plug>(CmdlineSpecialIterateWinbufdo)
    endif
    cnoremap <Plug>(CmdlineSpecialIterateWinbufdoWrite) <C-\>e(CmdlineSpecialEdits#Iterate#Prepend('WinbufdoWrite'))<CR>
    if ! hasmapto('<Plug>(CmdlineSpecialIterateWinbufdoWrite)', 'c')
	cmap <C-g>ww <Plug>(CmdlineSpecialIterateWinbufdoWrite)
    endif
    cnoremap <Plug>(CmdlineSpecialIterateTabwindo) <C-\>e(CmdlineSpecialEdits#Iterate#Prepend('Tabwindo'))<CR>
    if ! hasmapto('<Plug>(CmdlineSpecialIterateTabwindo)', 'c')
	cmap <C-g>td <Plug>(CmdlineSpecialIterateTabwindo)
    endif
    cnoremap <Plug>(CmdlineSpecialIterateTabwindoWrite) <C-\>e(CmdlineSpecialEdits#Iterate#Prepend('TabwindoWrite'))<CR>
    if ! hasmapto('<Plug>(CmdlineSpecialIterateTabwindoWrite)', 'c')
	cmap <C-g>tw <Plug>(CmdlineSpecialIterateTabwindoWrite)
    endif
else
    cnoremap <Plug>(CmdlineSpecialIterateArgdo) <C-\>e(CmdlineSpecialEdits#Iterate#Prepend('argdo'))<CR>
    if ! hasmapto('<Plug>(CmdlineSpecialIterateArgdo)', 'c')
	cmap <C-g>ad <Plug>(CmdlineSpecialIterateArgdo)
    endif
    cnoremap <Plug>(CmdlineSpecialIterateBufdo) <C-\>e(CmdlineSpecialEdits#Iterate#Prepend('bufdo'))<CR>
    if ! hasmapto('<Plug>(CmdlineSpecialIterateBufdo)', 'c')
	cmap <C-g>bd <Plug>(CmdlineSpecialIterateBufdo)
    endif
    cnoremap <Plug>(CmdlineSpecialIterateWinbufdo) <C-\>e(CmdlineSpecialEdits#Iterate#Prepend('windo'))<CR>
    if ! hasmapto('<Plug>(CmdlineSpecialIterateWinbufdo)', 'c')
	cmap <C-g>wd <Plug>(CmdlineSpecialIterateWinbufdo)
    endif
    cnoremap <Plug>(CmdlineSpecialIterateTabwindo) <C-\>e(CmdlineSpecialEdits#Iterate#Prepend('tabdo windo'))<CR>
    if ! hasmapto('<Plug>(CmdlineSpecialIterateTabwindo)', 'c')
	cmap <C-g>td <Plug>(CmdlineSpecialIterateTabwindo)
    endif
endif

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :

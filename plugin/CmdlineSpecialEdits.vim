" CmdlineSpecialEdits.vim: Useful replacements of parts of the cmdline.
"
" DEPENDENCIES:
"   - Requires Vim 7.0 or higher.
"
" Copyright: (C) 2012-2020 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	014	24-Sep-2019	Refactoring: Extract
"				CmdlineSpecialEdits#SpecialRange#LastChange().
"	013	08-Jul-2019	ENH: Add <C-g>/ mapping that converts
"                               :substitute (or similar) pattern separators.
"	012	05-Nov-2018	ENH: Add <C-g>+ mapping that converts between
"				relative and absolute range addresses.
"	011	03-Nov-2017	ENH: Add <A-(> mapping that (un-)wraps regexp in
"				grouping \(...\), similar to what <A-/> does
"				with whole word matching.
"	010	31-Oct-2017	Don't insert literal ^X in non-search
"				command-line on <A-/> / <A-?>.
"	009	12-Sep-2017	BUG: Missed replacing some left-hand side
"				original mapping with their new
"				<Plug>-equivalents.
"	008	09-Aug-2017	BUG: Missed function renaming in cmap <A-/>.
"	007	24-Jul-2017	Add many command-line related mappings from
"				ingomappings.vim.
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
if ! exists('g:CmdlineSpecialEdits_EnableSpecialSearchMode')
    let g:CmdlineSpecialEdits_EnableSpecialSearchMode = 1
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

cnoremap <silent> <Plug>(CmdlineSpecialChangeSubstitutionSep) <C-\>e(CmdlineSpecialEdits#Substitute#ChangeSeparator())<CR>
if ! hasmapto('<Plug>(CmdlineSpecialChangeSubstitutionSep)', 'c')
    cmap <C-g>/ <Plug>(CmdlineSpecialChangeSubstitutionSep)
endif

cnoremap <Plug>(CmdlineSpecialDeleteToEnd) <C-\>e(strpart(getcmdline(), 0, getcmdpos() - 1))<CR>
if ! hasmapto('<Plug>(CmdlineSpecialDeleteToEnd)', 'c')
    cmap <C-g>D <Plug>(CmdlineSpecialDeleteToEnd)
endif

cnoremap <Plug>(CmdlineSpecialToggleSymbolicRange) <C-\>e(CmdlineSpecialEdits#Range#ToggleSymbolic())<CR>
if ! hasmapto('<Plug>(CmdlineSpecialToggleSymbolicRange)', 'c')
    cmap <C-g>' <Plug>(CmdlineSpecialToggleSymbolicRange)
endif

cnoremap <Plug>(CmdlineSpecialToggleRelativeRange) <C-\>e(CmdlineSpecialEdits#Range#ToggleRelative())<CR>
if ! hasmapto('<Plug>(CmdlineSpecialToggleRelativeRange)', 'c')
    cmap <C-g>+ <Plug>(CmdlineSpecialToggleRelativeRange)
endif

cnoremap <Plug>(CmdlineSpecialRemoveBackspacing) <C-\>e(CmdlineSpecialEdits#Remove#Backspacing(getcmdline()))<CR>
if ! hasmapto('<Plug>(CmdlineSpecialRemoveBackspacing)', 'c')
    cmap <C-g><C-h> <Plug>(CmdlineSpecialRemoveBackspacing)
endif

cnoremap <Plug>(CmdlineSpecialRemoveLastPathComponent) <C-\>e(CmdlineSpecialEdits#Remove#LastPathComponent())<CR>
if ! hasmapto('<Plug>(CmdlineSpecialRemoveLastPathComponent)', 'c')
    cmap <C-BS> <Plug>(CmdlineSpecialRemoveLastPathComponent)
endif

cnoremap <Plug>(CmdlineSpecialAddPrefix) <C-\>e(CmdlineSpecialEdits#Edit#AddPrefix())<CR>
if ! hasmapto('<Plug>(CmdlineSpecialAddPrefix)', 'c')
    cmap <C-g>I <Plug>(CmdlineSpecialAddPrefix)
endif
cnoremap <Plug>(CmdlineSpecialAddSuffix) <C-\>e(CmdlineSpecialEdits#Edit#AddSuffix())<CR>
if ! hasmapto('<Plug>(CmdlineSpecialAddSuffix)', 'c')
    cmap <C-g>A <Plug>(CmdlineSpecialAddSuffix)
endif

cnoremap <Plug>(CmdlineSpecialSimplifyBranches) <C-\>e(CmdlineSpecialEdits#Simplify#Branches())<CR>
if ! hasmapto('<Plug>(CmdlineSpecialSimplifyBranches)', 'c')
    cmap <C-g>s <Plug>(CmdlineSpecialSimplifyBranches)
endif

cnoremap <Plug>(CmdlineSpecialIgnoreCaseMixed) <C-\>e(CmdlineSpecialEdits#IgnoreCase#Mixed())<CR>
if ! hasmapto('<Plug>(CmdlineSpecialIgnoreCaseMixed)', 'c')
    cmap <C-g>c <Plug>(CmdlineSpecialIgnoreCaseMixed)
endif

cnoremap <Plug>(CmdlineSpecialYankCommandLine) <C-\>e(CmdlineSpecialEdits#Edit#YankCommandLine(getcmdline()))<CR>
if ! hasmapto('<Plug>(CmdlineSpecialYankCommandLine)', 'c')
    cmap <C-g>y <Plug>(CmdlineSpecialYankCommandLine)
endif

cnoremap <Plug>(CmdlineSpecialInsertSelection) <C-r><C-r>=tr(ingo#selection#Get(), "\n", "\r")<CR>
if ! hasmapto('<Plug>(CmdlineSpecialInsertSelection)', 'c')
    cmap <C-r><C-y> <Plug>(CmdlineSpecialInsertSelection)
endif

cnoremap <expr> <Plug>(CmdlineSpecialInsertLine) ingo#str#Trim(getline('.'))
if ! hasmapto('<Plug>(CmdlineSpecialInsertLine)', 'c')
    cmap <C-r><C-l> <Plug>(CmdlineSpecialInsertLine)
endif

cnoremap <expr> <Plug>(CmdlineSpecialInsertChar) ingo#text#GetChar(getpos('.')[1:2])
if ! hasmapto('<Plug>(CmdlineSpecialInsertChar)', 'c')
    cmap <C-r><C-s> <Plug>(CmdlineSpecialInsertChar)
endif

cnoremap <silent> <Plug>(CmdlineSpecialInsertRegisterForLiteralSearch) <C-\>e(CmdlineSpecialEdits#Literal#Register())<CR>
if ! hasmapto('<Plug>(CmdlineSpecialInsertRegisterForLiteralSearch)', 'c')
    cmap <C-r><C-v> <Plug>(CmdlineSpecialInsertRegisterForLiteralSearch)
endif

cnoremap <expr> <Plug>(CmdlineSpecialLastChangeRange) CmdlineSpecialEdits#SpecialRange#LastChange()
if ! hasmapto('<Plug>(CmdlineSpecialLastChangeRange)', 'c')
    cmap # <Plug>(CmdlineSpecialLastChangeRange)
endif


if g:CmdlineSpecialEdits_EnableSpecialSearchMode
    cnoremap <expr> / CmdlineSpecialEdits#Search#SpecialSearchMode('/')
    cnoremap <expr> ? CmdlineSpecialEdits#Search#SpecialSearchMode('?')
    cnoremap <expr> _ CmdlineSpecialEdits#Search#SpecialSearchMode('_')
    cnoremap <expr> * CmdlineSpecialEdits#Search#SpecialSearchMode('*')
endif

nnoremap <silent> <Plug>(CmdlineSpecialToggleSearchMode) :<C-u>let @/=CmdlineSpecialEdits#Search#ToggleMode(@/)<Bar>echo ingo#avoidprompt#TranslateLineBreaks('/' . @/)<CR>
cnoremap <expr>   <Plug>(CmdlineSpecialToggleSearchMode) (stridx('/?', getcmdtype()) == -1 ? '' : '<C-\>e(CmdlineSpecialEdits#Search#ToggleMode(getcmdline()))<CR>')
if ! hasmapto('<Plug>(CmdlineSpecialToggleSearchMode)', 'n')
    nmap <A-/> <Plug>(CmdlineSpecialToggleSearchMode)
endif
if ! hasmapto('<Plug>(CmdlineSpecialToggleSearchMode)', 'c')
    cmap <A-/> <Plug>(CmdlineSpecialToggleSearchMode)
endif

nnoremap <silent> <Plug>(CmdlineSpecialToggleWholeWord) :<C-u>let @/=CmdlineSpecialEdits#Search#ToggleWholeWord('n', @/)<Bar>echo ingo#avoidprompt#TranslateLineBreaks('/' . @/)<CR>
cnoremap <expr> <Plug>(CmdlineSpecialToggleWholeWord) (stridx('/?', getcmdtype()) == -1 ? '' : '<C-\>e(CmdlineSpecialEdits#Search#ToggleWholeWord("c", getcmdline()))<CR>')
if ! hasmapto('<Plug>(CmdlineSpecialToggleWholeWord)', 'n')
    nmap <A-?> <Plug>(CmdlineSpecialToggleWholeWord)
endif
if ! hasmapto('<Plug>(CmdlineSpecialToggleWholeWord)', 'c')
    cmap <A-?> <Plug>(CmdlineSpecialToggleWholeWord)
endif

nnoremap <silent> <Plug>(CmdlineSpecialToggleGrouping) :<C-u>let @/=CmdlineSpecialEdits#Search#ToggleGrouping('n', @/)<Bar>echo ingo#avoidprompt#TranslateLineBreaks('/' . @/)<CR>
cnoremap <expr> <Plug>(CmdlineSpecialToggleGrouping) (stridx('/?', getcmdtype()) == -1 ? '' : '<C-\>e(CmdlineSpecialEdits#Search#ToggleGrouping("c", getcmdline()))<CR>')
if ! hasmapto('<Plug>(CmdlineSpecialToggleGrouping)', 'n')
    nmap <A-(> <Plug>(CmdlineSpecialToggleGrouping)
endif
if ! hasmapto('<Plug>(CmdlineSpecialToggleGrouping)', 'c')
    cmap <A-(> <Plug>(CmdlineSpecialToggleGrouping)
endif

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :

CMDLINE SPECIAL EDITS
===============================================================================
_by Ingo Karkat_

DESCRIPTION
------------------------------------------------------------------------------

You frequently go to Vim's Command-line-mode - especially for searches and
Ex commands. Within that single line, editing is limited; you're supposed to
use (or switch to) the command-line-window, which offers the full editing
power. However, many people mostly stick to the simple command-line, making
edits slower than necessary.

This plugin tries to bridge the gap between the simple command-line and the
command-line window by offering a large set of mappings for the command-line
that are tailored to custom editing tasks, and therefore may be even more
powerful than the full generic set of Vim commands in the command-line window.

Invocation and recall of Ex commands is aided by mappings that keep a previous
range, command, or arguments, adapting ranges to line numbers or relative
addressing, changing separators for :substitute et al, and many more.
The ubiquitous searches and substitutions are supercharged by mappings that
group and simplify regexp branches, insert register contents as literal
searches or replacements, and more.

Normal mode mappings allow to quickly start common searches like literal,
case-insensitive, or whitespace-ignoring, and can also toggle the mode when
inside the search command-line.

Finally, built-in CTRL-R insertions (like c\_CTRL-R\_CTRL-F) are extended with
additional targets for the current character, line, or selected text.

### SOURCE

- [CTRL-G ' inspiration](http://superuser.com/questions/856533/vim-visual-mode-search-and-replace)
- [CTRL-BS based on](http://vim.wikia.com/wiki/Command_line_file_name_completion)
- [CTRL-G D inspiration](https://unix.stackexchange.com/questions/408980/delete-to-end-of-command-line-in-vim)
- [CTRL-G CTRL-U inspiration](http://stackoverflow.com/questions/11011304/reusing-the-previous-range-in-ex-commands-in-vim/11013406)
- [CTRL-G + inspiration](https://stackoverflow.com/questions/53124198/select-relative-range-ignoring-invalid-line-numbers/53154241)
- [CTRL-G c inspiration](https://stackoverflow.com/questions/60194038/ignore-the-case-in-part-of-the-search-pattern-in-vim)

USAGE
------------------------------------------------------------------------------

    CTRL-G CTRL-U           Remove all characters between the cursor position and
                            the closest previous :range given to a command.
                            Useful to repeat a recalled command line with the same
                            range, but a different command.
                            When used on an empty command line, recalls the
                            previous command-line from history first.

    CTRL-G CTRL-A           Remove all command arguments between the cursor
                            position and the closest previous command.
                            Useful to repeat a command with different arguments.
                            When used on an empty command line, recalls the
                            previous command-line from history first.

    CTRL-G CTRL-C           Remove the closest previous command from the command
                            line, but keep its arguments.
                            Useful to re-use the same arguments with a different
                            command.
                            When used on an empty command line, recalls the
                            previous command-line from history first.

    CTRL-G D                Remove all characters between the cursor position and
                            the end of the line. Like c_CTRL-U, but in the other
                            direction. Like D, but in command-line mode.

    CTRL-G '                Change symbolic ranges like '<,'> to the actual line
                            numbers, and vice versa. Also corrects addressing out
                            of bounds (<= 0 and larger than the last line number)
                            and backwards ranges.
                            Useful to be able to repeat a command on the same
                            range, even when the selection changes.
                            When used on an empty command line, recalls the
                            previous command-line from history first.

    CTRL-G +                Change relative ranges like .-5,.+5 to absolute line
                            numbers and vice versa. Also corrects addressing out
                            of bounds (<= 0 and larger than the last line number)
                            and backwards ranges.
                            When used on an empty command line, recalls the
                            previous command-line from history first.

    CTRL-G CTRL-O           Recall older command-line from history, whose
                            beginning matches the current command-line, regardless
                            of the current :range and the one in the history.
                            Subsequent invocations step backwards through the
                            history, like c_<Up>. This allows you to re-apply
                            previous visual mode commands (e.g. :'<,'>s/foo/bar)
                            to a different range, or vice versa.

    CTRL-G CTRL-S           Toggle between :substitute and :SmartCase variants.
                            When entering a search pattern: Toggle pattern between
                            normal and SmartCase matching.
                            When used on an empty command line, recalls the
                            previous command-line / search pattern from history
                            first.

    CTRL-G / {sep}          Change the separator of the current :substitute (or
                            similar command taking a /{pattern}[/{string}/]
                            argument) command to {sep}.
                            For example, when you've started a substitution with
                            the default "/" separators but now want to insert a
                            longer filespec (with Unix-style forward path
                            separators), so tedious escaping would be necessary.

    CTRL-G ad               Prepend :argdo / :Argdo to the entire
                            command-line.
    CTRL-G aw               Prepend :ArgdoWrite to the entire command-line.
    CTRL-G bd               Prepend :bufdo / :Bufdo to the entire
                            command-line.
    CTRL-G bw               Prepend :BufdoWrite to the entire command-line.
    CTRL-G wd               Prepend :windo / :Winbufdo to the entire
                            command-line.
    CTRL-G ww               Prepend :WinbufdoWrite to the entire command-line.
    CTRL-G td               Prepend :tabdo||windo / :Tabwindo to the entire
                            command-line.
    CTRL-G tw               Prepend :TabwindoWrite to the entire command-line.
                            If the (last) command is a :substitute (or similar),
                            also append the :s_e flag so that buffers that don't
                            match the pattern don't cause an error.

    CTRL-G CTRL-H           Apply literal <BS> and <C-h> keys (e.g. when editing a
                            macro inline via q"{reg}) by removing them and the
                            previously pressed key.

    CTRL-<BS>               Remove last path component / file extension.

    CTRL-G I                Group any existing regexp branches and position the
                            cursor at the beginning (but behind a /^ anchor).
    CTRL-G A                Group any existing regexp branches and position the
                            cursor at the end (but before a /$ anchor).
                            These are useful to prepend / append a common prefix /
                            suffix to different pattern branches, e.g.:
                                bar\|baz -> \%(bar\|baz\)

    CTRL-G s                Simplify regexp branches of the search pattern by
                            extracting common substrings. For example:
                            /myFoobar\|theFoony -> /\%(my\|the\)Foo\%(bar\|ny\)

    CTRL-G c                Convert alphabetic characters following \c (up to the
                            end or the next \C) into case-insensitive [xX]
                            collections, or the opposite characters into
                            \%(\l\&x\) / \%(\u\&X\) (whichever resulting pattern
                            is shorter), and drop the \c\C atoms, so that the
                            entire regular expression becomes a partially case-
                            sensitive / partially case-insensitive pattern. (This
                            cannot be achieved by the built-in /\c / /\C, as
                            they apply to the whole pattern.)
                            When executed again on the result: Replace with the
                            alternative approach.

    CTRL-G Y                Yank the current command-line to the default register.
    CTRL-G y{x}             Yank the current command-line into register x.

    CTRL-R CTRL-S           Insert the (single) character under the cursor.
    CTRL-R CTRL-L           Insert the current line (without leading indent and
                            trailing spaces).
    CTRL-R CTRL-Y           Insert the current selected text. Unlike the above
                            mappings, this inserts literally, not as if typed.

    CTRL-R CTRL-V{0-9a-z"%#*+:.-=}
                            Insert the contents of a register literally:
                            - as literal regular expression (either via \V or
                              individually escaped characters, whatever is
                              shorter) for searches
                            - as literal pattern / replacement in a :substitute
                              command (depending on the position, also for custom
                              ones if inside a /.../ argument)
                            - as literal expression for a :put command
                            - else as literal Vimscript String

    :#                      Alias for :'[,'] (like :* is a synonym for :'<,'>)
    :##                     Replace with a range the same size as the last changed
                            area. This makes it easy to reapply an Ex command to a
                            same-sized range elsewhere. The created range is
                            relative to the current line, so it can be quickly
                            reapplied at further locations via @:.

    :**                     Replace with a range the same size as the last
                            selected area. This makes it easy to reapply a
                            selection to an Ex command, like 1v does in normal
                            mode. The created range is relative to the current
                            line, so it can be quickly reapplied at further
                            locations via @:.

    //, ??                  Perform a literal search. (Only after a search
                            pattern, to keep the idiom of //e to repeat the search
                            but jump to the end.)
    /?, ?/                  Perform a case-insensitive search. Both when
                            initiating a search as well as inside a search
                            command-line (where repeated use will toggle the
                            special search mode).
    /_, ?_                  Perform a search that ignores whitespace differences
                            and comment prefixes.
    /*, ?*                  Perform a search that ignores whitespace differences
                            and comment prefixes, and also allowing direct
                            concatenation of lines (i.e. without any whitespace in
                            between).

    ///, ???                Use the last search pattern and toggle from literal to
                            normal search and vice versa.
    //?, ??/                Use the last search pattern and toggle from
                            case-insensitive to normal search and vice versa.
    //_, ??_                Use the last search pattern and toggle from
                            whitespace-flexible to normal search and vice versa.

    ALT-/                   Toggle search mode between normal, case-insensitive,
                            and literal.

    ALT-SHIFT-/             Toggle search mode between whole word (\<...\>) and
                            normal matching.

    ALT-(                   (Un-)wrap search pattern in capturing group \(...\).

INSTALLATION
------------------------------------------------------------------------------

The code is hosted in a Git repo at
    https://github.com/inkarkat/vim-CmdlineSpecialEdits
You can use your favorite plugin manager, or "git clone" into a directory used
for Vim packages. Releases are on the "stable" branch, the latest unstable
development snapshot on "master".

This script is also packaged as a vimball. If you have the "gunzip"
decompressor in your PATH, simply edit the \*.vmb.gz package in Vim; otherwise,
decompress the archive first, e.g. using WinZip. Inside Vim, install by
sourcing the vimball or via the :UseVimball command.

    vim CmdlineSpecialEdits*.vmb.gz
    :so %

To uninstall, use the :RmVimball command.

### DEPENDENCIES

- Requires Vim 7.0 or higher.
- Requires the ingo-library.vim plugin ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)), version 1.043 or
  higher.
- ArgsAndMore.vim plugin ([vimscript #4152](http://www.vim.org/scripts/script.php?script_id=4152)) (optional; providing :Argdo et
  al. for the c\_CTRL-G\_ad etc. mappings).
- SmartCase.vim plugin ([vimscript #1359](http://www.vim.org/scripts/script.php?script_id=1359), or my fork at
  https://github.com/inkarkat/vim-SmartCase) (optional, only for
  c\_CTRL-G\_CTRL-S).

CONFIGURATION
------------------------------------------------------------------------------

For a permanent configuration, put the following commands into your vimrc:

The marks to be considered by the c\_CTRL-G\_' command are specified as a
String of mark names, with "#" representing the current line range :.; they
are checked from left to right. The default considers all marks except for
(){} (because those are very dependent on the current position).

    let g:CmdlineSpecialEdits_SymbolicRangeConsideredMarks = 'abcde...'

The c\_CTRL-G\_' command also uses small offsets for nearby marks. The default
is +/-3 lines; change it via:

    let g:CmdlineSpecialEdits_SymbolicRangeMaximumOffset = 0

If you don't want the CmdlineSpecialEdits-SpecialSearchModes (e.g. //, /?,
/\_), you can turn them off via

    let g:CmdlineSpecialEdits_EnableSpecialSearchMode = 0

Remapping to other keys isn't possible here.

The c\_CTRL-R\_CTRL\_V mapping does literal pattern / replacement in the
built-in :substitute command as well as any custom command starting with
:Substitute or :SmartCase. The c\_CTRL-G\_ad etc. mappings add the :s\_e flag
to substitutions. You can extend or change the list of custom commands that
are considered via a regular expression in:

    let g:CmdlineSpecialEdits_SubstitutionCommandsExpr = '^cmd1$\|^prefix'

If you want to use different mappings, map your keys to the
&lt;Plug&gt;(CmdlineSpecialEdits...) mapping targets _before_ sourcing the script
(e.g. in your vimrc):

    cmap <C-g><C-u> <Plug>(CmdlineSpecialRemoveAllButRange)
    cmap <C-g><C-a> <Plug>(CmdlineSpecialRemoveCommandArguments)
    cmap <C-g><C-c> <Plug>(CmdlineSpecialRemoveCommandName)
    cmap <C-g><C-o> <Plug>(CmdlineSpecialRecallAnyRange)
    cmap <C-g><C-s> <Plug>(CmdlineSpecialToggleSmartCase)
    cmap <C-g>/ <Plug>(CmdlineSpecialChangeSubstitutionSep)
    cmap <C-g>ad <Plug>(CmdlineSpecialIterateArgdo)
    cmap <C-g>aw <Plug>(CmdlineSpecialIterateArgdoWrite)
    cmap <C-g>bd <Plug>(CmdlineSpecialIterateBufdo)
    cmap <C-g>bw <Plug>(CmdlineSpecialIterateBufdoWrite)
    cmap <C-g>wd <Plug>(CmdlineSpecialIterateWinbufdo)
    cmap <C-g>ww <Plug>(CmdlineSpecialIterateWinbufdoWrite)
    cmap <C-g>td <Plug>(CmdlineSpecialIterateTabwindo)
    cmap <C-g>tw <Plug>(CmdlineSpecialIterateTabwindoWrite)
    cmap <C-g>D <Plug>(CmdlineSpecialDeleteToEnd)
    cmap <C-g>' <Plug>(CmdlineSpecialToggleSymbolicRange)
    cmap <C-g>+ <Plug>(CmdlineSpecialToggleRelativeRange)
    cmap <C-g><C-h> <Plug>(CmdlineSpecialRemoveBackspacing)
    cmap <C-BS> <Plug>(CmdlineSpecialRemoveLastPathComponent)
    cmap <C-g>I <Plug>(CmdlineSpecialAddPrefix)
    cmap <C-g>A <Plug>(CmdlineSpecialAddSuffix)
    cmap <C-g>s <Plug>(CmdlineSpecialSimplifyBranches)
    cmap <C-g>c <Plug>(CmdlineSpecialIgnoreCaseMixed)
    cmap <C-g>y <Plug>(CmdlineSpecialRegisterYankCommandLine)
    cmap <C-g>Y <Plug>(CmdlineSpecialYankCommandLine)
    cmap <C-r><C-l> <Plug>(CmdlineSpecialInsertLine)
    cmap <C-r><C-s> <Plug>(CmdlineSpecialInsertChar)
    cmap <C-r><C-y> <Plug>(CmdlineSpecialInsertSelection)
    cmap <C-r><C-v> <Plug>(CmdlineSpecialInsertRegisterForLiteralSearch)
    cmap # <Plug>(CmdlineSpecialLastChangeRange)
    nmap <A-/> <Plug>(CmdlineSpecialToggleSearchMode)
    cmap <A-/> <Plug>(CmdlineSpecialToggleSearchMode)
    nmap <A-?> <Plug>(CmdlineSpecialToggleWholeWord)
    cmap <A-?> <Plug>(CmdlineSpecialToggleWholeWord)

CONTRIBUTING
------------------------------------------------------------------------------

Report any bugs, send patches, or suggest features via the issue tracker at
https://github.com/inkarkat/vim-CmdlineSpecialEdits/issues or email (address
below).

HISTORY
------------------------------------------------------------------------------

##### 1.10    RELEASEME
- CHG: Switch &lt;C-G&gt;y to &lt;C-G&gt;Y and add &lt;C-G&gt;y{x} variant that allows to pass
  the register to yank the command-line to.
- BUG: &lt;C-G&gt;&lt;C-S&gt; introduces an additional separator if the cursor is before
  the final substitution separator (i.e. in the replacement part).
- ENH: Allow customization of the &lt;C-R&gt;&lt;C-V&gt; literal pattern / replacement for
  custom :Substitute commands and add :SmartCase by default.
- ENH: Add &lt;C-G&gt;ad, &lt;C-G&gt;aw, ... mappings that prepend the :Argdo,
  :ArgdoWrite, etc. commands provided by ArgsAndMore.vim to the command-line
  (and append the :s\_e flag to a :substitute command).

__You need to update to ingo-library ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)) version 1.043!__

##### 1.00    10-Mar-2020
- First published version.

##### 0.01    13-Jun-2012
- Started development.

------------------------------------------------------------------------------
Copyright: (C) 2012-2022 Ingo Karkat -
The [VIM LICENSE](http://vimdoc.sourceforge.net/htmldoc/uganda.html#license) applies to this plugin.

Maintainer:     Ingo Karkat &lt;ingo@karkat.de&gt;

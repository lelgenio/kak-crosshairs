set-face global crosshairs_line default,rgb:383838+bd
set-face global crosshairs_column default,rgb:383838+bd

# Whether to print debug information during runtime
declare-option -hidden bool highlight_debug

declare-option -hidden bool highlight_current_line
declare-option -hidden bool highlight_current_column

#------------------------------------#
#            User commands           #
#------------------------------------#

define-command -override crosshairs-toggle -docstring "Toggle Crosshairs or line/col highlighting" %{
    evaluate-commands %sh{
        printf "
            set-option global highlight_current_line %s\n
            set-option global highlight_current_column %s
        " $( [ "$kak_opt_highlight_current_column" = true ] \
                && printf "%s\n%s\n" "false" "false" \
                || printf "%s\n%s\n" "true" "true" )
    }
    crosshairs-change-hooks
}

define-command -override crosshairs-enable -docstring "Enable Crosshairs or line/col highlighting" %{
    set-option global highlight_current_line true
    set-option global highlight_current_column true
    crosshairs-change-hooks
}

define-command -override crosshairs-disable -docstring "disable Crosshairs or line/col highlighting" %{
    set-option global highlight_current_line false
    set-option global highlight_current_column false
    crosshairs-change-hooks
}



define-command -override cursorline -docstring "Toggle Highlighting for current line" %{
    evaluate-commands %sh{
        [ "$kak_opt_highlight_current_line" = true ] \
            && printf "%s\n" "set-option global highlight_current_line false" \
            || printf "%s\n" "set-option global highlight_current_line true"
    }
    crosshairs-change-hooks
}

define-command -override cursorline-enable -docstring "Enable Highlighting for current line" %{
    set-option global highlight_current_line true
    crosshairs-change-hooks
}

define-command -override cursorline-disable -docstring "Disable Highlighting for current line" %{
    set-option global highlight_current_line false
    crosshairs-change-hooks
}



define-command -override cursorcolumn -docstring "Toggle highlighting for current column" %{
    evaluate-commands %sh{
        [ "$kak_opt_highlight_current_column" = true ] \
            && printf "%s\n" "set-option global highlight_current_column false" \
            || printf "%s\n" "set-option global highlight_current_column true"
    }
    crosshairs-change-hooks
}
define-command -override cursorcolumn-enable -docstring "Enable highlighting for current column" %{
    set-option global highlight_current_column true
    crosshairs-change-hooks
}
define-command -override cursorcolumn-disable -docstring "Disable highlighting for current column" %{
    set-option global highlight_current_column false
    crosshairs-change-hooks
}

#------------------------------------#
#       Implementation commands      #
#------------------------------------#

define-command -override -hidden -docstring "Move/remove the line/column highlithers to match settings and cursor position" \
crosshairs-update-drawing %{
    try %{ remove-highlighter window/crosshairs-column }
    try %{ remove-highlighter window/crosshairs-line }

    try %{ evaluate-commands %sh{
        [ "$kak_opt_highlight_debug" = true ] && echo "runnig crosshairs-update-drawing" >&2

        if [ "$kak_opt_highlight_current_line" = true ]; then
            [ "$kak_opt_highlight_debug" = true ] && echo "drawing line" >&2
            printf "%s\n" "add-highlighter window/crosshairs-line line %val{cursor_line} crosshairs_line"
        fi
        if [ "$kak_opt_highlight_current_column" = true ]; then
            [ "$kak_opt_highlight_debug" = true ] && echo "drawing column" >&2
            printf "%s\n" "add-highlighter window/crosshairs-column column %val{cursor_display_column} crosshairs_column"
        fi
    } }
}

define-command -override -hidden -docstring "Add/remove crosshairs drawing hook" \
crosshairs-change-hooks %{
    evaluate-commands %sh{
        [ "$kak_opt_highlight_debug" = true ] && echo "runnig crosshairs-change-hooks" >&2
        if [ "$kak_opt_highlight_current_column" = true ] || [ "$kak_opt_highlight_current_line" = true ]; then
            [ "$kak_opt_highlight_debug" = true ] && echo "enabling draw hook" >&2
            printf "%s\n" "hook global -group crosshairs RawKey .+ crosshairs-update-drawing"
        else
            [ "$kak_opt_highlight_debug" = true ] && echo "disabling draw hook" >&2
            printf "%s\n" "remove-hooks global crosshairs"
        fi
    }
    crosshairs-update-drawing
}


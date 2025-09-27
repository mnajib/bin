#!/usr/bin/env bash
# cleanup-file.sh - Remove comment-only lines and optionally blank lines.
#
# Usage:
#   cleanup-file.sh [options] <file>
#
# Description:
#   - Removes lines that contain only comments (starting with '#').
#   - By default, reduces sequences of more than one blank line into a single blank line.
#   - With --no-blank, removes all blank lines entirely.
#
# Options:
#   -n, --no-blank   Remove all blank lines (instead of collapsing).
#   -h, --help       Show this help message and exit.

set -euo pipefail

# ---------- Pure Functions ----------

# Predicate: check if a line is comment-only
is_comment_line() {
    local line="$1"
    [[ "$line" =~ ^[[:space:]]*# ]] && return 0 || return 1
}

# Filter: remove comment-only lines
filter_comments() {
    while IFS= read -r line; do
        if ! is_comment_line "$line"; then
            printf '%s\n' "$line"
        fi
    done
}

# Filter: collapse multiple blank lines into a single one
normalize_blank_lines() {
    local blank_seen=0
    while IFS= read -r line; do
        if [[ -z "$line" ]]; then
            if [[ $blank_seen -eq 0 ]]; then
                printf '\n'
            fi
            blank_seen=1
        else
            printf '%s\n' "$line"
            blank_seen=0
        fi
    done
}

# Filter: remove all blank lines
remove_all_blank_lines() {
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            printf '%s\n' "$line"
        fi
    done
}

# ---------- Impure Functions ----------

show_help() {
    cat <<EOF
Usage: $(basename "$0") [options] <file>

Description:
  - Removes lines that contain only comments (starting with '#').
  - By default, reduces sequences of more than one blank line into a single blank line.
  - With --no-blank, removes all blank lines entirely.

Options:
  -n, --no-blank   Remove all blank lines (instead of collapsing).
  -h, --help       Show this help message and exit.

Examples:
  $(basename "$0") source.txt
  $(basename "$0") --no-blank source.txt
  $(basename "$0") --help
EOF
}

main() {
    local infile=""
    local mode="normalize"  # default

    # Parse options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -n|--no-blank)
                mode="remove"
                shift
                ;;
            -*)
                echo "Error: Unknown option '$1'" >&2
                show_help
                exit 1
                ;;
            *)
                infile="$1"
                shift
                ;;
        esac
    done

    if [[ -z "$infile" ]]; then
        echo "Error: Missing input file." >&2
        show_help
        exit 1
    fi

    if [[ ! -f "$infile" ]]; then
        echo "Error: File '$infile' not found." >&2
        exit 1
    fi

    case "$mode" in
        normalize) <"$infile" filter_comments | normalize_blank_lines ;;
        remove)    <"$infile" filter_comments | remove_all_blank_lines ;;
    esac
}

main "$@"


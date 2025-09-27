#!/usr/bin/env bash
# cleanup-file.sh - Remove comment-only lines and collapse multiple blank lines.
#
# Usage:
#   cleanup-file.sh <file>
#   cleanup-file.sh -h | --help
#
# Description:
#   - Removes lines that contain only comments (starting with '#').
#   - Reduces sequences of more than one blank line into a single blank line.

set -euo pipefail

# ---------- Pure Functions ----------

# Predicate: check if a line is comment-only
is_comment_line() {
    local line="$1"
    [[ "$line" =~ ^[[:space:]]*# ]] && return 0 || return 1
}

# Pure filter: remove comment-only lines
filter_comments() {
    while IFS= read -r line; do
        if ! is_comment_line "$line"; then
            printf '%s\n' "$line"
        fi
    done
}

# Pure filter: collapse multiple blank lines into a single one
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

# ---------- Impure Functions ----------

show_help() {
    cat <<EOF
Usage: $(basename "$0") <file>

Description:
  - Removes lines that contain only comments (starting with '#').
  - Reduces sequences of more than one blank line into a single blank line.

Options:
  -h, --help    Show this help message and exit.

Examples:
  $(basename "$0") source.txt
  $(basename "$0") --help
EOF
}

main() {
    local infile="${1:-}"

    case "$infile" in
        -h|--help|"")
            show_help
            exit 0
            ;;
    esac

    if [[ ! -f "$infile" ]]; then
        echo "Error: File '$infile' not found." >&2
        exit 1
    fi

    <"$infile" filter_comments | normalize_blank_lines
}

main "$@"


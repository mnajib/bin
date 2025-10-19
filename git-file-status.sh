#!/usr/bin/env bash
#
# git-file-status.sh — list tracked, untracked, and ignored files as simple list
#
# Author: Najib & GPT-5
# Version: 1.2 — Added command-line argument support

# --- Configuration ----------------------------------------------------------
VERSION="1.2"
SCRIPT_NAME=$(basename "$0")

# Default display settings
SHOW_TRACKED=true
SHOW_UNTRACKED=true
SHOW_IGNORED=true
SHOW_SUMMARY=true

# --- Helper Functions -------------------------------------------------------

# Display help information
show_help() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

List tracked, untracked, and ignored files in a Git repository as a simple list.

OPTIONS:
    --tracked        Show only tracked files
    --untracked      Show only untracked files
    --ignored        Show only ignored files
    --summary        Show only summary counts
    --all            Show all sections (default)
    --version        Display version information
    --help           Display this help message
EOF
}
#EXAMPLES:
#    $SCRIPT_NAME                    # Show all sections
#    $SCRIPT_NAME --tracked          # Show only tracked files
#    $SCRIPT_NAME --untracked        # Show only untracked files
#    $SCRIPT_NAME --summary          # Show only summary
#    $SCRIPT_NAME --tracked --summary # Show tracked files and summary
#
#COLORS:
#    ✅ Tracked files:   Green
#    ⚠️  Untracked files: Yellow
#    🚫 Ignored files:   Red

# Display version information
show_version() {
    echo "$SCRIPT_NAME version $VERSION"
}

# Pretty title section
print_section() {
    local title="$1"
    echo
    echo "============================================================"
    echo " $title"
    echo "============================================================"
}

# Render files as simple list with color
# Accepts: color code as $1, file paths from stdin
print_list() {
    local color="$1"

    while IFS= read -r file; do
        if [[ -n "$file" ]]; then
            echo -e "${color}${file}\033[0m"
        fi
    done
}

# Parse command line arguments
parse_arguments() {
    # If no arguments, use default behavior
    if [[ $# -eq 0 ]]; then
        return 0
    fi

    # Reset all display flags when specific sections are requested
    local has_specific_sections=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --help)
                show_help
                exit 0
                ;;
            --version)
                show_version
                exit 0
                ;;
            --tracked)
                SHOW_TRACKED=true
                SHOW_UNTRACKED=false
                SHOW_IGNORED=false
                has_specific_sections=true
                shift
                ;;
            --untracked)
                SHOW_TRACKED=false
                SHOW_UNTRACKED=true
                SHOW_IGNORED=false
                has_specific_sections=true
                shift
                ;;
            --ignored)
                SHOW_TRACKED=false
                SHOW_UNTRACKED=false
                SHOW_IGNORED=true
                has_specific_sections=true
                shift
                ;;
            --summary)
                SHOW_SUMMARY=true
                # Don't change other flags for summary-only mode
                shift
                ;;
            --all)
                # Reset to defaults
                SHOW_TRACKED=true
                SHOW_UNTRACKED=true
                SHOW_IGNORED=true
                SHOW_SUMMARY=true
                shift
                ;;
            *)
                echo "Error: Unknown option '$1'" >&2
                echo "Try '$SCRIPT_NAME --help' for more information." >&2
                exit 1
                ;;
        esac
    done

    # If specific file sections were requested but summary wasn't explicitly set,
    # don't show summary by default in single-section mode
    if [[ "$has_specific_sections" == true ]] && [[ "$SHOW_SUMMARY" == true ]]; then
        # Keep summary enabled as it might be useful even in single-section mode
        : # Do nothing, keep summary enabled
    fi
}

# --- Main -------------------------------------------------------------------

# Parse command line arguments
parse_arguments "$@"

if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "❌ Not a Git repository."
    exit 1
fi

# Change directory to repo root for consistent paths
cd "$(git rev-parse --show-toplevel)" || exit 1

# Collect file lists (we collect all data upfront for efficiency)
tracked_files=$(git ls-files)
untracked_files=$(git ls-files --others --exclude-standard)
ignored_files=$(git ls-files --others --ignored --exclude-standard)

# Calculate counts
tracked_count=$(echo "$tracked_files" | grep -c . || true)
untracked_count=$(echo "$untracked_files" | grep -c . || true)
ignored_count=$(echo "$ignored_files" | grep -c . || true)

# --- Show tracked -----------------------------------------------------------
if [[ "$SHOW_TRACKED" == true ]]; then
    print_section "✅ TRACKED FILES"
    if [[ -n "$tracked_files" ]]; then
        echo "$tracked_files" | sort | print_list "\033[1;32m"   # green
    else
        echo "  (none)"
    fi
fi

# --- Show untracked ---------------------------------------------------------
if [[ "$SHOW_UNTRACKED" == true ]]; then
    print_section "⚠️  UNTRACKED FILES"
    if [[ -n "$untracked_files" ]]; then
        echo "$untracked_files" | sort | print_list "\033[1;33m"  # yellow
    else
        echo "  (none)"
    fi
fi

# --- Show ignored -----------------------------------------------------------
if [[ "$SHOW_IGNORED" == true ]]; then
    print_section "🚫 IGNORED FILES"
    if [[ -n "$ignored_files" ]]; then
        echo "$ignored_files" | sort | print_list "\033[1;31m"    # red
    else
        echo "  (none)"
    fi
fi

# --- Show summary -----------------------------------------------------------
if [[ "$SHOW_SUMMARY" == true ]]; then
    print_section "📊 SUMMARY"
    printf "  ✅ Tracked   : %d\n" "$tracked_count"
    printf "  ⚠️  Untracked : %d\n" "$untracked_count"
    printf "  🚫 Ignored   : %d\n" "$ignored_count"
    echo
fi

#!/usr/bin/env bash
# Copy one or more files from a remote host to the local clipboard
# Multiple files are concatenated in order, like Haskell's mconcat

set -euo pipefail

# ---- Helper functions ----

# Print usage and exit
usage() {
    cat <<EOF
Usage: $0 <user@host> <remote-file-path> [<remote-file-path> ...]
Example: $0 user@remote ~/.xmonad/xmonad.hs ~/.xmonad/config.hs
EOF
    exit 1
}

# Check if required commands exist
check_dependencies() {
    local deps=("ssh" "xclip" "cat")
    for cmd in "${deps[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            echo "Error: $cmd is not installed" >&2
            exit 1
        fi
    done
}

# Copy remote files to local clipboard
copy_remote_files() {
    local remote="$1"
    shift
    local files=("$@")

    for file in "${files[@]}"; do
        ssh "$remote" "cat '$file'"
        echo    # Add newline between files
    done | xclip -selection clipboard
}

# ---- Main script ----

# Check arguments
if [ $# -lt 2 ]; then
    usage
fi

REMOTE_HOST="$1"
shift
REMOTE_FILES=("$@")

# Check dependencies
check_dependencies

# Copy to clipboard
copy_remote_files "$REMOTE_HOST" "${REMOTE_FILES[@]}"

echo "✅ Remote files from '$REMOTE_HOST' copied to local clipboard."


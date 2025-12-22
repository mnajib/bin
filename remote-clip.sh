#!/usr/bin/env bash
# remote-clip.sh
# Copy a file from a remote host to the local clipboard

set -euo pipefail # ensure this scrip exits on errors

# ---- Helper functions ----

# Print usage and exit
usage() {
    cat <<EOF
Usage: $0 <user@host> <remote-file-path>
Example: $0 user@remote ~/.xmonad/xmonad.hs
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

# Copy file from remote to local clipboard
copy_remote_file() {
    local remote="$1"
    local remote_file="$2"

    # Use SSH to cat the file and pipe into xclip
    ssh "$remote" "cat '$remote_file'" | xclip -selection clipboard
}

# ---- Main script ----

# Check arguments
if [ $# -ne 2 ]; then
    usage
fi

REMOTE_HOST="$1"
REMOTE_FILE="$2"

# Check dependencies
check_dependencies

# Copy to clipboard
copy_remote_file "$REMOTE_HOST" "$REMOTE_FILE"

echo "✅ Remote file '$REMOTE_FILE' from '$REMOTE_HOST' copied to local clipboard."


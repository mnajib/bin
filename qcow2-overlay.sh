#!/usr/bin/env bash
# qcow2-helper.sh
# Version 1.0.0

set -euo pipefail

SCRIPT_NAME=$(basename "$0")
VERSION="1.0.0"
DEBUG=0
LOG_FILE=""

log() {
    local msg="$1"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $msg" | tee -a "$LOG_FILE"
}

debug() {
    [[ $DEBUG -eq 1 ]] && echo "[DEBUG] $*"
}

usage() {
    cat <<EOF
Usage: $SCRIPT_NAME [OPTIONS] <paths/files>

Options:
  --list-overlay <dir/file>    List one-level overlay of .qcow2 files
  --create-overlay <file>      Create a new overlay image
  --help                       Show this help message
  --version                    Show script version
  --debug                      Enable debug output
  --log <file>                  Specify log file
EOF
}

get_base_image() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        return
    fi
    local base
    base=$(qemu-img info --output=json "$file" 2>/dev/null | jq -r '.["backing-filename"] // empty' || true)
    echo "$base"
}

list_overlay() {
    local paths=("$@")

    for path in "${paths[@]}"; do
        local files=()
        if [[ -d "$path" ]]; then
            mapfile -t files < <(find "$path" -maxdepth 1 -type f -name '*.qcow2' | sort)
        elif [[ -f "$path" ]]; then
            files=("$path")
        else
            echo "Skipping invalid path: $path"
            continue
        fi

        for f in "${files[@]}"; do
            local base
            base=$(get_base_image "$f" || true)

            # Determine log file location if not set
            if [[ -z "$LOG_FILE" ]]; then
                LOG_FILE="$(dirname "$f")/qcow2-helper.log"
            fi

            f_name=$(basename "$f")
            if [[ -n "$base" ]]; then
                base_name=$(basename "$base")
                echo "$f_name -> $base_name"
                # Only log to file, not stdout
                echo "$(date '+%Y-%m-%d %H:%M:%S') $f_name -> $base_name" >> "$LOG_FILE"
            else
                echo "$f_name"
                # Only log to file, not stdout
                echo "$(date '+%Y-%m-%d %H:%M:%S') $f_name" >> "$LOG_FILE"
            fi
        done
    done
}

create_overlay() {
    local src="$1"

    if [[ ! -f "$src" ]]; then
        echo "File does not exist: $src"
        exit 1
    fi

    # Determine log file location
    if [[ -z "$LOG_FILE" ]]; then
        LOG_FILE="$(dirname "$src")/qcow2-helper.log"
    fi

    local dir=$(dirname "$src")
    local base=$(basename "$src")
    local tmp_name="${base}.bak"
    local new_overlay="${base}"

    log "Creating overlay for $src"
    mv "$src" "$dir/$tmp_name"
    qemu-img create -f qcow2 -b "$dir/$tmp_name" "$dir/$new_overlay"
    log "Overlay created: $new_overlay (base: $tmp_name)"
}

# --- Parse CLI ---
if [[ $# -eq 0 ]]; then
    usage
    exit 0
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        --list-overlay)
            shift
            [[ $# -eq 0 ]] && { echo "--list-overlay requires a path"; exit 1; }
            list_overlay "$@"
            exit 0
            ;;
        --create-overlay)
            shift
            [[ $# -eq 0 ]] && { echo "--create-overlay requires a file"; exit 1; }
            create_overlay "$1"
            exit 0
            ;;
        --help)
            usage
            exit 0
            ;;
        --version)
            echo "$SCRIPT_NAME version $VERSION"
            exit 0
            ;;
        --debug)
            DEBUG=1
            shift
            ;;
        --log)
            shift
            [[ $# -eq 0 ]] && { echo "--log requires a file"; exit 1; }
            LOG_FILE="$1"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done


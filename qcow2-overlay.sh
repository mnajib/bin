#!/usr/bin/env bash
# qcow2-overlay.sh
# Version 1.3.0

set -euo pipefail

SCRIPT_NAME=$(basename "$0")
VERSION="1.3.0"
DEBUG=0
LOG_FILE=""

RED="\e[31m"
RESET="\e[0m"

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
  --fix <dir/file>             Fix self-pointing overlays
  --test                       Run internal tests
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

    local abs_file abs_base
    abs_file=$(readlink -f "$file")
    abs_base=$(readlink -f "$base" 2>/dev/null || true)
    if [[ "$abs_base" == "$abs_file" ]]; then
        debug "Detected self-pointing overlay: $file"
        base="SELFPOINTING"
    fi

    echo "$base"
}

list_overlay() {
    local paths=("$@")
    local self_pointing_files=()

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

            [[ -z "$LOG_FILE" ]] && LOG_FILE="$(dirname "$f")/qcow2-helper.log"

            local f_name=$(basename "$f")
            if [[ "$base" == "SELFPOINTING" ]]; then
                echo -e "${RED}${f_name} <-> ${f_name}${RESET}"
                self_pointing_files+=("$f_name")
                echo "$(date '+%Y-%m-%d %H:%M:%S') ${f_name} <-> ${f_name}" >> "$LOG_FILE"
            elif [[ -n "$base" ]]; then
                local base_name=$(basename "$base")
                echo "$f_name -> $base_name"
                echo "$(date '+%Y-%m-%d %H:%M:%S') $f_name -> $base_name" >> "$LOG_FILE"
            else
                echo "$f_name"
                echo "$(date '+%Y-%m-%d %H:%M:%S') $f_name" >> "$LOG_FILE"
            fi
        done
    done

    if [[ ${#self_pointing_files[@]} -gt 0 ]]; then
        echo -e "\n${RED}Warning:${RESET} Detected self-pointing overlays: ${self_pointing_files[*]}"
    fi
}

create_overlay() {
    local src="$1"

    [[ ! -f "$src" ]] && { echo "File does not exist: $src"; exit 1; }
    [[ -z "$LOG_FILE" ]] && LOG_FILE="$(dirname "$src")/qcow2-helper.log"

    local dir=$(dirname "$src")
    local base=$(basename "$src")
    local tmp_name="${base}.bak"
    local new_overlay="${base}"

    local abs_src abs_backing
    abs_src=$(readlink -f "$src")
    abs_backing=$(qemu-img info --output=json "$src" 2>/dev/null | jq -r '.["backing-filename"] // empty' || true)
    abs_backing=$(readlink -f "$abs_backing" 2>/dev/null || true)

    if [[ "$abs_src" == "$abs_backing" ]]; then
        log "Detected self-pointing overlay: $src. Renaming original to $tmp_name"
        mv "$src" "$dir/$tmp_name"
        src="$dir/$tmp_name"
    fi

    log "Creating overlay for $src"
    qemu-img create -f qcow2 -b "$src" -F qcow2 "$dir/$new_overlay"
    log "Overlay created: $new_overlay (base: $src)"
}

fix_self_pointing() {
    local paths=("$@")
    local fixed=()

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
            base=$(get_base_image "$f")
            if [[ "$base" == "SELFPOINTING" ]]; then
                create_overlay "$f"
                fixed+=("$(basename "$f")")
            fi
        done
    done

    if [[ ${#fixed[@]} -gt 0 ]]; then
        echo -e "\nFixed self-pointing overlays: ${fixed[*]}"
    else
        echo "No self-pointing overlays detected."
    fi
}

run_tests() {
    echo "Running internal tests..."
    local tmp_dir
    tmp_dir=$(mktemp -d)
    echo "Using temp dir: $tmp_dir"

    local base="$tmp_dir/base.qcow2"
    local overlay="$tmp_dir/overlay.qcow2"

    qemu-img create -f qcow2 "$base" 10M
    echo "Created base image: $base"

    qemu-img create -f qcow2 -b "$base" -F qcow2 "$overlay"
    echo "Created overlay image: $overlay -> $base"

    echo "Test list overlay output:"
    list_overlay "$tmp_dir"

    echo "Tests completed."
    rm -rf "$tmp_dir"
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
        --fix)
            shift
            [[ $# -eq 0 ]] && { echo "--fix requires a path"; exit 1; }
            fix_self_pointing "$@"
            exit 0
            ;;
        --test)
            run_tests
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


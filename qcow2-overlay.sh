#!/usr/bin/env bash
# qcow2-overlay.sh (with Maybe + logging + dry-run)
set -euo pipefail

# ------------------------------
# Logger
# ------------------------------
log_error() { echo "[ERROR] $1" >&2; }
log_info() { echo "[INFO] $1"; }

# ------------------------------
# Maybe helpers
# ------------------------------
maybe_safe() {
    local func="$1"; shift
    local output
    if output=$("$func" "$@" 2>&1); then
        echo "Just:$output"
    else
        log_error "$output"
        echo "Nothing:$output"
    fi
}

maybe_bind() {
    local maybe_val="$1"
    local func="$2"
    if [[ "$maybe_val" == Just:* ]]; then
        local val="${maybe_val#Just:}"
        "$func" "$val"
    else
        echo "$maybe_val"
    fi
}

# ------------------------------
# Pure functions
# ------------------------------
is_self_overlay() {
    local file="$1"
    local backing
    backing=$(qemu-img info "$file" 2>/dev/null | awk -F': ' '/backing file/ {print $2}')
    [[ "$file" == "$backing" ]] && echo "true" || echo "false"
}

detect_cycles_pure() {
    local files=("$@")
    declare -A seen cycles
    for f in "${files[@]}"; do
        local current="$f"
        while true; do
            local backing
            backing=$(qemu-img info "$current" 2>/dev/null | awk -F': ' '/backing file/ {print $2}')
            [[ -z "$backing" ]] && break
            if [[ -n "${seen[$backing]:-}" ]]; then
                cycles["$backing"]=1
                break
            fi
            seen["$backing"]=1
            current="$backing"
        done
    done
    echo "${!cycles[@]}"
}

# ------------------------------
# Impure functions
# ------------------------------
qcow2_create_overlay() {
    local base="$1" overlay="$2" backing_fmt="${3:-qcow2}" dry_run="${4:-false}"

    [[ "$base" == "$overlay" ]] && { log_error "Cannot create overlay pointing to self: $overlay"; return 1; }

    if [[ "$dry_run" == "true" ]]; then
        log_info "[DRY-RUN] Would create overlay: $overlay -> $base"
    else
        qemu-img create -f qcow2 -o backing_file="$base",backing_fmt="$backing_fmt" "$overlay"
    fi
}

qcow2_create_overlay_maybe() { maybe_safe qcow2_create_overlay "$@"; }

fix_self_overlay() {
    local file="$1" dry_run="${2:-false}"
    if [[ "$(is_self_overlay "$file")" == "true" ]]; then
        local backup="${file}.bak"
        if [[ "$dry_run" == "true" ]]; then
            log_info "[DRY-RUN] Would rename $file -> $backup and create overlay"
        else
            mv "$file" "$backup"
            qcow2_create_overlay_maybe "$backup" "$file"
            log_info "Fixed self-pointing overlay: $file"
        fi
    fi
}

fix_cycles() {
    local files=("$@") dry_run="${files[-1]}"
    unset 'files[-1]'  # last arg is dry_run flag
    local cycles
    cycles=($(detect_cycles_pure "${files[@]}"))
    for f in "${cycles[@]}"; do
        local backup="${f}.bak"
        if [[ "$dry_run" == "true" ]]; then
            log_info "[DRY-RUN] Would rename $f -> $backup and create overlay"
        else
            mv "$f" "$backup"
            qcow2_create_overlay_maybe "$backup" "$f"
            log_info "Fixed cyclic overlay: $f"
        fi
    done
}

# ------------------------------
# List overlays
# ------------------------------
list_overlays() {
    local dir="$1"
    for f in "$dir"/*.qcow2; do
        [[ -e "$f" ]] || continue
        local backing
        backing=$(qemu-img info "$f" 2>/dev/null | awk -F': ' '/backing file/ {print $2}')
        [[ -n "$backing" ]] && echo "$f -> $backing" || echo "$f"
    done
}

# ------------------------------
# Unit tests
# ------------------------------
unit_test() {
    local tmp_dir
    tmp_dir=$(mktemp -d)
    log_info "Running unit tests... Temp dir: $tmp_dir"

    local base="$tmp_dir/base.qcow2"
    local overlay="$tmp_dir/overlay.qcow2"
    local self="$tmp_dir/self.qcow2"

    qemu-img create -f qcow2 "$base" 10M &>/dev/null
    qemu-img create -f qcow2 "$self" 10M &>/dev/null

    log_info "- Testing normal overlay creation"
    qcow2_create_overlay_maybe "$base" "$overlay" false

    log_info "- Testing self-pointing overlay detection & fix"
    qemu-img create -f qcow2 -o backing_file="$self" "$self.tmp" &>/dev/null
    fix_self_overlay "$self.tmp" true

    log_info "- Testing cyclic overlay detection & fix"
    local c1="$tmp_dir/cycle1.qcow2"
    local c2="$tmp_dir/cycle2.qcow2"
    qemu-img create -f qcow2 "$c1" 10M &>/dev/null
    qemu-img create -f qcow2 "$c2" 10M &>/dev/null
    qemu-img create -f qcow2 -o backing_file="$c2" "$c1.tmp" &>/dev/null
    qemu-img create -f qcow2 -o backing_file="$c1.tmp" "$c2.tmp" &>/dev/null
    fix_cycles "$c1.tmp" "$c2.tmp" true

    log_info "Unit test done."
}

# ------------------------------
# Main CLI
# ------------------------------
main() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: $0 --list-overlay <dir> | --fix <file> | --fix-cycles <files> | --dry-run ... | --test"
        exit 1
    fi

    local cmd="$1"
    shift
    case "$cmd" in
        --list-overlay) list_overlays "$1" ;;
        --fix) fix_self_overlay "$1" false ;;
        --fix-cycles) fix_cycles "${@:1}" false ;;
        --dry-run)
            if [[ "$1" == "--fix" ]]; then fix_self_overlay "$2" true
            elif [[ "$1" == "--fix-cycles" ]]; then fix_cycles "${@:2}" true
            fi
            ;;
        --test) unit_test ;;
        *)
            echo "Usage: $0 --list-overlay <dir> | --fix <file> | --fix-cycles <files> | --dry-run ... | --test"
            exit 1
            ;;
    esac
}

main "$@"


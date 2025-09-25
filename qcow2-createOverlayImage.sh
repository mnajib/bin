#!/usr/bin/env bash
# qcow2-overlay-create.sh
#
# Helper script to create and inspect overlay qcow2 images.
#
# Usage:
#   Create overlay:
#     ./qcow2-overlay-create.sh [-s SIZE] BASE.qcow2 [OVERLAY.qcow2]
#   Inspect image chain:
#     ./qcow2-overlay-create.sh -i IMAGE.qcow2 [--combined]
#   Scan directory (default: .):
#     ./qcow2-overlay-create.sh [-r] -i
#   Show help:
#     ./qcow2-overlay-create.sh -h
#
# Functional style: small, pure helpers + clear separation of side effects.

set -euo pipefail

# =========================
# Logger functions
# =========================
log_info()  { echo "[INFO] $*" >&2; }
log_error() { echo "[ERROR] $*" >&2; }

# =========================
# Pure helper functions
# =========================

check_file_exists() { [[ -f "$1" ]]; }
check_not_exists()  { [[ ! -e "$1" ]]; }

basename_noext() {
    local f=$1
    echo "$(basename "$f" .qcow2)"
}

find_next_overlay_name() {
    local base=$1
    local prefix
    prefix="$(basename_noext "$base")-overlay"
    local i=1
    local candidate
    while :; do
        candidate=$(printf "%s-%03d.qcow2" "$prefix" "$i")
        if [[ ! -e "$candidate" ]]; then
            echo "$candidate"
            return
        fi
        ((i++))
    done
}

find_qcow2_files() {
    local recursive=$1
    if [[ "$recursive" == "true" ]]; then
        find . -type f -name "*.qcow2" | sort
    else
        ls -1 *.qcow2 2>/dev/null || true
    fi
}

# =========================
# Non-pure functions
# =========================

create_overlay() {
    local base=$1
    local overlay=$2
    local size=$3

    log_info "Creating overlay '$overlay' based on '$base'"

    if [[ -n "$size" ]]; then
        qemu-img create -f qcow2 -b "$base" -F qcow2 "$overlay" "$size"
        log_info "Overlay created with size $size"
    else
        qemu-img create -f qcow2 -b "$base" -F qcow2 "$overlay"
        log_info "Overlay created with inherited size"
    fi
}

# Recursively follow qcow2 backing files and print as tree
inspect_chain() {
    local image=$1
    local prefix=$2
    local is_last=$3

    local branch="├──"
    local next_prefix="$prefix│   "
    if [[ "$is_last" == "true" ]]; then
        branch="└──"
        next_prefix="$prefix    "
    fi

    echo "${prefix}${branch} $(basename "$image")"

    local backing
    backing=$(qemu-img info --output=json "$image" | jq -r '.["backing-filename"] // empty')

    if [[ -n "$backing" ]]; then
        if [[ "$backing" != /* ]]; then
            backing="$(dirname "$image")/$backing"
        fi
        if check_file_exists "$backing"; then
            inspect_chain "$backing" "$next_prefix" true
        else
            echo "${next_prefix}└── [missing: $backing]"
        fi
    fi
}

inspect_image() {
    local image=$1
    local combined=$2

    if ! check_file_exists "$image"; then
        log_error "Image '$image' does not exist"
        return 1
    fi

    log_info "Inspecting image chain for '$image'"
    inspect_chain "$image" "" true

    if [[ "$combined" == "true" ]]; then
        echo
        log_info "Detailed qemu-img info for '$image'"
        qemu-img info "$image"
    fi
}

print_help() {
    cat <<EOF
qcow2-overlay-create.sh - Helper script for creating and inspecting qcow2 overlay images

Usage:
  Create overlay:
    $0 [-s SIZE] BASE.qcow2 [OVERLAY.qcow2]
      -s, --size SIZE   Set size for the overlay (e.g. 20G).
                        If omitted, inherits base size.
      If OVERLAY is not given, a name is auto-generated.

  Inspect image chain:
    $0 -i IMAGE.qcow2 [--combined]
      -i, --inspect IMAGE   Inspect overlay chain for given IMAGE.
          --combined        Show both tree chain and qemu-img info.

  Scan for all qcow2 files (default current dir):
    $0 -i                 Inspect all *.qcow2 files in current directory
    $0 -i -r              Inspect all *.qcow2 files recursively

  Show help:
    $0 -h | --help
EOF
}

# =========================
# Main
# =========================
main() {
    local size=""
    local inspect=""
    local combined="false"
    local recursive="false"
    local positional=()

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -s|--size)
                size=$2
                shift 2
                ;;
            -i|--inspect)
                inspect=${2:-""}
                # if next arg is not empty and not starting with -, treat as file
                if [[ -n "$inspect" && "$inspect" != "-"* ]]; then
                    shift 2
                else
                    inspect="" # means: scan mode
                    shift 1
                fi
                ;;
            --combined)
                combined="true"
                shift
                ;;
            -r|--recursive)
                recursive="true"
                shift
                ;;
            -h|--help)
                print_help
                exit 0
                ;;
            -*)
                log_error "Unknown option: $1"
                echo
                print_help
                exit 1
                ;;
            *)
                positional+=("$1")
                shift
                ;;
        esac
    done

    # Mode: inspect
    if [[ -n "$inspect" || "$inspect" == "" && "${#positional[@]}" -eq 0 ]]; then
        local images=()
        if [[ -n "$inspect" ]]; then
            images=("$inspect")
        else
            # No file given: scan for all qcow2
            images=($(find_qcow2_files "$recursive"))
        fi

        if [[ ${#images[@]} -eq 0 ]]; then
            log_error "No .qcow2 files found"
            exit 1
        fi

        for img in "${images[@]}"; do
            inspect_image "$img" "$combined"
            echo
        done
        exit 0
    fi

    # Mode: create overlay
    if [[ ${#positional[@]} -lt 1 || ${#positional[@]} -gt 2 ]]; then
        print_help
        exit 1
    fi

    local base=${positional[0]}
    local overlay=${positional[1]:-}

    if ! check_file_exists "$base"; then
        log_error "Base image '$base' does not exist"
        exit 1
    fi

    if [[ -z "$overlay" ]]; then
        overlay=$(find_next_overlay_name "$base")
        log_info "No overlay name given, auto-generated: $overlay"
    fi

    if ! check_not_exists "$overlay"; then
        log_error "Overlay image '$overlay' already exists"
        exit 1
    fi

    create_overlay "$base" "$overlay" "$size"
}

main "$@"


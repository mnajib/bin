#!/usr/bin/env bash
# qcow2-overlay.sh (Maybe + logging + dry-run + safe fix with restore on failure)
set -euo pipefail

# ==========================================
# 1. Logger (impure)
# ==========================================
log_error() { echo "[ERROR] $1" >&2; }
log_info()  { echo "[INFO]  $1"; }

# ==========================================
# 2. Maybe Monad (pure-ish wrappers)
# ==========================================
maybe_safe() {
    # maybe_safe <function> <args...>
    local func="$1"; shift
    local out
    if out=$("$func" "$@" 2>&1); then
        echo "Just:$out"
    else
        log_error "$out"
        echo "Nothing:$out"
    fi
}

maybe_bind() {
    # maybe_bind "Just:value" function
    local maybe="$1"
    local func="$2"
    if [[ "$maybe" == Just:* ]]; then
        local v="${maybe#Just:}"
        "$func" "$v"
    else
        echo "$maybe"
    fi
}

# ==========================================
# 3. Pure helpers
# ==========================================
# Extract backing file (pure helper). Returns single backing filename (possibly relative).
_extract_backing_relative() {
    local file="$1"
    # Match exact field "backing file"
    qemu-img info "$file" 2>/dev/null |
        awk -F': ' '$1 == "backing file" { print $2; exit }'
}

# Pure test: is file self-pointing (file == backing)
_is_self_overlay_pure() {
    local file="$1"
    local backing="$2"
    [[ "$file" == "$backing" ]] && echo true || echo false
}

# Detect cycles purely; returns list of files that are part of cycles (space-separated)
detect_cycles_pure() {
    local files=("$@")
    declare -A seen cycles
    for f in "${files[@]}"; do
        local cur="$f"
        while true; do
            local backing_rel
            backing_rel=$(_extract_backing_relative "$cur")
            [[ -z "$backing_rel" ]] && break

            # Normalize to absolute path to compare reliably
            local backing_abs
            if [[ "$backing_rel" == /* ]]; then
                backing_abs="$backing_rel"
            else
                backing_abs="$(dirname "$cur")/$backing_rel"
            fi

            if [[ -n "${seen[$backing_abs]:-}" ]]; then
                cycles["$backing_abs"]=1
                break
            fi
            seen["$backing_abs"]=1
            cur="$backing_abs"
        done
    done

    echo "${!cycles[@]}"
}

# ==========================================
# 4. Impure functions
# ==========================================
# Return absolute backing file (or empty string)
get_backing_file() {
    local file="$1"
    local backing_rel
    backing_rel=$(_extract_backing_relative "$file") || true
    [[ -z "$backing_rel" ]] && { echo ""; return; }

    if [[ "$backing_rel" == /* ]]; then
        echo "$backing_rel"
    else
        echo "$(dirname "$file")/$backing_rel"
    fi
}

qcow2_create_overlay() {
    # qcow2_create_overlay <base> <overlay> <dry_run>
    local base="$1"
    local overlay="$2"
    local dry_run="${3:-false}"

    if [[ "$base" == "$overlay" ]]; then
        log_error "Cannot create overlay pointing to itself: $overlay"
        return 1
    fi

    if [[ "$dry_run" == "true" ]]; then
        log_info "[DRY-RUN] create: $overlay → $base"
    else
        # always declare backing_fmt explicitly
        qemu-img create -f qcow2 \
            -o backing_file="$base",backing_fmt="qcow2" \
            "$overlay"
    fi
}

qcow2_create_overlay_maybe() {
    maybe_safe qcow2_create_overlay "$@"
}

# ---------- SAFER self-overlay fix ----------
fix_self_overlay() {
    # fix_self_overlay <file> [dry_run]
    local file="$1"
    local dry_run="${2:-false}"

    local backing
    backing=$(get_backing_file "$file")

    if [[ "$(_is_self_overlay_pure "$file" "$backing")" == true ]]; then
        local bak="${file}.bak"

        if [[ "$dry_run" == "true" ]]; then
            log_info "[DRY-RUN] SELF: rename $file → $bak, recreate overlay"
            return 0
        fi

        # move original to backup
        mv "$file" "$bak"
        # attempt to create overlay; capture Maybe result
        local result
        result=$(qcow2_create_overlay_maybe "$bak" "$file" false) || result="$result"

        if [[ "$result" == Nothing:* ]]; then
            # restore original on failure
            log_error "Failed to recreate overlay for $file; restoring backup"
            mv "$bak" "$file"
            return 1
        fi

        log_info "Fixed self-overlay: $file"
    else
        log_info "No self-overlay detected: $file"
    fi
}

# ---------- SAFER cycle fix ----------
fix_cycles() {
    # fix_cycles <file1> <file2> ... <dry_run_flag>
    local files=("$@")
    if [[ ${#files[@]} -eq 0 ]]; then
        log_info "fix_cycles: no files given"
        return
    fi

    local dry_run="${files[-1]}"
    unset 'files[-1]'

    # Normalize files array: ensure absolute paths
    local normalized=()
    for f in "${files[@]}"; do
        normalized+=("$(readlink -f "$f")")
    done

    local cycles
    mapfile -t cycles < <(detect_cycles_pure "${normalized[@]}")

    for f in "${cycles[@]}"; do
        local bak="${f}.bak"

        if [[ "$dry_run" == "true" ]]; then
            log_info "[DRY-RUN] CYCLE: rename $f → $bak, recreate overlay"
            continue
        fi

        mv "$f" "$bak"
        local result
        result=$(qcow2_create_overlay_maybe "$bak" "$f" false) || result="$result"

        if [[ "$result" == Nothing:* ]]; then
            log_error "Failed to recreate overlay for $f; restoring backup"
            mv "$bak" "$f"
            # continue to next cycle; do not abort entire run
            continue
        fi

        log_info "Fixed cycle: $f"
    done
}

# ==========================================
# 5. List overlays with markers
# ==========================================
list_overlays() {
    local dir="$1"
    if [[ -z "$dir" ]]; then
        log_error "list_overlays: missing directory"
        return 1
    fi

    # collect files (absolute paths)
    local files=()
    for f in "$dir"/*.qcow2; do
        [[ -e "$f" ]] || continue
        files+=("$(readlink -f "$f")")
    done

    # detect cycles (will return absolute paths)
    local cycles
    mapfile -t cycles < <(detect_cycles_pure "${files[@]}")

    for f in "${files[@]}"; do
        local backing
        backing=$(get_backing_file "$f")
        local mark=""
        if [[ "$(_is_self_overlay_pure "$f" "$backing")" == true ]]; then
            mark=" [SELF]"
        else
            for c in "${cycles[@]}"; do
                if [[ "$c" == "$f" ]]; then
                    mark=" [CYCLE]"
                    break
                fi
            done
        fi

        if [[ -n "$backing" ]]; then
            echo "$(basename "$f") -> $(basename "$backing")$mark"
        else
            echo "$(basename "$f")$mark"
        fi
    done
}

# ==========================================
# 6. Unit Tests (full internal test)
# ==========================================
unit_test() {
    local tmp
    tmp=$(mktemp -d)
    log_info "Testing inside: $tmp"

    local base="$tmp/base.qcow2"
    local overlay="$tmp/overlay.qcow2"
    local self="$tmp/self.qcow2"

    qemu-img create -f qcow2 "$base" 10M >/dev/null
    qemu-img create -f qcow2 "$self" 10M >/dev/null

    log_info "- create normal overlay"
    qcow2_create_overlay_maybe "$base" "$overlay" false

    log_info "- create self-overlay test (backing_fmt explicit)"
    qemu-img create -f qcow2 -o backing_file="$self",backing_fmt="qcow2" "$self.tmp" >/dev/null 2>/dev/null || true
    fix_self_overlay "$self.tmp" true

    log_info "- create cyclic overlays (backing_fmt explicit)"
    local A="$tmp/A.qcow2"
    local B="$tmp/B.qcow2"
    qemu-img create -f qcow2 "$A" 10M >/dev/null
    qemu-img create -f qcow2 "$B" 10M >/dev/null
    qemu-img create -f qcow2 -o backing_file="$B",backing_fmt="qcow2" "$A.tmp" >/dev/null
    qemu-img create -f qcow2 -o backing_file="$A.tmp",backing_fmt="qcow2" "$B.tmp" >/dev/null

    fix_cycles "$A.tmp" "$B.tmp" true

    log_info "Unit test complete."
    rm -rf "$tmp"
}

# ==========================================
# 7. CLI
# ==========================================
usage() {
    cat <<EOF
Usage:
  $0 --list-overlay <dir>
  $0 --fix <file>
  $0 --fix-cycles <file1> <file2> ... --dry-run-flag
  $0 --dry-run --fix <file>
  $0 --dry-run --fix-cycles <file1> <file2> ...
  $0 --test
EOF
}

main() {
    if [[ $# -eq 0 ]]; then
        usage
        exit 1
    fi

    local cmd="$1"; shift

    case "$cmd" in
        --list-overlay)
            [[ $# -lt 1 ]] && { log_error "--list-overlay requires a directory"; exit 1; }
            list_overlays "$1"
            ;;
        --fix)
            [[ $# -lt 1 ]] && { log_error "--fix requires a file"; exit 1; }
            fix_self_overlay "$1" false
            ;;
        --fix-cycles)
            if [[ $# -lt 1 ]]; then
                log_error "--fix-cycles requires at least one file"
                exit 1
            fi
            fix_cycles "$@" false
            ;;
        --dry-run)
            if [[ $# -lt 2 ]]; then
                log_error "--dry-run requires a subcommand and its args"
                exit 1
            fi
            case "$1" in
                --fix)
                    shift
                    [[ $# -lt 1 ]] && { log_error "--dry-run --fix requires a file"; exit 1; }
                    fix_self_overlay "$1" true
                    ;;
                --fix-cycles)
                    shift
                    [[ $# -lt 1 ]] && { log_error "--dry-run --fix-cycles requires at least one file"; exit 1; }
                    fix_cycles "$@" true
                    ;;
                *)
                    log_error "Unknown --dry-run subcommand: $1"
                    exit 1
                    ;;
            esac
            ;;
        --test) unit_test ;;
        --help|-h) usage ;;
        *) log_error "Unknown option: $cmd"; usage; exit 1 ;;
    esac
}

main "$@"


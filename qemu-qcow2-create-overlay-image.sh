#!/usr/bin/env bash

###############################################################################
# Generic helpers (pure)
###############################################################################

# pure_basename :: String -> String
pure_basename() {
    local path="$1"
    printf "%s" "${path##*/}"
}

# pure_dirname :: String -> String
pure_dirname() {
    local path="$1"
    printf "%s" "${path%/*}"
}

# pure_remove_extension :: String -> String
pure_remove_extension() {
    local filename="$1"
    printf "%s" "${filename%.*}"
}

# pure_extension :: String -> String
pure_extension() {
    local filename="$1"
    printf "%s" "${filename##*.}"
}

# pure_join_path :: dir -> file -> path
pure_join_path() {
    local dir="$1"
    local file="$2"
    printf "%s/%s" "$dir" "$file"
}

###############################################################################
# Maybe-like helpers
###############################################################################

# maybe_check_file :: path -> returns 0 if exists, 1 otherwise
maybe_check_file() {
    local fp="$1"
    [[ -f "$fp" ]]
}

###############################################################################
# Non-pure IO functions
###############################################################################

# io_log :: msg -> (prints log message)
io_log() {
    printf "[LOG] %s\n" "$*"
}

# io_err :: msg -> (prints error message)
io_err() {
    printf "[ERR] %s\n" "$*" >&2
}

# io_create_overlay :: base -> output -> void
# Uses qemu-img create -F qcow2 -b <base> <img>
io_create_overlay() {
    local base="$1"
    local out="$2"
    qemu-img create -f qcow2 -F qcow2 -b "$base" "$out"
}

# io_rename :: old -> new
io_rename() {
    mv -f "$1" "$2"
}

###############################################################################
# Main logic
###############################################################################

main() {
    local input="$1"

    if [[ -z "$input" ]]; then
        io_err "Usage: $0 <qcow2-image>"
        exit 1
    fi

    if ! maybe_check_file "$input"; then
        io_err "File does not exist: $input"
        exit 1
    fi

    # Paths
    local dir base filename ext
    filename="$(pure_basename "$input")"
    dir="$(pure_dirname "$input")"
    base="$(pure_remove_extension "$filename")"
    ext="$(pure_extension "$filename")"

    # Derived names
    local base_name="${base}-base.${ext}"
    local overlay_name="${base}-overlay.${ext}"

    local base_path
    local overlay_path
    base_path="$(pure_join_path "$dir" "$base_name")"
    overlay_path="$(pure_join_path "$dir" "$overlay_name")"

    io_log "Input file:        $input"
    io_log "Base image name:   $base_path"
    io_log "Overlay image name: $overlay_path"

    io_log "Creating overlay image referencing base..."
    io_create_overlay "$input" "$overlay_path"

    io_log "Renaming original → base..."
    io_rename "$input" "$base_path"

    io_log "Renaming overlay → original name..."
    io_rename "$overlay_path" "$input"

    io_log "Done!"
    io_log "Final state:"
    io_log " - Base image: $base_path"
    io_log " - Active VM image: $input"
}

main "$@"


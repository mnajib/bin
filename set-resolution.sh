#!/usr/bin/env bash

# =============================================================================
# set-resolution.sh
# Set custom xrandr modeline untuk monitor yang tidak dapat baca EDID betul.
# Berguna untuk monitor lama yang disambung via VGA.
#
# Gaya: Haskell-inspired — fungsi kecil, pure (tiada side-effect), composable.
# Side-effects (xrandr calls) diasingkan ke bahagian bawah sahaja.
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# CONSTANTS — semua nilai tetap di satu tempat (seperti `data` dalam Haskell)
# -----------------------------------------------------------------------------

readonly SCRIPT_NAME="$(basename "$0")"
readonly DEFAULT_OUTPUT="VGA-1"
readonly DEFAULT_MODE="1920x1080_60.00"
readonly DEFAULT_PCLK="173.00"
readonly DEFAULT_MODELINE="1920 2048 2248 2576  1080 1083 1088 1120 -hsync +vsync"

# -----------------------------------------------------------------------------
# PURE FUNCTIONS — tiada side-effect, hanya transform data
# (seperti fungsi pure dalam Haskell)
# -----------------------------------------------------------------------------

# Bina nama mode dari resolusi dan refresh rate
# Usage: make_mode_name "1920x1080" "60.00"  -> "1920x1080_60.00"
make_mode_name() {
    local resolution="$1"   # cth: "1920x1080"
    local refresh="$2"      # cth: "60.00"
    echo "${resolution}_${refresh}"
}

# Bina string modeline penuh untuk xrandr --newmode
# Usage: make_modeline_str <name> <pclk> <timing>
make_modeline_str() {
    local name="$1"     # cth: "1920x1080_60.00"
    local pclk="$2"     # pixel clock dalam MHz, cth: "173.00"
    local timing="$3"   # baki timing string dari cvt
    echo "\"${name}\" ${pclk} ${timing}"
}

# Semak sama ada satu string kosong
# Returns: 0 (true) jika kosong, 1 (false) jika tidak
is_empty() {
    local value="$1"
    [[ -z "$value" ]]
}

# Semak sama ada output xrandr wujud pada sistem
# Returns: 0 jika wujud, 1 jika tidak
output_exists() {
    local output="$1"   # cth: "VGA-1"
    xrandr --query | grep -q "^${output} "
}

# Semak sama ada mode sudah didaftarkan dalam xrandr
# Returns: 0 jika sudah ada, 1 jika belum
mode_exists() {
    local mode_name="$1"    # cth: "1920x1080_60.00"
    xrandr --query | grep -q "  ${mode_name} "
}

# Format mesej log dengan timestamp
# Usage: fmt_log "INFO" "mesej"  -> "[INFO] 08:05:01 mesej"
fmt_log() {
    local level="$1"
    local msg="$2"
    echo "[${level}] $(date '+%H:%M:%S') ${msg}"
}

# -----------------------------------------------------------------------------
# LOGGING — side-effect terpencil (tulis ke stderr)
# -----------------------------------------------------------------------------

log_info()  { fmt_log "INFO " "$1" >&2; }
log_ok()    { fmt_log "OK   " "$1" >&2; }
log_warn()  { fmt_log "WARN " "$1" >&2; }
log_error() { fmt_log "ERROR" "$1" >&2; }

# -----------------------------------------------------------------------------
# HELP / USAGE
# -----------------------------------------------------------------------------

usage() {
    cat <<EOF
Guna: ${SCRIPT_NAME} [PILIHAN]

Set resolusi custom pada output xrandr menggunakan modeline manual.
Berguna untuk monitor lama via VGA yang tidak dapat baca EDID dengan betul.

PILIHAN:
  -o, --output   OUTPUT    Nama output xrandr (default: ${DEFAULT_OUTPUT})
                           Contoh: VGA-1, HDMI-1, DP-1
  -m, --mode     NAME      Nama mod (default: ${DEFAULT_MODE})
                           Contoh: "1920x1080_60.00"
  -p, --pclk     MHZ       Pixel clock dalam MHz (default: ${DEFAULT_PCLK})
                           Dapatkan nilai ini dari: cvt <lebar> <tinggi> <hz>
  -t, --timing   STRING    Timing string dari cvt (default: modeline 1080p)
                           Contoh: "1920 2048 2248 2576  1080 1083 1088 1120 -hsync +vsync"
  -d, --dry-run            Tunjuk arahan sahaja, jangan laksanakan
  -l, --list               Senaraikan output xrandr yang tersedia
  -h, --help               Tunjuk mesej bantuan ini

CONTOH:
  # Guna nilai default (1920x1080 @ 60Hz pada VGA-1)
  ${SCRIPT_NAME}

  # Tentukan output lain
  ${SCRIPT_NAME} --output HDMI-1

  # Dry-run — lihat arahan tanpa laksanakan
  ${SCRIPT_NAME} --dry-run

  # Resolusi custom — jana modeline dulu dengan: cvt 1680 1050 60
  ${SCRIPT_NAME} --mode "1680x1050_60.00" --pclk "146.25" \\
    --timing "1680 1784 1960 2240  1050 1053 1059 1089 -hsync +vsync"

  # Senarai output tersedia
  ${SCRIPT_NAME} --list

NOTA:
  Modeline boleh dijana menggunakan arahan: cvt <lebar> <tinggi> <hz>
  Contoh: cvt 1920 1080 60
EOF
}

# -----------------------------------------------------------------------------
# LIST OUTPUTS — paparkan semua output xrandr
# -----------------------------------------------------------------------------

list_outputs() {
    log_info "Output xrandr yang tersedia:"
    xrandr --query | grep -E "^[A-Z].*connected" | \
        awk '{printf "  %-12s %s\n", $1, $3}'
}

# -----------------------------------------------------------------------------
# SIDE-EFFECT FUNCTIONS — semua xrandr calls di sini sahaja
# (seperti IO monad dalam Haskell — diasingkan dari logik pure)
# -----------------------------------------------------------------------------

# Daftarkan mod baharu ke xrandr (xrandr --newmode)
xrandr_newmode() {
    local modeline_str="$1"
    log_info "Mendaftarkan mod baharu: ${modeline_str}"
    # eval diperlukan kerana modeline_str mengandungi quoted name
    eval xrandr --newmode "${modeline_str}"
}

# Tambah mod ke output tertentu (xrandr --addmode)
xrandr_addmode() {
    local output="$1"
    local mode_name="$2"
    log_info "Menambah mod '${mode_name}' ke output '${output}'"
    xrandr --addmode "${output}" "${mode_name}"
}

# Aktifkan mod pada output (xrandr --output --mode)
xrandr_setmode() {
    local output="$1"
    local mode_name="$2"
    log_info "Mengaktifkan mod '${mode_name}' pada '${output}'"
    xrandr --output "${output}" --mode "${mode_name}"
}

# Dry-run: paparkan arahan yang akan dilaksanakan tanpa laksanakannya
dry_run_print() {
    local output="$1"
    local mode_name="$2"
    local pclk="$3"
    local timing="$4"

    echo ""
    echo "=== DRY RUN — arahan yang akan dilaksanakan ==="
    echo ""
    echo "xrandr --newmode \"${mode_name}\" ${pclk} ${timing}"
    echo "xrandr --addmode ${output} \"${mode_name}\""
    echo "xrandr --output ${output} --mode \"${mode_name}\""
    echo ""
    echo "=== (tiada perubahan dibuat) ==="
}

# -----------------------------------------------------------------------------
# MAIN LOGIC — orchestrate semua fungsi di atas
# (seperti `main` dalam Haskell — hanya IO, delegate ke pure functions)
# -----------------------------------------------------------------------------

main() {
    # -- Parse argumen --
    local output="$DEFAULT_OUTPUT"
    local mode_name="$DEFAULT_MODE"
    local pclk="$DEFAULT_PCLK"
    local timing="$DEFAULT_MODELINE"
    local dry_run=false
    local do_list=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -o|--output)  output="$2";    shift 2 ;;
            -m|--mode)    mode_name="$2"; shift 2 ;;
            -p|--pclk)    pclk="$2";      shift 2 ;;
            -t|--timing)  timing="$2";    shift 2 ;;
            -d|--dry-run) dry_run=true;   shift   ;;
            -l|--list)    do_list=true;   shift   ;;
            -h|--help)    usage; exit 0           ;;
            *)
                log_error "Argumen tidak dikenali: $1"
                echo ""
                usage
                exit 1
                ;;
        esac
    done

    # -- List mode --
    if $do_list; then
        list_outputs
        exit 0
    fi

    # -- Dry-run mode --
    if $dry_run; then
        dry_run_print "$output" "$mode_name" "$pclk" "$timing"
        exit 0
    fi

    # -- Validate: output mesti wujud --
    if ! output_exists "$output"; then
        log_error "Output '${output}' tidak dijumpai. Guna --list untuk lihat output tersedia."
        exit 1
    fi
    log_ok "Output '${output}' dijumpai."

    # -- Daftarkan mod (skip kalau sudah ada) --
    if mode_exists "$mode_name"; then
        log_warn "Mod '${mode_name}' sudah wujud, langkau --newmode."
    else
        local modeline_str
        modeline_str="$(make_modeline_str "$mode_name" "$pclk" "$timing")"
        xrandr_newmode "$modeline_str"
        log_ok "Mod '${mode_name}' berjaya didaftarkan."
    fi

    # -- Tambah mod ke output --
    xrandr_addmode "$output" "$mode_name"
    log_ok "Mod ditambah ke output '${output}'."

    # -- Aktifkan mod --
    xrandr_setmode "$output" "$mode_name"
    log_ok "Resolusi '${mode_name}' aktif pada '${output}'."

    echo ""
    log_ok "Selesai! Semak dengan: xrandr | grep -A1 '${output}'"
}

# Entry point
main "$@"

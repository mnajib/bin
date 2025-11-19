#!/usr/bin/env bash

# Script: display-scale.sh
# Version: 7.0.0 (Clean syntax: --scale 75 as primary command)
# Description: Toggles or sets display scale (zoom-out) using xrandr.

# --- Configuration (Pure Data - Immutable) ---
readonly SCRIPT_VERSION="7.1.0"
readonly SCRIPT_NAME=$(basename "$0")
readonly NORMAL_SCALE="1x1"
readonly NORMAL_SCALE_FLOAT="1.0"

# Declare and treat the scale factors as immutable
declare -rA SCALE_FACTORS=(
    ["75"]="1.3333x1.3333" # 75% visual size (1 / 0.75 ≈ 1.3333)
    ["55"]="1.8182x1.8182" # 55% visual size (1 / 0.55 ≈ 1.8182)
    ["0"]="$NORMAL_SCALE"  # 100% visual size (Reset/Normal)
)

# --- Globals (Mutable during parsing, then Immutable) ---
VERBOSE=0
DEBUG=0
DRYRUN=0
COMMAND=""      # Will store: "scale", "toggle", "reset", "test", "help", "version"
SCALE_LEVEL=""  # Will store: "75", "55", "0"

# ==============================================================================
#  ✨ Pure Utility Functions
# (Deterministic, No Side Effects)
# ==============================================================================

# Pure Function: log
log() {
    local level="$1"
    shift
    local message="$@"
    if [ "$level" == "DEBUG" ] && [ "$DEBUG" -eq 1 ]; then
        echo "[DEBUG] $message" >&2
    elif [ "$level" == "VERBOSE" ] && [ "$VERBOSE" -eq 1 ]; then
        echo "[INFO] $message" >&2
    elif [ "$level" == "INFO" ] || [ "$level" == "ERROR" ]; then
        echo "[$level] $message" >&2
    elif [ "$level" == "DRYRUN" ]; then
        echo "[$level] $message" >&2
    fi
}

# Pure Function: normalize_scale
# Output: The X-scale float (e.g., "1.3333") printed to stdout
normalize_scale() {
    local scale_factor="$1"
    echo "$scale_factor" | cut -d 'x' -f 1
}

# ==============================================================================
# ☔ Impure I/O Functions (Maybe/Either Principle)
# (Signal success/failure via exit code 0/non-zero)
# ==============================================================================

# Impure Function: detect_output
# Output: Output name (e.g., DVI-I-1) printed to stdout on success.
detect_output() {
    local output
    output=$(xrandr | awk '/ connected / {print $1; exit}')

    if [ -z "$output" ]; then
        log "ERROR" "No connected display output found. Cannot proceed." >&2
        return 1
    fi
    log "DEBUG" "Detected output: $output"
    echo "$output"
    return 0
}

# Impure Function: get_current_scale
# Output: The X-scale float (e.g., "1.333298") printed to stdout on success.
get_current_scale() {
    local output_name="$1"
    local scale

    scale=$(xrandr --verbose | awk '
        /^\t'"$output_name"'/ { in_output=1; next }
        /Transform:/ {
            getline;
            print $1;
            exit
        }
    ')

    if [ -z "$scale" ]; then
        log "DEBUG" "Scale detection failed. Assuming $NORMAL_SCALE_FLOAT" >&2
        echo "$NORMAL_SCALE_FLOAT"
        return 0
    fi

    log "DEBUG" "Current raw X-scale detected: $scale"
    echo "$scale"
    return 0
}

# Impure Function: set_scale
# Output: None (logging only).
set_scale() {
    local output="$1"
    local scale_factor="$2"
    log "INFO" "Applying scale $scale_factor to $output." >&2

    if [ $DRYRUN -ne 1 ]; then
      xrandr --output "$output" --scale "$scale_factor"
      local exit_code=$?
      if [ "$exit_code" -ne 0 ]; then
          log "ERROR" "Failed to apply scale $scale_factor. xrandr exit code: $exit_code." >&2
          return 1
      fi
    else
      log "DRYRUN" "xrandr --output \"$output\" --scale \"$scale_factor\""
    fi

    log "DEBUG" "xrandr command succeeded." >&2
    return 0
}

# ==============================================================================
# 🧪 Test Functions
# ==============================================================================

run_tests() {
    log "INFO" "Running internal unit tests..."
    local failures=0

    local input="1.8182x1.8182"
    local expected="1.8182"
    local actual=$(normalize_scale "$input")
    if [ "$actual" == "$expected" ]; then
        log "DEBUG" "TEST 1 (Pure - normalize_scale): PASS"
    else
        log "ERROR" "TEST 1 (Pure - normalize_scale): FAIL (Expected: $expected, Got: $actual)"
        failures=$((failures + 1))
    fi

    local current_x="1.333298"
    local target_x="1.3333"
    local diff_check=$(echo "scale=5; diff = $current_x - $target_x; if (diff < 0) diff = -diff; if (diff < 0.0001) print 1 else print 0" | bc)

    if [ "$diff_check" -eq 1 ]; then
        log "DEBUG" "TEST 2 (Pure - Float comparison): PASS"
    else
        log "ERROR" "TEST 2 (Pure - Float comparison): FAIL"
        failures=$((failures + 1))
    fi

    log "INFO" "Tests complete. Total Failures: $failures"

    if [ "$failures" -gt 0 ]; then
        return 1
    fi
    return 0
}

# ==============================================================================
# 🎯 Core Logic Functions
# ==============================================================================

handle_scale() {
    log "VERBOSE" "Begin handle_scale()"
    local zoom_level="$1"
    log "DEBUG" "zoom_level: ${zoom_level}"
    local target_scale="${SCALE_FACTORS[$zoom_level]}"

    log "VERBOSE" "Check scale level"
    if [ -z "$target_scale" ]; then
        log "ERROR" "Invalid scale level '$zoom_level'. Use 75, 55, or 0."
        print_usage
        exit 1
    fi

    log "VERBOSE" "Detect video output"
    local output
    output=$(detect_output)
    if [ $? -ne 0 ]; then exit 1; fi

    log "VERBOSE" "Do set the scaling"
    set_scale "$output" "$target_scale"
    if [ $? -ne 0 ]; then exit 1; fi

    log "VERBOSE" "End handle_scale()"
}

handle_toggle() {
    local zoom_level="$1"
    local target_scale="${SCALE_FACTORS[$zoom_level]}"

    if [ -z "$target_scale" ] || [ "$zoom_level" == "0" ]; then
        log "ERROR" "Invalid toggle level '$zoom_level'. Use 75 or 55."
        print_usage
        exit 1
    fi

    local output
    output=$(detect_output)
    if [ $? -ne 0 ]; then exit 1; fi

    local current_x_scale
    current_x_scale=$(get_current_scale "$output")
    if [ $? -ne 0 ]; then exit 1; fi

    local target_x_scale
    target_x_scale=$(normalize_scale "$target_scale")

    local is_target
    is_target=$(echo "scale=5; diff = $current_x_scale - $target_x_scale; if (diff < 0) diff = -diff; if (diff < 0.0001) print 1 else print 0" | bc)

    if [ "$is_target" -eq 1 ]; then
        log "INFO" "Target zoom ($target_x_scale) detected. Toggling to Normal ($NORMAL_SCALE)."
        set_scale "$output" "$NORMAL_SCALE"
    else
        log "INFO" "Current scale is $current_x_scale. Toggling to target zoom ($target_scale)."
        set_scale "$output" "$target_scale"
    fi

    if [ $? -ne 0 ]; then exit 1; fi
}

handle_reset() {
    local output
    output=$(detect_output)
    if [ $? -ne 0 ]; then exit 1; fi

    set_scale "$output" "$NORMAL_SCALE"
    if [ $? -ne 0 ]; then exit 1; fi
}

# ==============================================================================
# ❓ Help and Usage Functions
# ==============================================================================

print_help() {
cat << EOF
Usage: $SCRIPT_NAME [OPTIONS] <COMMAND>

DESCRIPTION:
  Manages display scaling (zoom-out) using xrandr.
  Automatically detects connected display output and current scale.

OPTIONS (can be placed anywhere in the command):
  --verbose     Show execution steps and output detection
  --debug       Show verbose output plus low-level command details
  --dryrun      Do not run the actual command, just print it
  --help        Display this help message
  --version     Display the script version

COMMANDS:
  --scale <level>     Set display to specific scale
                      Levels: 75 (75% visual size, 1.3333x scale)
                              55 (55% visual size, 1.8182x scale)
                              0  (100% visual size, reset to 1x1)

  --toggle <level>    Toggle between target scale and normal (1x1)
                      Levels: 75 or 55

  --reset             Reset display to normal scale (1x1)
                      Equivalent to: --scale 0

  --test              Run internal unit tests

EXAMPLES:
  # Set scale to 75% visual size
  $SCRIPT_NAME --scale 75

  # Set with verbose output (flags can be anywhere)
  $SCRIPT_NAME --verbose --scale 75
  $SCRIPT_NAME --scale 75 --verbose

  # Toggle between 55% and 100%
  $SCRIPT_NAME --toggle 55

  # Debug mode with toggle
  $SCRIPT_NAME --debug --toggle 75

  # Reset to normal
  $SCRIPT_NAME --reset
  $SCRIPT_NAME --scale 0

  # Run tests with debug output
  $SCRIPT_NAME --test --debug

SCALE FACTOR EXPLANATION:
  Visual Size    Scale Factor    Description
  ───────────    ────────────    ───────────
  100% (Normal)  1x1             No zoom (default)
  75%            1.3333x1.3333   Zoom out (see more content)
  55%            1.8182x1.8182   Zoom out more (maximum)

NOTE:
  Scale factors are applied using xrandr's Transform property.
  All commands require a connected display output.

EOF
}

print_usage() {
    echo "Usage: $SCRIPT_NAME [--verbose|--debug] --scale <level> | --toggle <level> | --reset | --help"
}

# ==============================================================================
# 🔍 Argument Parsing Function (2-Pass Strategy)
# ==============================================================================

parse_arguments() {
    # Pass 1: Extract ALL flags and commands in one loop
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --verbose)
                VERBOSE=1
                shift
                ;;
            --debug)
                DEBUG=1
                VERBOSE=1
                shift
                ;;
            --dryrun)
                DRYRUN=1
                shift
                ;;
            --version)
                COMMAND="version"
                shift
                ;;
            --help)
                COMMAND="help"
                shift
                ;;
            --test)
                COMMAND="test"
                shift
                ;;
            --reset)
                COMMAND="reset"
                shift
                ;;
            --scale)
                COMMAND="scale"
                shift
                if [ "$#" -gt 0 ] && [[ "$1" =~ ^[0-9]+$ ]]; then
                    SCALE_LEVEL="$1"
                    shift
                else
                    log "ERROR" "--scale requires a level argument (75, 55, or 0)"
                    print_usage
                    exit 1
                fi
                ;;
            --toggle)
                COMMAND="toggle"
                shift
                if [ "$#" -gt 0 ] && [[ "$1" =~ ^[0-9]+$ ]]; then
                    SCALE_LEVEL="$1"
                    shift
                else
                    log "ERROR" "--toggle requires a level argument (75 or 55)"
                    print_usage
                    exit 1
                fi
                ;;
            *)
                log "ERROR" "Unknown argument: $1"
                print_usage
                exit 1
                ;;
        esac
    done

    # Validation
    if [ -z "$COMMAND" ]; then
        log "ERROR" "No command specified"
        print_usage
        exit 1
    fi
}

# ==============================================================================
# ⚙️ Main Execution
# ==============================================================================

if [ "$#" -eq 0 ]; then
    print_usage
    exit 1
fi

# PHASE 1: Parse all arguments (order-independent)
parse_arguments "$@"

# PHASE 2: Enforce immutability
readonly VERBOSE
readonly DEBUG
readonly DRYRUN
readonly COMMAND
readonly SCALE_LEVEL

log "DEBUG" "Parsed - Command: $COMMAND, Level: $SCALE_LEVEL, Verbose: $VERBOSE, Debug: $DEBUG"

# PHASE 3: Execute command based on parsed data
case "$COMMAND" in
    version)
        echo "$SCRIPT_NAME version $SCRIPT_VERSION"
        exit 0
        ;;
    help)
        print_help
        exit 0
        ;;
    test)
        run_tests
        exit $?
        ;;
    reset)
        handle_reset
        ;;
    scale)
        handle_scale "$SCALE_LEVEL"
        ;;
    toggle)
        handle_toggle "$SCALE_LEVEL"
        ;;
    *)
        log "ERROR" "Internal error: Unknown command '$COMMAND'"
        exit 1
        ;;
esac

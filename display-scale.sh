#!/usr/bin/env bash

# Script: display-scale.sh
# Version: 9.0.0 (Dynamic scale calculation with pure functions)
# Description: Toggles or sets display scale (zoom-out) using xrandr.

# --- Configuration (Pure Data - Immutable) ---
readonly SCRIPT_VERSION="9.0.0"
readonly SCRIPT_NAME=$(basename "$0")
readonly NORMAL_SCALE="1x1"
readonly NORMAL_SCALE_FLOAT="1.0"

# Validation ranges
readonly MIN_VISUAL_SIZE=10   # Minimum 10% visual size
readonly MAX_VISUAL_SIZE=100  # Maximum 100% visual size (normal)

# --- Globals (Mutable during parsing, then Immutable) ---
VERBOSE=0
DEBUG=0
DRYRUN=0
COMMAND=""      # Will store: "scale", "toggle", "reset", "test", "help", "version"
SCALE_LEVEL=""  # Will store: any integer 10-100

# ==============================================================================
#  ✨ Pure Utility Functions
# (Deterministic, No Side Effects, Referentially Transparent)
# ==============================================================================

# Pure Function: log
# Takes log level and message, outputs to stderr based on current verbosity
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
        echo "[DRYRUN] $message" >&2
    fi
}

# Pure Function: calculate_scale_factor
# Input: Visual size percentage (integer 10-100)
# Output: Scale factor as "XxY" string (e.g., "1.3333x1.3333")
# Formula: scale = 100 / visual_size_percentage
#
# Uses 'bc' for floating-point arithmetic:
#   bc -l : Load math library for floating point
#   scale=4 : Use 4 decimal places for precision
calculate_scale_factor() {
    local visual_size="$1"

    # Handle special case: 100% = exactly 1x1
    if [ "$visual_size" -eq 100 ]; then
        echo "$NORMAL_SCALE"
        return 0
    fi

    # Calculate: scale = 100 / visual_size
    # bc is used for floating-point division
    local scale_value
    scale_value=$(echo "scale=4; 100 / $visual_size" | bc)

    # Format as "XxY" (e.g., "1.3333x1.3333")
    echo "${scale_value}x${scale_value}"
}

# Pure Function: validate_visual_size
# Input: Visual size percentage (any value)
# Output: 0 if valid, 1 if invalid
# Side effect: Logs error message if invalid
validate_visual_size() {
    local visual_size="$1"

    # Check if it's a number
    if ! [[ "$visual_size" =~ ^[0-9]+$ ]]; then
        log "ERROR" "Scale level must be an integer, got: '$visual_size'"
        return 1
    fi

    # Check range
    if [ "$visual_size" -lt "$MIN_VISUAL_SIZE" ] || [ "$visual_size" -gt "$MAX_VISUAL_SIZE" ]; then
        log "ERROR" "Scale level must be between $MIN_VISUAL_SIZE and $MAX_VISUAL_SIZE, got: $visual_size"
        return 1
    fi

    return 0
}

# Pure Function: normalize_scale
# Input: Scale factor string (e.g., "1.3333x1.3333")
# Output: The X-scale float (e.g., "1.3333") printed to stdout
normalize_scale() {
    local scale_factor="$1"
    echo "$scale_factor" | cut -d 'x' -f 1
}

# Pure Function: build_xrandr_command
# Input: output name, scale factor
# Output: The complete xrandr command string
# This is PURE - it only builds a string, doesn't execute anything
build_xrandr_command() {
    local output="$1"
    local scale_factor="$2"
    echo "xrandr --output \"$output\" --scale \"$scale_factor\""
}

# ==============================================================================
# ☔ Impure I/O Functions (Maybe/Either Principle)
# (Signal success/failure via exit code 0/non-zero)
# ==============================================================================

# Impure Function: detect_output
# Output: Output name (e.g., DVI-I-1) printed to stdout on success.
detect_output() {
    log "VERBOSE" "Detect video output"
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
# This function respects DRYRUN mode
# If DRYRUN=1: Only print what would be executed
# If DRYRUN=0: Execute the command
set_scale() {
    local output="$1"
    local scale_factor="$2"

    log "INFO" "Applying scale $scale_factor to $output." >&2

    # Build the command (pure operation)
    local cmd
    cmd=$(build_xrandr_command "$output" "$scale_factor")

    # Execute or simulate based on DRYRUN flag
    if [ "$DRYRUN" -eq 1 ]; then
        log "DRYRUN" "$cmd"
        log "DEBUG" "xrandr command succeeded (simulated)." >&2
        return 0
    else
        # Actually execute the command
        xrandr --output "$output" --scale "$scale_factor"
        local exit_code=$?

        if [ "$exit_code" -ne 0 ]; then
            log "ERROR" "Failed to apply scale $scale_factor. xrandr exit code: $exit_code." >&2
            return 1
        fi
        log "DEBUG" "xrandr command succeeded." >&2
        return 0
    fi
}

# ==============================================================================
# 🧪 Test Functions
# ==============================================================================

run_tests() {
    log "INFO" "Running internal unit tests..."
    local failures=0

    # Test 1: calculate_scale_factor for 75%
    local expected="1.3333x1.3333"
    local actual=$(calculate_scale_factor 75)
    if [ "$actual" == "$expected" ]; then
        log "DEBUG" "TEST 1 (Pure - calculate_scale_factor 75): PASS"
    else
        log "ERROR" "TEST 1 (Pure - calculate_scale_factor 75): FAIL (Expected: $expected, Got: $actual)"
        failures=$((failures + 1))
    fi

    # Test 2: calculate_scale_factor for 100%
    expected="1x1"
    actual=$(calculate_scale_factor 100)
    if [ "$actual" == "$expected" ]; then
        log "DEBUG" "TEST 2 (Pure - calculate_scale_factor 100): PASS"
    else
        log "ERROR" "TEST 2 (Pure - calculate_scale_factor 100): FAIL (Expected: $expected, Got: $actual)"
        failures=$((failures + 1))
    fi

    # Test 3: calculate_scale_factor for 80%
    expected="1.2500x1.2500"
    actual=$(calculate_scale_factor 80)
    if [ "$actual" == "$expected" ]; then
        log "DEBUG" "TEST 3 (Pure - calculate_scale_factor 80): PASS"
    else
        log "ERROR" "TEST 3 (Pure - calculate_scale_factor 80): FAIL (Expected: $expected, Got: $actual)"
        failures=$((failures + 1))
    fi

    # Test 4: calculate_scale_factor for 50%
    expected="2.0000x2.0000"
    actual=$(calculate_scale_factor 50)
    if [ "$actual" == "$expected" ]; then
        log "DEBUG" "TEST 4 (Pure - calculate_scale_factor 50): PASS"
    else
        log "ERROR" "TEST 4 (Pure - calculate_scale_factor 50): FAIL (Expected: $expected, Got: $actual)"
        failures=$((failures + 1))
    fi

    # Test 5: normalize_scale (Pure)
    local input="1.8182x1.8182"
    expected="1.8182"
    actual=$(normalize_scale "$input")
    if [ "$actual" == "$expected" ]; then
        log "DEBUG" "TEST 5 (Pure - normalize_scale): PASS"
    else
        log "ERROR" "TEST 5 (Pure - normalize_scale): FAIL (Expected: $expected, Got: $actual)"
        failures=$((failures + 1))
    fi

    # Test 6: Float Comparison Check (Pure)
    local current_x="1.333298"
    local target_x="1.3333"
    local diff_check=$(echo "scale=5; diff = $current_x - $target_x; if (diff < 0) diff = -diff; if (diff < 0.0001) print 1 else print 0" | bc)

    if [ "$diff_check" -eq 1 ]; then
        log "DEBUG" "TEST 6 (Pure - Float comparison): PASS"
    else
        log "ERROR" "TEST 6 (Pure - Float comparison): FAIL"
        failures=$((failures + 1))
    fi

    # Test 7: build_xrandr_command (Pure)
    local expected_cmd='xrandr --output "DVI-I-1" --scale "1.3333x1.3333"'
    local actual_cmd=$(build_xrandr_command "DVI-I-1" "1.3333x1.3333")
    if [ "$actual_cmd" == "$expected_cmd" ]; then
        log "DEBUG" "TEST 7 (Pure - build_xrandr_command): PASS"
    else
        log "ERROR" "TEST 7 (Pure - build_xrandr_command): FAIL"
        log "ERROR" "  Expected: $expected_cmd"
        log "ERROR" "  Got:      $actual_cmd"
        failures=$((failures + 1))
    fi

    # Test 8: validate_visual_size - valid cases
    if validate_visual_size 75 >/dev/null 2>&1 && \
       validate_visual_size 100 >/dev/null 2>&1 && \
       validate_visual_size 10 >/dev/null 2>&1; then
        log "DEBUG" "TEST 8 (Pure - validate_visual_size valid): PASS"
    else
        log "ERROR" "TEST 8 (Pure - validate_visual_size valid): FAIL"
        failures=$((failures + 1))
    fi

    # Test 9: validate_visual_size - invalid cases
    if ! validate_visual_size 9 >/dev/null 2>&1 && \
       ! validate_visual_size 101 >/dev/null 2>&1 && \
       ! validate_visual_size "abc" >/dev/null 2>&1; then
        log "DEBUG" "TEST 9 (Pure - validate_visual_size invalid): PASS"
    else
        log "ERROR" "TEST 9 (Pure - validate_visual_size invalid): FAIL"
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
    log "DEBUG" "visual_size: $1"

    local visual_size="$1"

    log "VERBOSE" "Validate scale level"
    if ! validate_visual_size "$visual_size"; then
        print_usage
        exit 1
    fi

    log "VERBOSE" "Calculate scale factor"
    local target_scale
    target_scale=$(calculate_scale_factor "$visual_size")
    log "DEBUG" "Calculated scale factor: $target_scale"

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
    log "VERBOSE" "Begin handle_toggle()"
    log "DEBUG" "visual_size: $1"

    local visual_size="$1"

    log "VERBOSE" "Validate toggle level"
    if ! validate_visual_size "$visual_size"; then
        print_usage
        exit 1
    fi

    # Cannot toggle with 100 (normal)
    if [ "$visual_size" -eq 100 ]; then
        log "ERROR" "Cannot toggle with 100% (normal scale). Use a value < 100."
        print_usage
        exit 1
    fi

    log "VERBOSE" "Calculate target scale factor"
    local target_scale
    target_scale=$(calculate_scale_factor "$visual_size")
    log "DEBUG" "Calculated target scale: $target_scale"

    log "VERBOSE" "Detect video output"
    local output
    output=$(detect_output)
    if [ $? -ne 0 ]; then exit 1; fi

    log "VERBOSE" "Get current scale"
    local current_x_scale
    current_x_scale=$(get_current_scale "$output")
    if [ $? -ne 0 ]; then exit 1; fi

    local target_x_scale
    target_x_scale=$(normalize_scale "$target_scale")

    log "VERBOSE" "Compare current vs target scale"
    local is_target
    is_target=$(echo "scale=5; diff = $current_x_scale - $target_x_scale; if (diff < 0) diff = -diff; if (diff < 0.0001) print 1 else print 0" | bc)

    log "VERBOSE" "Do toggle the scaling"
    if [ "$is_target" -eq 1 ]; then
        log "INFO" "Target zoom ($target_x_scale) detected. Toggling to Normal ($NORMAL_SCALE)."
        set_scale "$output" "$NORMAL_SCALE"
    else
        log "INFO" "Current scale is $current_x_scale. Toggling to target zoom ($target_scale)."
        set_scale "$output" "$target_scale"
    fi

    if [ $? -ne 0 ]; then exit 1; fi

    log "VERBOSE" "End handle_toggle()"
}

handle_reset() {
    log "VERBOSE" "Begin handle_reset()"

    log "VERBOSE" "Detect video output"
    local output
    output=$(detect_output)
    if [ $? -ne 0 ]; then exit 1; fi

    log "VERBOSE" "Do reset the scaling"
    set_scale "$output" "$NORMAL_SCALE"
    if [ $? -ne 0 ]; then exit 1; fi

    log "VERBOSE" "End handle_reset()"
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
  Dynamically calculates scale factors for any visual size percentage.

OPTIONS (can be placed anywhere in the command):
  --verbose     Show execution steps and output detection
  --debug       Show verbose output plus low-level command details
  --dryrun      Simulate execution without actually running xrandr
  --help        Display this help message
  --version     Display the script version

COMMANDS:
  --scale <level>     Set display to specific visual size percentage
                      Level: Any integer from $MIN_VISUAL_SIZE to $MAX_VISUAL_SIZE
                      Examples: 75, 80, 85, 90, 95, 98, 100

                      Formula: scale_factor = 100 / visual_size

  --toggle <level>    Toggle between target scale and normal (1x1)
                      Level: Any integer from $MIN_VISUAL_SIZE to 99
                      (Cannot toggle with 100)

  --reset             Reset display to normal scale (1x1)
                      Equivalent to: --scale 100

  --test              Run internal unit tests

EXAMPLES:
  # Set to 75% visual size (zoom out)
  $SCRIPT_NAME --scale 75

  # Set to 80% visual size
  $SCRIPT_NAME --scale 80

  # Set to 95% visual size (slight zoom)
  $SCRIPT_NAME --scale 95

  # Reset to normal (100%)
  $SCRIPT_NAME --scale 100
  $SCRIPT_NAME --reset

  # Toggle between 85% and 100%
  $SCRIPT_NAME --toggle 85

  # Simulate without executing
  $SCRIPT_NAME --dryrun --scale 90

  # With verbose output (flags can be anywhere)
  $SCRIPT_NAME --verbose --scale 75
  $SCRIPT_NAME --scale 75 --verbose --debug

  # Run tests
  $SCRIPT_NAME --test --debug

SCALE FACTOR CALCULATION:
  Visual Size    Formula         Scale Factor    Description
  ───────────    ──────────      ────────────    ───────────
  100%           100/100         1.0000x1.0000   Normal (no zoom)
  98%            100/98          1.0204x1.0204   Very slight zoom
  95%            100/95          1.0526x1.0526   Slight zoom
  90%            100/90          1.1111x1.1111   Moderate zoom
  85%            100/85          1.1765x1.1765   Moderate zoom
  80%            100/80          1.2500x1.2500   Noticeable zoom
  75%            100/75          1.3333x1.3333   Strong zoom
  55%            100/55          1.8182x1.8182   Very strong zoom
  50%            100/50          2.0000x2.0000   Maximum zoom (2x)

DRYRUN MODE:
  When --dryrun is specified, the script will:
  - Parse all arguments normally
  - Calculate scale factors
  - Show what command WOULD be executed
  - NOT actually execute xrandr
  - Useful for testing and verification

NOTE:
  - Scale factors are calculated dynamically using pure functions
  - All calculations use 4 decimal places for precision
  - Scales are applied using xrandr's Transform property
  - All commands require a connected display output

EOF
}

print_usage() {
    echo "Usage: $SCRIPT_NAME [--verbose|--debug|--dryrun] --scale <$MIN_VISUAL_SIZE-$MAX_VISUAL_SIZE> | --toggle <$MIN_VISUAL_SIZE-99> | --reset | --help"
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
                if [ "$#" -gt 0 ]; then
                    SCALE_LEVEL="$1"
                    shift
                else
                    log "ERROR" "--scale requires a level argument ($MIN_VISUAL_SIZE-$MAX_VISUAL_SIZE)"
                    print_usage
                    exit 1
                fi
                ;;
            --toggle)
                COMMAND="toggle"
                shift
                if [ "$#" -gt 0 ]; then
                    SCALE_LEVEL="$1"
                    shift
                else
                    log "ERROR" "--toggle requires a level argument ($MIN_VISUAL_SIZE-99)"
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

log "DEBUG" "Parsed - Command: $COMMAND, Level: $SCALE_LEVEL, Verbose: $VERBOSE, Debug: $DEBUG, Dryrun: $DRYRUN"

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

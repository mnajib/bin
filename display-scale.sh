#!/usr/bin/env bash

# Script: display-scale.sh
# Description: Toggles or sets display scale (zoom-out) using xrandr.
# Detects current scale from xrandr's transform property to enable intelligent toggling.

SCRIPT_VERSION="3.0.0"
SCRIPT_NAME=$(basename "$0")

# --- Configuration ---
NORMAL_SCALE="1x1"
NORMAL_SCALE_FLOAT="1.0"

declare -A SCALE_FACTORS=(
    ["75"]="1.3333x1.3333" # 75% visual size (1 / 0.75 ≈ 1.3333)
    ["55"]="1.8182x1.8182" # 55% visual size (1 / 0.55 ≈ 1.8182)
    ["0"]="$NORMAL_SCALE"  # 100% visual size (Reset/Normal)
)

# --- Globals for Verbosity and Debugging ---
VERBOSE=0
DEBUG=0

# --- Utility Functions ---

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
    fi
}

# Function to automatically detect the primary connected display output
detect_output() {
    local output
    # Find the output name that is currently 'connected'
    output=$(xrandr | awk '/ connected / {print $1; exit}')
    
    if [ -z "$output" ]; then
        log "ERROR" "No connected display output found. Exiting."
        exit 1
    fi
    echo "$output"
}

# Function to get the current scale factor from xrandr transform matrix
# NEW AND IMPROVED LOGIC
get_current_scale() {
    local output_name="$1"
    local scale

    # Use awk to find the Transform line for the specific output and extract the 
    # first number on the line immediately following the "Transform:" line.
    scale=$(xrandr --verbose | awk '
        # Check if we are inside the section for the target output
        /^'"$output_name"'/ { in_output=1; next } 
        
        # If we see another output, stop looking
        /^[A-Z0-9_-]+ connected/ { in_output=0 } 
        
        # If we are in the right section and see the "Transform:" line
        in_output && /Transform:/ { 
            # The scale factor is on the NEXT line, which starts with whitespace.
            # Read the next line, then print the FIRST field (the X-scale factor) and exit.
            getline; 
            print $1; 
            exit 
        }
        # Fallback if Transform is on the same line (less common)
        in_output && /Transform: ([0-9.]+)/ { print $2; exit }
    ')
    
    # If the scale is empty, assume 1.0 (Normal)
    if [ -z "$scale" ]; then
        log "DEBUG" "Scale detection failed. Assuming 1.0"
        scale="$NORMAL_SCALE_FLOAT"
    fi
    echo "$scale"
}

# Function to set the display scale using xrandr
set_scale() {
    local output="$1"
    local scale_factor="$2"
    log "INFO" "Applying scale $scale_factor to $output."
    xrandr --output "$output" --scale "$scale_factor"
    
    if [ $? -ne 0 ]; then
        log "ERROR" "Failed to apply scale $scale_factor. Check xrandr permissions."
        exit 1
    fi
}

# --- Core Logic Functions ---

# Helper to normalize scale factors for comparison
normalize_scale() {
    local scale_factor="$1"
    # Extracts the X-scale part (e.g., 1.3333x1.3333 becomes 1.3333)
    echo "$scale_factor" | cut -d 'x' -f 1
}

# Handles setting a specific scale (e.g., ./display-scale.sh 75)
handle_set() {
    local zoom_level="$1"
    local target_scale="${SCALE_FACTORS[$zoom_level]}"
    
    if [ -z "$target_scale" ]; then
        log "ERROR" "Invalid scale level '$zoom_level'. Use 75, 55, or 0."
        print_usage
        exit 1
    fi

    local output=$(detect_output)
    set_scale "$output" "$target_scale"
}

# Handles toggling between a target scale and 1x1 (e.g., ./display-scale.sh --toggle 75)
handle_toggle() {
    local zoom_level="$1"
    local target_scale="${SCALE_FACTORS[$zoom_level]}"

    if [ -z "$target_scale" ] || [ "$zoom_level" == "0" ]; then
        log "ERROR" "Invalid toggle level '$zoom_level'. Use 75 or 55."
        print_usage
        exit 1
    fi
    
    local output=$(detect_output)
    local current_x_scale=$(get_current_scale "$output")
    local target_x_scale=$(normalize_scale "$target_scale")
    
    # Use 'bc' for precise float comparison
    # We check if the current scale is "close enough" to the target scale
    # To avoid floating point issues, check if the absolute difference is small (e.g., < 0.0001)
    
    is_target=$(echo "scale=5; diff = $current_x_scale - $target_x_scale; if (diff < 0) diff = -diff; if (diff < 0.0001) print 1 else print 0" | bc)

    if [ "$is_target" -eq 1 ]; then
        # Currently set to the target zoom, toggle to Normal
        log "INFO" "Target zoom ($target_x_scale) detected. Toggling to Normal ($NORMAL_SCALE)."
        set_scale "$output" "$NORMAL_SCALE"
    else
        # Not currently set to the target zoom, toggle to target zoom
        log "INFO" "Current scale is $current_x_scale. Toggling to target zoom ($target_scale)."
        set_scale "$output" "$target_scale"
    fi
}

# Handles the --reset flag
handle_reset() {
    local output=$(detect_output)
    set_scale "$output" "$NORMAL_SCALE"
}

# --- Help and Usage (omitted for brevity, assume unchanged) ---
print_help() {
    echo ""
    echo "Usage: $SCRIPT_NAME <level> | --toggle <level> | --reset | --help | --version"
    echo ""
    echo "This script manages display scaling (zoom-out) using xrandr."
    echo "It automatically detects the connected display output and current scale."
    echo ""
    echo "--- Set Mode (Applies scale immediately) ---"
    echo "  $SCRIPT_NAME 75       -> Sets display to 75% visual size (Scale: 1.3333x1.3333)"
    echo "  $SCRIPT_NAME 55       -> Sets display to 55% visual size (Scale: 1.8182x1.8182)"
    echo "  $SCRIPT_NAME 0        -> Sets display to 100% visual size (Reset: 1x1)"
    echo ""
    echo "--- Toggle Mode ---"
    echo "  $SCRIPT_NAME --toggle 75   -> Toggles between 75% visual size and 100% (Normal)"
    echo "  $SCRIPT_NAME --toggle 55   -> Toggles between 55% visual size and 100% (Normal)"
    echo ""
    echo "--- Utility Flags ---"
    echo "  $SCRIPT_NAME --reset       -> Alias for setting the scale to 1x1."
    echo "  $SCRIPT_NAME --verbose     -> Show execution steps and output detection."
    echo "  $SCRIPT_NAME --debug       -> Show verbose output plus low-level command details."
    echo "  $SCRIPT_NAME --help        -> Display this help message."
    echo "  $SCRIPT_NAME --version     -> Display the script version."
    echo ""
}

print_usage() {
    echo "Usage: $SCRIPT_NAME <level> | --toggle <level> | --reset | --help"
}
# --- Main Execution ---

if [ "$#" -eq 0 ]; then
    print_usage
    exit 1
fi

while [ "$#" -gt 0 ]; do
    case "$1" in
        --verbose) VERBOSE=1; shift ;;
        --debug) VERBOSE=1; DEBUG=1; shift ;;
        --version) echo "$SCRIPT_NAME version $SCRIPT_VERSION"; exit 0 ;;
        --help) print_help; exit 0 ;;
        -*) break ;;
        *) break ;;
    esac
done

case "$1" in
    --help)
        print_help
        exit 0
        ;;
    --toggle)
        shift
        handle_toggle "$1"
        ;;
    --reset)
        handle_reset
        ;;
    75|55|0)
        handle_set "$1"
        ;;
    *)
        log "ERROR" "Unknown command or level: $1"
        print_usage
        exit 1
        ;;
esac

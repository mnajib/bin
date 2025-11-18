#!/usr/bin/env bash

# --- Configuration ---
ZOOM_SCALE="1.3333x1.3333"
NORMAL_SCALE="1x1"

# --- 1. Detect Active Output ---
# This command finds the output name (e.g., DVI-I-1) that is currently 'connected'
# and extracts the name before the word 'connected'.
OUTPUT_NAME=$(xrandr | awk '/ connected / {print $1; exit}')

if [ -z "$OUTPUT_NAME" ]; then
    echo "Error: No connected display output found. Exiting."
    exit 1
fi

echo "Detected active display: $OUTPUT_NAME"

# --- 2. Get Current Scaling ---
# xrandr doesn't expose the scale directly, but the effective resolution changes
# when scale is applied. The best way to check the current scale is to use
# the 'grep' on the output of 'xrandr --verbose' looking for the 'Transform' property.

CURRENT_SCALE=$(xrandr --verbose | awk "/^$OUTPUT_NAME/ {p=1} p && /Transform/ {print \$NF; exit}")

# xrandr --verbose output for scale 1.3333x1.3333 looks like:
# Transform: 1.333333 0.000000 0.000000
#            0.000000 1.333333 0.000000
#            0.000000 0.000000 1.000000
# We only check the first value of the transform matrix (the X-scale factor)

# We check if the first transform value is greater than 1.0 (indicating zoom)
# We use 'bc' for floating-point comparison.

if [ "$(echo "$CURRENT_SCALE > 1.0" | bc)" -eq 1 ]; then

    # Current scale is > 1.0 (Zoomed out), so we set it to Normal (1x1)
    echo "Current scale is $CURRENT_SCALE (Zoomed Out). Setting to Normal ($NORMAL_SCALE)."
    xrandr --output "$OUTPUT_NAME" --scale "$NORMAL_SCALE"

else

    # Current scale is 1.0 (Normal), so we set it to Zoomed Out (1.3333x1.3333)
    echo "Current scale is Normal ($CURRENT_SCALE). Setting to Zoomed Out ($ZOOM_SCALE)."
    xrandr --output "$OUTPUT_NAME" --scale "$ZOOM_SCALE"

fi

echo "Scale toggled successfully."

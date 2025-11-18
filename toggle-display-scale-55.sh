#!/usr/bin/env bash

# --- Configuration ---
# 55% visual size requires a scale factor of 1 / 0.55 ≈ 1.8182
ZOOM_SCALE="1.8182x1.8182"
NORMAL_SCALE="1x1"

# --- 1. Detect Active Output ---
# Finds the output name (e.g., DVI-I-1) that is currently 'connected'
OUTPUT_NAME=$(xrandr | awk '/ connected / {print $1; exit}')

if [ -z "$OUTPUT_NAME" ]; then
    echo "Error: No connected display output found. Exiting."
    exit 1
fi

echo "Detected active display: $OUTPUT_NAME"

# --- 2. Get Current Scaling ---
# Checks the 'Transform' property in xrandr --verbose output for the current scale factor.
CURRENT_SCALE=$(xrandr --verbose | awk "/^$OUTPUT_NAME/ {p=1} p && /Transform/ {print \$NF; exit}")

# --- 3. Toggle Logic ---
# We check if the current scale factor is greater than 1.0.
# Note: Since the $75\% script sets 1.3333 and this script targets 1.8182,
# both are greater than 1.0. This script will simply toggle to 1x1 if *any* zoom
# is currently applied, and apply 1.8182x1.8182 if currently 1x1.

if [ "$(echo "$CURRENT_SCALE > 1.0" | bc)" -eq 1 ]; then

    # Current scale is > 1.0 (Zoomed Out), so we set it to Normal (1x1)
    echo "Current scale is $CURRENT_SCALE (Zoomed Out). Setting to Normal ($NORMAL_SCALE)."
    xrandr --output "$OUTPUT_NAME" --scale "$NORMAL_SCALE"

else

    # Current scale is 1.0 (Normal), so we set it to Zoomed Out (1.8182x1.8182)
    echo "Current scale is Normal ($CURRENT_SCALE). Setting to Zoomed Out ($ZOOM_SCALE)."
    xrandr --output "$OUTPUT_NAME" --scale "$ZOOM_SCALE"

fi

echo "Scale toggled successfully."

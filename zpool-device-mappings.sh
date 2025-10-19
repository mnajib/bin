#!/usr/bin/env bash

##############################################################################
# ZPool Device Mapper
# 
# Description: Display ZFS pool information with detailed device mappings
#              including drive paths, by-id paths, and UUIDs.
# 
# Usage: ./zpool-device-mappings.sh
# 
# Features:
# - Pure functions for predictable behavior
# - Comprehensive error handling
# - Detailed logging and debugging
# - Self-contained testing
# - Immutable data flow
##############################################################################

set -euo pipefail

# Global constants
readonly SCRIPT_NAME="zpool-device-mappings.sh"
readonly VERSION="1.0.0"
readonly LOG_PREFIX="[ZPOOL-MAP]"

##############################################################################
# Logging Utilities
##############################################################################

# Log an info message
# @param $1: Message to log
log_info() {
    echo "${LOG_PREFIX} INFO: $1" >&2
}

# Log a warning message
# @param $1: Message to log
log_warn() {
    echo "${LOG_PREFIX} WARN: $1" >&2
}

# Log an error message
# @param $1: Message to log
log_error() {
    echo "${LOG_PREFIX} ERROR: $1" >&2
}

# Log a debug message (only shown when DEBUG=true)
# @param $1: Message to log
log_debug() {
    [[ "${DEBUG:-false}" == "true" ]] && echo "${LOG_PREFIX} DEBUG: $1" >&2
    return 0
}

##############################################################################
# Error Handling Monad-like Utilities
##############################################################################

# Result type: either Success(value) or Error(message)
# We simulate this using strings with prefixes

# Create a success result
# @param $1: Success value
# @output: Success:value
result_success() {
    echo "SUCCESS:$1"
}

# Create an error result  
# @param $1: Error message
# @output: ERROR:$1
result_error() {
    echo "ERROR:$1"
}

# Check if result is success
# @param $1: Result string
# @return: 0 if success, 1 if error
result_is_success() {
    [[ "$1" == SUCCESS:* ]]
}

# Check if result is error
# @param $1: Result string
# @return: 0 if error, 1 if success  
result_is_error() {
    [[ "$1" == ERROR:* ]]
}

# Extract value from success result
# @param $1: Result string
# @output: Extracted value
result_value() {
    echo "${1#SUCCESS:}"
}

# Extract error from error result
# @param $1: Result string  
# @output: Error message
result_error_msg() {
    echo "${1#ERROR:}"
}

# Bind operation for monadic composition
# @param $1: Result from previous operation
# @param $2: Function to apply (must accept one arg and return result)
# @output: New result
result_bind() {
    local result="$1"
    local func="$2"
    
    if result_is_success "$result"; then
        local value
        value=$(result_value "$result")
        $func "$value"
    else
        echo "$result"  # Propagate error
    fi
}

# Try operation with error handling - executes command in subshell
# @param $1: Command to execute
# @param $2: Error message prefix
# @output: Result with output or error
try_cmd() {
    local cmd="$1"
    local error_prefix="$2"
    
    log_debug "Executing: $cmd"
    
    # Use eval to properly handle pipes and redirections in the command string
    if output=$(eval "$cmd" 2>&1); then
        result_success "$output"
    else
        result_error "${error_prefix}: $output"
    fi
}

##############################################################################
# Pure Data Extraction Functions
##############################################################################

# Get ATA drive mappings from /dev/disk/by-id
# This function is PURE - no side effects, depends only on inputs
#
# Usage: get_drive_mappings
#
# Output: 
#   Success: Multiline string with format "by_id_path device_path"
#   Error: Error message
#
# Example output:
#   ata-WDC_WD10EZEX-60WN4A2_WD-WCC6Y4ZJA16T ../../sde
get_drive_mappings() {
    local cmd="ls -l /dev/disk/by-id/ata-* 2>/dev/null | grep -v -- -part | awk '{print \$9 \" \" \$11}' | sort"
    try_cmd "$cmd" "Failed to get ATA drive mappings"
}

# Get SCSI device mappings using lsscsi
# This function is PURE - no side effects
#
# Usage: get_scsi_mappings
#
# Output:
#   Success: Multiline string with format "scsi_id device_path" 
#   Error: Error message
#
# Example output:
#   0:0:0:0 /dev/sda
get_scsi_mappings() {
    if ! command -v lsscsi &> /dev/null; then
        log_warn "lsscsi command not available"
        result_success ""  # lsscsi not available is not an error
        return
    fi
    
    local cmd="lsscsi -g 2>/dev/null | awk '/disk.*ATA/ {gsub(/\\[|\\]/,\"\"); print \$1 \" \" \$(NF-1)}'"
    try_cmd "$cmd" "Failed to get SCSI mappings"
}

# Extract device information from zpool status output - SIMPLE AND EFFECTIVE
# This function is PURE - no side effects
#
# Usage: get_zpool_devices
#
# Output:
#   Success: Multiline string with format "pool_name vdev_name device_id"
#   Error: Error message
#
# Example output:
#   Garden raidz3-0 ata-HUA722010CLA330_43W7625_42C0400IBM_JPW9L0HZ0WN54C
get_zpool_devices() {
    if ! command -v zpool &> /dev/null; then
        result_error "zpool command not available"
        return
    fi
    
    # Get raw zpool status output
    local cmd="zpool status"
    local result
    result=$(try_cmd "$cmd" "Failed to get zpool status")
    
    if result_is_error "$result"; then
        echo "$result"
        return
    fi
    
    local zpool_output
    zpool_output=$(result_value "$result")
    
    log_debug "ZPool status output lines: $(echo "$zpool_output" | wc -l)"
    
    # SIMPLE APPROACH: Extract pool names and devices using grep and basic parsing
    local parsed_devices=""
    local current_pool=""
    local current_vdev="-"
    
    while IFS= read -r line; do
        # Extract pool name
        if [[ "$line" =~ ^[[:space:]]*pool:[[:space:]]+([^[:space:]]+) ]]; then
            current_pool="${BASH_REMATCH[1]}"
            current_vdev="-"
            log_debug "Found pool: $current_pool"
            continue
        fi
        
        # Extract vdev name (raidz, mirror, etc.)
        if [[ "$line" =~ ^[[:space:]]+(raidz[0-9]*-[0-9]+|mirror-[0-9]+|spare|log|cache|special)[[:space:]]+ ]]; then
            current_vdev="${BASH_REMATCH[1]}"
            log_debug "Found vdev: $current_vdev"
            continue
        fi
        
        # Extract device lines (lines containing ata- and ONLINE)
        if [[ "$line" =~ ^[[:space:]]+(ata-[^[:space:]]+)[[:space:]]+ONLINE ]]; then
            local device_id="${BASH_REMATCH[1]}"
            if [[ -n "$current_pool" && -n "$device_id" ]]; then
                parsed_devices+="${current_pool} ${current_vdev} ${device_id}"$'\n'
                log_debug "Found device: $current_pool $current_vdev $device_id"
            fi
            continue
        fi
        
        # For Riyadh pool which has direct devices without vdev
        if [[ "$line" =~ ^[[:space:]]+(ata-[^[:space:]]+-part[0-9]+)[[:space:]]+ONLINE ]] && [[ "$current_pool" == "Riyadh" ]]; then
            local device_id="${BASH_REMATCH[1]}"
            if [[ -n "$current_pool" && -n "$device_id" ]]; then
                parsed_devices+="${current_pool} - ${device_id}"$'\n'
                log_debug "Found Riyadh device: $current_pool - $device_id"
            fi
            continue
        fi
        
    done <<< "$zpool_output"
    
    # Remove trailing newline and trim
    parsed_devices=$(echo "$parsed_devices" | sed '/^[[:space:]]*$/d')
    
    log_debug "Parsed devices count: $(echo "$parsed_devices" | wc -l)"
    if [[ -n "$parsed_devices" ]]; then
        log_debug "Parsed devices:"
        echo "$parsed_devices" | while IFS= read -r line; do
            log_debug "  $line"
        done
    else
        log_debug "No devices parsed from zpool status"
    fi
    
    if [[ -z "$parsed_devices" ]]; then
        result_error "No devices found in zpool status output"
    else
        result_success "$parsed_devices"
    fi
}

# Find UUID for a given device ID
# This function is PURE - no side effects
#
# Usage: get_uuid_for_device "device_id"
#
# Input:
#   $1: Device ID (e.g., "ata-WDC_WD10EZEX-60WN4A2_WD-WCC6Y4ZJA16T")
#
# Output:
#   Success: UUID string or "unknown" if not found
#   Error: Error message
get_uuid_for_device() {
    local device_id="$1"
    local device_path="/dev/disk/by-id/$device_id"
    
    log_debug "Looking up UUID for device: $device_id"
    
    # Check if device exists
    if [[ ! -L "$device_path" ]]; then
        log_debug "Device path not found: $device_path"
        result_success "unknown"
        return
    fi
    
    # Get real device path
    local real_device
    if ! real_device=$(readlink -f "$device_path" 2>/dev/null); then
        log_debug "Failed to resolve device path: $device_path"
        result_success "unknown"
        return
    fi
    
    log_debug "Resolved device: $device_path -> $real_device"
    
    # Search for UUID in by-uuid directory
    local uuid_found="unknown"
    if [[ -d "/dev/disk/by-uuid" ]]; then
        for uuid_link in /dev/disk/by-uuid/*; do
            if [[ -L "$uuid_link" ]]; then
                local uuid_target
                if uuid_target=$(readlink -f "$uuid_link" 2>/dev/null); then
                    if [[ "$uuid_target" == "$real_device" ]]; then
                        uuid_found=$(basename "$uuid_link")
                        log_debug "Found UUID: $uuid_found for device $device_id"
                        break
                    fi
                fi
            fi
        done
    else
        log_debug "/dev/disk/by-uuid directory not found"
    fi
    
    # If UUID is still unknown, try using blkid as fallback
    if [[ "$uuid_found" == "unknown" ]] && command -v blkid &> /dev/null; then
        log_debug "Trying blkid fallback for: $real_device"
        local blkid_output
        if blkid_output=$(blkid "$real_device" 2>/dev/null); then
            if [[ "$blkid_output" =~ UUID=\"([^\"]+)\" ]]; then
                uuid_found="${BASH_REMATCH[1]}"
                log_debug "Found UUID via blkid: $uuid_found"
            fi
        fi
    fi
    
    result_success "$uuid_found"
}

##############################################################################
# Data Processing Functions
##############################################################################

# Build comprehensive drive mapping table from all sources
# This function is PURE - no side effects, deterministic output
#
# Usage: build_drive_mapping_table
#
# Output:
#   Success: Multiline string with format "key:value" for device mappings
#   Error: Error message
build_drive_mapping_table() {
    log_info "Building drive mapping table..."
    
    # Get ATA mappings
    local ata_result
    ata_result=$(get_drive_mappings)
    if result_is_error "$ata_result"; then
        log_warn "ATA mappings unavailable: $(result_error_msg "$ata_result")"
        # Try alternative approach - direct processing
        log_info "Trying alternative ATA mapping approach..."
        ata_result=$(result_success "$(process_ata_mappings_directly)")
    fi
    
    # Get SCSI mappings  
    local scsi_result
    scsi_result=$(get_scsi_mappings)
    if result_is_error "$scsi_result"; then
        log_warn "SCSI mappings unavailable: $(result_error_msg "$scsi_result")"
        scsi_result=$(result_success "")
    fi
    
    # Process ATA mappings
    local -A drive_map
    local ata_mappings
    ata_mappings=$(result_value "$ata_result")
    
    while IFS=' ' read -r by_id_path device_rel_path; do
        if [[ -n "$by_id_path" && -n "$device_rel_path" ]]; then
            local by_id_base=$(basename "$by_id_path")
            local device_base=$(basename "$device_rel_path")
            
            # Map by-id to device (e.g., ata-... -> sda)
            drive_map["$by_id_base"]="$device_base"
            # Map device to by-id for reverse lookup
            drive_map["$device_base"]="$by_id_base"
            
            log_debug "Mapped: $by_id_base -> $device_base"
        fi
    done <<< "$ata_mappings"
    
    # Process SCSI mappings
    local scsi_mappings
    scsi_mappings=$(result_value "$scsi_result")
    
    while IFS=' ' read -r scsi_id device_path; do
        if [[ -n "$scsi_id" && -n "$device_path" ]]; then
            local dev_name=$(basename "$device_path")
            drive_map["$scsi_id"]="$dev_name"
            log_debug "Mapped SCSI: $scsi_id -> $dev_name"
        fi
    done <<< "$scsi_mappings"
    
    # Convert associative array to output string
    local mapping_output=""
    for key in "${!drive_map[@]}"; do
        mapping_output+="${key}:${drive_map[$key]}"$'\n'
    done
    
    local mapping_count=$(echo "$mapping_output" | grep -c .)
    log_info "Drive mapping table built with $mapping_count entries"
    
    result_success "$mapping_output"
}

# Alternative direct ATA mapping processing
# This function is PURE - no side effects
process_ata_mappings_directly() {
    log_info "Processing ATA mappings directly..."
    local output=""
    
    # Process each ata device link directly
    for ata_link in /dev/disk/by-id/ata-*; do
        if [[ -L "$ata_link" ]] && [[ "$ata_link" != *"-part"* ]]; then
            local target
            target=$(readlink "$ata_link" 2>/dev/null || echo "")
            if [[ -n "$target" ]]; then
                local base_name=$(basename "$ata_link")
                output+="$base_name $target"$'\n'
                log_debug "Direct mapped: $base_name -> $target"
            fi
        fi
    done
    
    # Sort the output
    echo "$output" | sort
}

##############################################################################
# Output Formatting Functions
##############################################################################

# Format and display zpool device information
# This function has side effects (output to stdout) but is deterministic
#
# Usage: format_zpool_output "drive_mappings"
#
# Input:
#   $1: Drive mappings string from build_drive_mapping_table
format_zpool_output() {
    local drive_mappings="$1"
    
    log_info "Formatting zpool output..."
    
    # Parse drive mappings into associative array
    declare -A drive_map
    while IFS=: read -r key value; do
        [[ -n "$key" && -n "$value" ]] && drive_map["$key"]="$value"
    done <<< "$drive_mappings"
    
    log_debug "Drive map size: ${#drive_map[@]} entries"
    
    # Get zpool devices
    local zpool_result
    zpool_result=$(get_zpool_devices)
    if result_is_error "$zpool_result"; then
        log_error "Cannot get zpool devices: $(result_error_msg "$zpool_result")"
        echo "Error: $(result_error_msg "$zpool_result")" >&2
        return 1
    fi
    
    local zpool_devices
    zpool_devices=$(result_value "$zpool_result")
    
    if [[ -z "$zpool_devices" ]]; then
        log_error "No zpool devices found in parsed output"
        echo "No ZFS pools or devices found in the parsed output." >&2
        return 1
    fi
    
    log_info "Displaying zpool device information..."
    
    # Header
    echo "        NAME                                                       DRIVE       ID                      UUID"
    echo ""
    
    local current_pool=""
    local current_vdev=""
    local device_count=0
    
    # Process each zpool device
    while IFS=' ' read -r pool vdev device_id; do
        if [[ -z "$device_id" ]]; then
            continue
        fi
        
        device_count=$((device_count + 1))
        
        # Print pool name header
        if [[ "$pool" != "$current_pool" ]]; then
            [[ -n "$current_pool" ]] && echo ""
            printf "        %-58s\n" "$pool"
            current_pool="$pool"
            current_vdev=""
        fi
        
        # Print vdev name header
        if [[ "$vdev" != "$current_vdev" && "$vdev" != "-" ]]; then
            printf "          %-56s\n" "$vdev"
            current_vdev="$vdev"
        fi
        
        # Process device information
        local base_device_id="$device_id"
        local is_partition=""
        
        # Handle partition devices
        if [[ "$device_id" == *"-part"* ]]; then
            base_device_id="${device_id%-part*}"
            is_partition="true"
            log_debug "Processing partition: $device_id (base: $base_device_id)"
        fi
        
        # Resolve device paths
        local drive_path="unknown"
        local full_id_path="/dev/disk/by-id/$device_id"
        local uuid_result
        uuid_result=$(get_uuid_for_device "$device_id")
        local uuid_path="unknown"
        
        if result_is_success "$uuid_result"; then
            local uuid_val
            uuid_val=$(result_value "$uuid_result")
            if [[ "$uuid_val" != "unknown" ]]; then
                uuid_path="/dev/disk/by-uuid/$uuid_val"
            else
                uuid_path="unknown"
            fi
        fi
        
        # Look up device path from mappings
        if [[ -n "${drive_map[$base_device_id]:-}" ]]; then
            local mapped_value="${drive_map[$base_device_id]}"
            
            # Determine if this is a device name or by-id path
            if [[ "$mapped_value" =~ ^sd[a-z]+$ ]]; then
                # It's a device name
                drive_path="/dev/$mapped_value"
                if [[ "$is_partition" == "true" ]]; then
                    # Add partition number
                    local part_num="${device_id##*-part}"
                    drive_path="${drive_path}${part_num}"
                    log_debug "Resolved partition: $device_id -> $drive_path"
                else
                    log_debug "Resolved device: $base_device_id -> $drive_path"
                fi
            else
                # It's probably a by-id path, try to resolve
                drive_path=$(readlink -f "/dev/disk/by-id/$mapped_value" 2>/dev/null || echo "unknown")
                log_debug "Resolved via by-id: $mapped_value -> $drive_path"
            fi
        else
            log_debug "No mapping found for: $base_device_id"
            # Try direct resolution as fallback
            if [[ -L "/dev/disk/by-id/$device_id" ]]; then
                drive_path=$(readlink -f "/dev/disk/by-id/$device_id" 2>/dev/null || echo "unknown")
                log_debug "Direct resolution: $device_id -> $drive_path"
            fi
        fi
        
        # Output device information
        printf "          %-58s %-11s %-23s %s\n" \
            "$device_id" \
            "$drive_path" \
            "$full_id_path" \
            "$uuid_path"
            
    done <<< "$zpool_devices"
    
    log_info "Displayed $device_count zpool devices"
}

##############################################################################
# Testing Functions
##############################################################################

# Test zpool status parsing with sample data
# This function has side effects (test output)
#
# Usage: test_zpool_parsing
test_zpool_parsing() {
    log_info "Testing zpool status parsing..."
    
    local tests_passed=0
    local tests_failed=0
    
    # Sample zpool status output that matches the user's actual output
    local sample_zpool_output="  pool: Garden
 state: ONLINE
status: Some supported and requested features are not enabled on the pool.
        The pool can still be used, but some features are unavailable.
action: Enable all features using 'zpool upgrade'. Once this is done,
        the pool may no longer be accessible by software that does not support
        the features. See zpool-features(7) for details.
  scan: scrub in progress since Sun Oct 19 05:51:39 2025
        3.95T scanned
 config:

        NAME                                                       STATE     READ WRITE CKSUM
        Garden                                                     ONLINE       0     0     0
          raidz3-0                                                 ONLINE       0     0     0
            ata-HUA722010CLA330_43W7625_42C0400IBM_JPW9L0HZ0WN54C  ONLINE       0     0     0
            ata-WDC_WD10SPCX-75KHST0_WXA1AA61VDLL                  ONLINE       0     0     0
            ata-WDC_WD10SPZX-00Z10T0_WD-WXK2A80LH7PC               ONLINE       0     0     0
            ata-TOSHIBA_DT01ACA1000_626YTCBQCT                     ONLINE       0     0     0
            ata-WDC_WD1002FB9YZ-09H1JL1_WD-WC81Y7821691            ONLINE       0     0     0

errors: No known data errors

  pool: Riyadh
 state: ONLINE
status: Some supported and requested features are not enabled on the pool.
        The pool can still be used, but some features are unavailable.
action: Enable all features using 'zpool upgrade'. Once this is done,
        the pool may no longer be accessible by software that does not support
        the features. See zpool-features(7) for details.
  scan: scrub repaired 0B in 00:07:25 with 0 errors on Sun Oct 19 05:59:22 2025
config:

        NAME                                                           STATE     READ WRITE CKSUM
        Riyadh                                                         ONLINE       0     0     0
          ata-HUA722010CLA330_43W7625_42C0400IBM_JPW9L0HZ0JD0ZC-part2  ONLINE       0     0     0
          ata-WDC_WD10SPCX-75KHST0_WXU1AA60XS04-part2                  ONLINE       0     0     0

errors: No known data errors"
    
    # Test the actual parsing function with the sample data
    local parsed_devices=""
    local current_pool=""
    local current_vdev="-"
    
    while IFS= read -r line; do
        # Extract pool name
        if [[ "$line" =~ ^[[:space:]]*pool:[[:space:]]+([^[:space:]]+) ]]; then
            current_pool="${BASH_REMATCH[1]}"
            current_vdev="-"
            continue
        fi
        
        # Extract vdev name (raidz, mirror, etc.)
        if [[ "$line" =~ ^[[:space:]]+(raidz[0-9]*-[0-9]+|mirror-[0-9]+|spare|log|cache|special)[[:space:]]+ ]]; then
            current_vdev="${BASH_REMATCH[1]}"
            continue
        fi
        
        # Extract device lines (lines containing ata- and ONLINE)
        if [[ "$line" =~ ^[[:space:]]+(ata-[^[:space:]]+)[[:space:]]+ONLINE ]]; then
            local device_id="${BASH_REMATCH[1]}"
            if [[ -n "$current_pool" && -n "$device_id" ]]; then
                parsed_devices+="${current_pool} ${current_vdev} ${device_id}"$'\n'
            fi
            continue
        fi
        
        # For Riyadh pool which has direct devices without vdev
        if [[ "$line" =~ ^[[:space:]]+(ata-[^[:space:]]+-part[0-9]+)[[:space:]]+ONLINE ]] && [[ "$current_pool" == "Riyadh" ]]; then
            local device_id="${BASH_REMATCH[1]}"
            if [[ -n "$current_pool" && -n "$device_id" ]]; then
                parsed_devices+="${current_pool} - ${device_id}"$'\n'
            fi
            continue
        fi
        
    done <<< "$sample_zpool_output"
    
    # Remove trailing newline and trim
    parsed_devices=$(echo "$parsed_devices" | sed '/^[[:space:]]*$/d')
    
    # Verify we found the correct number of devices
    local device_count=$(echo "$parsed_devices" | wc -l)
    if [[ "$device_count" -eq 7 ]]; then
        log_debug "✓ zpool parsing found 7 devices as expected"
        tests_passed=$((tests_passed + 1))
    else
        log_error "✗ zpool parsing found $device_count devices, expected 7"
        log_debug "Parsed devices:"
        echo "$parsed_devices" | while IFS= read -r line; do
            log_debug "  $line"
        done
        tests_failed=$((tests_failed + 1))
    fi
    
    log_info "ZPool parsing tests completed: $tests_passed passed, $tests_failed failed"
    return $tests_failed
}

# Run internal tests to verify script functionality
# This function has side effects (test output)
#
# Usage: run_internal_tests
run_internal_tests() {
    log_info "Running internal tests..."
    
    local tests_passed=0
    local tests_failed=0
    
    # Test result utilities
    local test_result
    test_result=$(result_success "test value")
    if result_is_success "$test_result" && [[ $(result_value "$test_result") == "test value" ]]; then
        log_debug "✓ result_success/test_value passed"
        tests_passed=$((tests_passed + 1))
    else
        log_error "✗ result_success/test_value failed"
        tests_failed=$((tests_failed + 1))
    fi
    
    test_result=$(result_error "test error") 
    if result_is_error "$test_result" && [[ $(result_error_msg "$test_result") == "test error" ]]; then
        log_debug "✓ result_error/test_error passed"
        tests_passed=$((tests_passed + 1))
    else
        log_error "✗ result_error/test_error failed"
        tests_failed=$((tests_failed + 1))
    fi
    
    # Test monadic bind
    local bind_result
    bind_result=$(result_bind "$(result_success "input")" "result_success")
    if result_is_success "$bind_result"; then
        log_debug "✓ result_bind/success passed"
        tests_passed=$((tests_passed + 1))
    else
        log_error "✗ result_bind/success failed"
        tests_failed=$((tests_failed + 1))
    fi
    
    # Test command execution
    local cmd_result
    cmd_result=$(try_cmd "echo 'test'" "Test command")
    if result_is_success "$cmd_result" && [[ $(result_value "$cmd_result") == "test" ]]; then
        log_debug "✓ try_cmd/echo passed"
        tests_passed=$((tests_passed + 1))
    else
        log_error "✗ try_cmd/echo failed"
        tests_failed=$((tests_failed + 1))
    fi
    
    # Run zpool parsing tests
    if test_zpool_parsing; then
        tests_passed=$((tests_passed + 1))
        log_debug "✓ zpool parsing tests passed"
    else
        tests_failed=$((tests_failed + 1))
        log_error "✗ zpool parsing tests failed"
    fi
    
    log_info "Internal tests completed: $tests_passed passed, $tests_failed failed"
    
    if [[ $tests_failed -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

##############################################################################
# Main Function
##############################################################################

# Display usage information
# This function has side effects (output to stdout)
show_usage() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

Display ZFS pool information with detailed device mappings including drive paths,
by-id paths, and UUIDs.

OPTIONS:
    -h, --help          Show this help message
    -v, --version       Show version information
    -t, --test          Run internal tests
    -d, --debug         Enable debug output
    --usage             Show usage examples

EXAMPLES:
    $SCRIPT_NAME                    # Normal operation
    $SCRIPT_NAME --debug           # With debug output
    $SCRIPT_NAME --test            # Run internal tests

EOF
}

# Show usage examples
show_usage_examples() {
    cat << EOF
USAGE EXAMPLES:

1. Basic usage:
   $ ./zpool-device-mappings.sh

2. With debug information:
   $ DEBUG=true ./zpool-device-mappings.sh

3. Run self-tests:
   $ ./zpool-device-mappings.sh --test

4. Show help:
   $ ./zpool-device-mappings.sh --help

EOF
}

# Main execution function
# This function coordinates all operations and handles user input
main() {
    local run_tests=false
    local show_help=false
    local show_version=false
    local show_usage_examples=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help=true
                shift
                ;;
            -v|--version)
                show_version=true
                shift
                ;;
            -t|--test)
                run_tests=true
                shift
                ;;
            -d|--debug)
                export DEBUG=true
                shift
                ;;
            --usage)
                show_usage_examples=true
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                return 1
                ;;
        esac
    done
    
    # Handle help and version requests
    if [[ "$show_help" == "true" ]]; then
        show_usage
        return 0
    fi
    
    if [[ "$show_version" == "true" ]]; then
        echo "$SCRIPT_NAME version $VERSION"
        return 0
    fi
    
    if [[ "$show_usage_examples" == "true" ]]; then
        show_usage_examples
        return 0
    fi
    
    # Run tests if requested
    if [[ "$run_tests" == "true" ]]; then
        run_internal_tests
        return $?
    fi
    
    log_info "Starting ZPool Device Mapper v$VERSION"
    
    # Build drive mapping table
    local mapping_result
    mapping_result=$(build_drive_mapping_table)
    if result_is_error "$mapping_result"; then
        log_error "Failed to build drive mapping table: $(result_error_msg "$mapping_result")"
        return 1
    fi
    
    local drive_mappings
    drive_mappings=$(result_value "$mapping_result")
    
    # Display results
    echo ""
    echo "ZPool Device Overview:"
    echo "=========================================================================================================="
    
    if ! format_zpool_output "$drive_mappings"; then
        log_error "Failed to format zpool output"
        return 1
    fi
    
    echo "=========================================================================================================="
    log_info "ZPool Device Mapper completed successfully"
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

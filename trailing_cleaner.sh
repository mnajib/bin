#!/usr/bin/env bash

# trailing_cleaner.sh - A simple script for cleaning trailing whitespace

set -euo pipefail

# Global constants
readonly SUCCESS=0
readonly ERROR_INVALID_INPUT=1
readonly ERROR_FILE_NOT_FOUND=2
readonly ERROR_PERMISSION_DENIED=3
readonly ERROR_UNKNOWN=4

# Simple logging functions
log_info() {
    echo "[INFO] $1"
}

log_error() {
    echo "[ERROR] $1" >&2
}

log_debug() {
    if [[ "${DEBUG:-}" == "true" ]]; then
        echo "[DEBUG] $1" >&2
    fi
}

# Validate file exists and is writable
validate_file() {
    local file_path="$1"

    if [[ -z "$file_path" ]]; then
        log_error "File path is empty"
        return "$ERROR_INVALID_INPUT"
    fi

    if [[ ! -e "$file_path" ]]; then
        log_error "File not found: $file_path"
        return "$ERROR_FILE_NOT_FOUND"
    fi

    if [[ ! -f "$file_path" ]]; then
        log_error "Not a regular file: $file_path"
        return "$ERROR_INVALID_INPUT"
    fi

    if [[ ! -r "$file_path" ]]; then
        log_error "No read permission: $file_path"
        return "$ERROR_PERMISSION_DENIED"
    fi

    if [[ ! -w "$file_path" ]]; then
        log_error "No write permission: $file_path"
        return "$ERROR_PERMISSION_DENIED"
    fi

    return "$SUCCESS"
}

# Detect trailing whitespace in a file
detect_trailing_whitespace() {
    local file_path="$1"

    if ! validate_file "$file_path"; then
        return "$?"
    fi

    log_debug "Detecting trailing whitespace in: $file_path"

    # Use grep to find lines with trailing whitespace
    local detected_lines=""
    if grep -n -E '[[:space:]]+$' "$file_path" >/dev/null 2>&1; then
        detected_lines=$(grep -n -E '[[:space:]]+$' "$file_path" 2>/dev/null || true)
    fi

    if [[ -n "$detected_lines" ]]; then
        local line_count
        line_count=$(echo "$detected_lines" | wc -l | tr -d ' ')
        echo "$detected_lines"
        log_debug "Found $line_count lines with trailing whitespace"
        return "$SUCCESS"
    else
        log_debug "No trailing whitespace found"
        return "$SUCCESS"
    fi
}

# Clean trailing whitespace from a file
clean_trailing_whitespace() {
    local file_path="$1"
    local dry_run="${2:-false}"

    if ! validate_file "$file_path"; then
        return "$?"
    fi

    log_debug "Processing file: $file_path (dry_run: $dry_run)"

    # Detect trailing whitespace first
    local detected_lines
    detected_lines=$(detect_trailing_whitespace "$file_path")
    local detection_result=$?

    if [[ $detection_result -ne 0 ]]; then
        return "$detection_result"
    fi

    if [[ -z "$detected_lines" ]]; then
        log_info "No trailing whitespace found in $file_path"
        return "$SUCCESS"
    fi

    local line_count
    line_count=$(echo "$detected_lines" | wc -l | tr -d ' ')

    if [[ "$dry_run" == "true" ]]; then
        log_info "DRY RUN: Would clean trailing whitespace from $line_count line(s) in $file_path"
        echo "Lines with trailing whitespace:"
        echo "$detected_lines"
        return "$SUCCESS"
    fi

    # Create backup
    local timestamp
    timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_path="${file_path}.backup_${timestamp}"

    if ! cp "$file_path" "$backup_path"; then
        log_error "Failed to create backup: $backup_path"
        return "$ERROR_PERMISSION_DENIED"
    fi

    log_debug "Backup created: $backup_path"

    # Clean the file in place using sed
    if sed -i 's/[[:space:]]*$//' "$file_path"; then
        log_info "Successfully cleaned trailing whitespace from $line_count line(s) in $file_path"
        log_info "Backup saved as: $backup_path"

        # Verify the cleaning worked
        local remaining_lines
        remaining_lines=$(detect_trailing_whitespace "$file_path" || true)
        if [[ -n "$remaining_lines" ]]; then
            local remaining_count
            remaining_count=$(echo "$remaining_lines" | wc -l | tr -d ' ')
            log_error "Still found $remaining_count lines with trailing whitespace after cleaning"
            return "$ERROR_UNKNOWN"
        fi

        return "$SUCCESS"
    else
        log_error "Failed to clean file: $file_path"
        # Try to restore from backup
        if cp "$backup_path" "$file_path"; then
            log_info "Restored original file from backup"
        else
            log_error "Failed to restore from backup!"
        fi
        return "$ERROR_UNKNOWN"
    fi
}

# Process multiple files
process_files() {
    local files=("$@")
    local dry_run=false
    local processed_count=0
    local error_count=0

    # Check for dry-run flag
    for arg in "$@"; do
        if [[ "$arg" == "-d" || "$arg" == "--dry-run" ]]; then
            dry_run=true
        fi
    done

    for file in "${files[@]}"; do
        # Skip flags
        if [[ "$file" == "-d" || "$file" == "--dry-run" || "$file" == "-v" || "$file" == "--verbose" ]]; then
            continue
        fi

        echo "Processing: $file"

        if clean_trailing_whitespace "$file" "$dry_run"; then
            ((processed_count++))
        else
            log_error "Failed to process: $file"
            ((error_count++))
        fi
        echo
    done

    # Summary
    echo "=== Summary ==="
    echo "Files processed successfully: $processed_count"
    echo "Files with errors: $error_count"
    echo "Dry run mode: $dry_run"

    if [[ $error_count -gt 0 ]]; then
        return "$ERROR_UNKNOWN"
    fi

    return "$SUCCESS"
}

# Usage information
print_usage() {
    cat << EOF
Usage: $0 [OPTIONS] FILE1 [FILE2 ...]

Clean trailing spaces and tabs from files.

OPTIONS:
    -h, --help      Show this help message
    -d, --dry-run   Detect but don't modify files
    -v, --verbose   Enable verbose output

EXAMPLES:
    $0 file.txt                    # Clean file.txt
    $0 -d script.sh               # Dry run on script.sh
    $0 --verbose *.py             # Clean all Python files verbosely
    $0 file1.txt file2.sh file3.c # Clean multiple files

EOF
}

# Main function
main() {
    local files=()
    local dry_run=false

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                print_usage
                exit "$SUCCESS"
                ;;
            -d|--dry-run)
                dry_run=true
                shift
                ;;
            -v|--verbose)
                export DEBUG=true
                shift
                ;;
            -*)
                log_error "Unknown option: $1"
                print_usage
                exit "$ERROR_INVALID_INPUT"
                ;;
            *)
                files+=("$1")
                shift
                ;;
        esac
    done

    if [[ ${#files[@]} -eq 0 ]]; then
        log_error "No files specified"
        print_usage
        exit "$ERROR_INVALID_INPUT"
    fi

    # If dry-run was specified, add it to the files array for process_files
    if [[ "$dry_run" == "true" ]]; then
        files=("-d" "${files[@]}")
    fi

    process_files "${files[@]}"
}

# Test function
test_functions() {
    echo "Testing basic functionality..."

    # Test validation
    echo "1. Testing file validation..."
    if validate_file "$0"; then
        echo "✓ Current script file validation passed"
    else
        echo "✗ Current script file validation failed"
    fi

    # Test detection
    echo "2. Testing trailing whitespace detection..."
    if detect_trailing_whitespace "$0" >/dev/null; then
        echo "✓ Trailing whitespace detection working"
    else
        echo "✗ Trailing whitespace detection failed"
    fi

    # Create test file
    local test_file="/tmp/test_trailing_whitespace.txt"
    echo "test line with spaces     " > "$test_file"
    echo "another line with tabs	" >> "$test_file"

    echo "3. Testing with actual trailing whitespace..."
    local detected
    detected=$(detect_trailing_whitespace "$test_file")
    if [[ -n "$detected" ]]; then
        echo "✓ Successfully detected trailing whitespace:"
        echo "$detected"
    else
        echo "✗ Failed to detect trailing whitespace"
    fi

    # Clean up
    rm -f "$test_file"
    echo "Testing completed"
}

# Run tests if requested
if [[ "${1:-}" == "--test" ]]; then
    test_functions
    exit "$SUCCESS"
fi

# Run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

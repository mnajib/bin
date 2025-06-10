#!/bin/bash

# bash_logger.sh - Enhanced Logging Library with Debug Flag Support

# Log levels: DEBUG < INFO < WARN < ERROR < FATAL
declare -A LOG_LEVELS=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3 [FATAL]=4)
DEFAULT_LOG_LEVEL="INFO"
CURRENT_LOG_LEVEL=${LOG_LEVELS[$DEFAULT_LOG_LEVEL]}
LOG_TARGET=""  # Empty means stderr
DEBUG_FLAG_ENABLED=false

# Pure function to identify caller script name
__get_caller_script() {
    local idx=1  # Start at 1 to skip this function's frame
    while (( idx < ${#BASH_SOURCE[@]} )); do
        local candidate="${BASH_SOURCE[$idx]}"
        # Skip frames from the logger script itself
        [[ "$candidate" == "${BASH_SOURCE[0]}" ]] || {
            # Extract filename without path
            local name="${candidate##*/}"
            # Handle special case when script is sourced
            [[ "$name" == "bash" || "$name" == "sh" ]] && name="main"
            printf -v "$1" "%s" "$name"
            return
        }
        ((idx++))
    done
    printf -v "$1" "%s" "main"
}

# Initialize logging system
__log_init() {
    if [[ -n "$LOG_TARGET" && "$LOG_TARGET" != "stderr" ]]; then
        exec 3>>"$LOG_TARGET" || {
            echo "Failed to open log file: $LOG_TARGET" >&2
            exit 1
        }
    else
        exec 3>&2  # Default to stderr
    fi
}

# Core logging function
log() {
    local level=$1 msg=$2
    local level_num=${LOG_LEVELS[$level]}
    
    [[ $level_num -ge $CURRENT_LOG_LEVEL ]] || return 0
    
    local timestamp
    timestamp=$(date +"%Y-%m-%d %T")
    
    # Pure caller identification
    local source_file
    __get_caller_script source_file

    # Format: [Time] [Level] [Script] Message
    printf "[%s] [%s] [%s] %s\n" \
        "$timestamp" "$level" "$source_file" "$msg" >&3
}

# Public logging functions
debug() { log "DEBUG" "$1"; }
info()  { log "INFO"  "$1"; }
warn()  { log "WARN"  "$1"; }
error() { log "ERROR" "$1"; }
fatal() { log "FATAL" "$1"; exit 1; }

# Set log level
set_log_level() {
    local new_level=${1^^}
    if [[ -n "${LOG_LEVELS[$new_level]}" ]]; then
        CURRENT_LOG_LEVEL=${LOG_LEVELS[$new_level]}
    else
        echo "Invalid log level: $1. Valid levels: ${!LOG_LEVELS[*]}" >&2
        return 1
    fi
}

# Enable debug mode via command line flag
enable_debug_mode() {
    DEBUG_FLAG_ENABLED=true
    set_log_level "DEBUG"
    debug "Debug mode enabled via command line flag"
}

# Check for --debug flag in arguments
check_debug_flag() {
    for arg in "$@"; do
        if [[ "$arg" == "--debug" ]]; then
            enable_debug_mode
            return 0
        fi
    done
    return 1
}

# Set log target (file or 'stderr')
set_log_target() {
    local target=$1
    if [[ -n "$target" && "$target" != "stderr" ]]; then
        LOG_TARGET=$target
        # Close previous file descriptor if needed
        [[ ! -t 3 ]] && exec 3>&-
        exec 3>>"$LOG_TARGET" || {
            echo "Failed to open log file: $LOG_TARGET" >&2
            return 1
        }
    else
        LOG_TARGET="stderr"
        exec 3>&2  # Redirect to stderr
    fi
}

# Initialize logging when sourced
__log_init

#!/usr/bin/env bash

# bash_logger.sh - Logging Library for Bash Scripts

# Log levels: DEBUG < INFO < WARN < ERROR < FATAL
declare -A LOG_LEVELS=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3 [FATAL]=4)
DEFAULT_LOG_LEVEL="INFO"
CURRENT_LOG_LEVEL=${LOG_LEVELS[$DEFAULT_LOG_LEVEL]}
LOG_TARGET=""  # Empty means stderr

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
    
    # Robust caller identification
    local source_file="main"
    if [[ ${#BASH_SOURCE[@]} -gt 2 ]]; then
        # Walk through call stack to find first external script
        for (( idx=2; idx<${#BASH_SOURCE[@]}; idx++ )); do
            local candidate="${BASH_SOURCE[$idx]}"
            if [[ "$candidate" != "${BASH_SOURCE[0]}" ]]; then
                source_file=$(basename "$candidate")
                break
            fi
        done
    fi

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

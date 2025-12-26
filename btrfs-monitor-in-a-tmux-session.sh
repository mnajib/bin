#!/usr/bin/env bash
# btrfs-monitor-in-a-tmux-session.sh: Functional-style Btrfs monitoring with Maybe monad


# =============================================
# Logging
# =============================================
source ${HOME}/bin/bash_logger.sh
# Set log level (DEBUG/INFO/WARN/ERROR/FATAL)
# Set default log level (ERROR in your case)
set_log_level "ERROR"
#set_log_level "WARN"
#set_log_level "DEBUG"

# Check for --debug flag BEFORE any logging calls
check_debug_flag "$@"
#
# Handle debug flag by removing it from arguments
args=()
for arg in "$@"; do
    if [[ "$arg" == "--debug" ]]; then
        # Enable debug mode and log the change
        set_log_level "DEBUG"
        debug "Debug mode enabled via command line flag"
    else
        # Keep all other arguments
        args+=("$arg")
    fi
done

# Set log target (default: stderr)
#  set_log_target "/var/log/myscript.log"
#  set_log_target "stderr"   # Revert to stderr
#set_log_target "/tmp/btrfs-monitor-tmux.log"
set_log_target "/tmp/${USER}-btrfs-monitor-tmux.log"

cat /dev/null > "/tmp/${USER}-btrfs-monitor-tmux.log"
debug "Logging start"

# Example to use the logging functions:
#   debug "Detailed debug message"
#   info "General information"
#   warn "Warning message"
#   error "Error occurred"
#   fatal "Critical failure - exiting"


# =============================================
# Maybe Monad Implementation for Bash
# =============================================

# Maybe constructor: Just value
Just() { echo "$1"; }

# Maybe constructor: Nothing
Nothing() { :; }

# Bind operator: maybe_value >>= function
mbind() {
    local maybe_value="$1"
    local f="$2"

    # If value is empty, return Nothing
    #debug "If value is empty, return Nothing"
    [[ -z "$maybe_value" ]] && return

    # Apply function to value
    #debug "Apply function to value"
    "$f" "$maybe_value"
}

# Safe function application: f |<< value
safe_apply() {
    local f="$1"
    local value="$2"

    [[ -z "$value" ]] && return 1
    "$f" "$value"
}

# =============================================
# Pure Functions with Maybe Pattern
# =============================================

# Safe: Get absolute path to btrfs-primary-mounts.sh
get_primary_script_path() {
    # Try user's bin directory first
    if [[ -f "$HOME/bin/btrfs-primary-mounts.sh" ]]; then
        Just "$HOME/bin/btrfs-primary-mounts.sh"
    # Try current directory
    elif [[ -f "./btrfs-primary-mounts.sh" ]]; then
        Just "$(pwd)/btrfs-primary-mounts.sh"
    # Try system PATH
    else
        path=$(command -v btrfs-primary-mounts.sh 2>/dev/null)
        [[ -n "$path" ]] && Just "$path" || Nothing
    fi
}

# Pure function: Generate tmux session name
generate_session_name() {
    Just "btrfs-monitor-$(date +%s)"
}

# Pure function: Generate window name for a mount point
generate_window_name() {
    local mount_point="$1"
    local base_name

    # Handle root mount point
    base_name="${mount_point:-root}"
    base_name=$(basename "$base_name")

    # Sanitize for tmux window names (ensure non-empty)
    local sanitized=$(echo "$base_name" | sed 's/[^a-zA-Z0-9]/-/g')

    # Ensure we never return empty name
    [[ -z "$sanitized" ]] && sanitized="root"

    Just "$sanitized"
}

# Pure function: Get pane title
get_pane_title() {
    local pane_index="$1"
    #case $pane_index in
    #    0) echo "Dev Usage" ;;
    #    1) echo "FS DF" ;;
    #    2) echo "FS Usage" ;;
    #    3) echo "Scrub/Balance" ;;
    #    *) Nothing ;;
    #esac
    case $pane_index in
        1) echo "Dev Usage" ;;
        2) echo "FS DF" ;;
        3) echo "FS Usage" ;;
        4) echo "Scrub/Balance" ;;
        *) Nothing ;;
    esac
}

# Pure function: Get pane command
get_pane_command() {
    local pane_index="$1"
    local mount_point="$2"

    #case $pane_index in
    #    0) echo "btrfs device usage '$mount_point'" ;;
    #    1) echo "btrfs filesystem df '$mount_point'" ;;
    #    2) echo "btrfs filesystem usage '$mount_point'" ;;
    #    3) echo "btrfs scrub status '$mount_point'; echo; btrfs balance status '$mount_point'" ;;
    #    *) Nothing ;;
    #esac
    case $pane_index in
        1) echo "btrfs device usage '$mount_point'" ;;
        2) echo "btrfs filesystem df '$mount_point'" ;;
        3) echo "btrfs filesystem usage '$mount_point'" ;;
        4) echo "btrfs scrub status '$mount_point'; echo; btrfs balance status '$mount_point'" ;;
        *) Nothing ;;
    esac
}

# Get refresh command
get_refresh_command() {
    local command="$1"
    local interval="$2"
    echo "while true; do clear; $command; sleep $interval; done"
}


# =============================================
# Effectful Functions with Maybe Handling
# =============================================

# Safe: Get Btrfs mount points
get_btrfs_mount_points() {
    local script_path="$1"

    # Safe application with Maybe pattern
    #safe_apply run_script "$script_path" || Nothing
    # Run the script and convert output to one mount point per line
    #run_script "$script_path" | tr ' ' '\n' | sed '/^$/d'
    safe_apply run_script "$script_path" | tr ' ' '\n' | sed '/^$/d' || Nothing
}

run_script() {
    local script_path="$1"
    [[ -x "$script_path" ]] || return 1
    "$script_path"
}

# Create tmux session
create_tmux_session() {
    local session_name="$1"
    tmux new-session -d -s "$session_name" -n "Dashboard" "echo 'Initializing...'"
}

# Safe: Create tmux window. Get window index after creation
# Usage: create_tmux_window <existing_session_name> <to_be_created_window_name>
create_tmux_window() {
    local session="$1" name="$2"

    # Create window and capture output to get window ID
    #tmux new-window -d -P -t "$session" -n "$name" "echo 'Initializing...'"
    tmux new-window -d -P -t "$session" -n "$name"
    send_tmux_keys "$session" "$name" "echo 'Initializing...'"

    local window_id=$?
    # Get actual window index
    local index=$(tmux list-windows -t "$session" -F '#I:#W' | awk -F: -v name="$name" '$2 == name {print $1}' | tail -n1)
    debug "create_tmux_window: index='${index}'"

    [[ -n "$index" ]] && Just "$index" || Nothing
}
# Safe: Create tmux window and return its index
# Usage: create_tmux_window <session> <window_name>
_create_tmux_window() {
    local session="$1" name="$2"

    # Create window and capture output
    local output
    output=$(tmux new-window -d -P -t "$session" -n "$name" "echo 'Initializing...'")
    local status=$?

    if [[ $status -ne 0 ]]; then
        error "Failed to create window: tmux new-window returned $status"
        return 1
    fi

    # Parse window index from output (format: [session]:index)
    local index
    debug "create_tmux_window: output='$output'"
    #index=$(echo "$output" | awk -F: '{print $2}' | tr -d ']')
    #index=$(echo "$output" | awk -F[:.] '{print $2}')
    index="$output"
    debug "create_tmux_window: index='$index'"

    if [[ -z "$index" ]]; then
        error "Failed to parse window index from tmux output: '$output'"
        return 1
    fi

    debug "create_tmux_window: Created window '$name' with index '$index'"
    Just "$index"
}

# Safe: Create pane
create_tmux_pane() {
    local session="$1"
    local window_index="$2"
    local direction="$3"
    #local target_pane="${4:-0}"   # Default to pane 0
    local target_pane="${4:-1}"   # Default to pane 1

    tmux split-window -d "$direction" -t "${session}:${window_index}.${target_pane}" && Just "$?"
}
create_tmux_pane_2() {
    local target_pane="${1}"
    local direction="${2}"

    tmux split-window -d "$direction" -t "${target_pane}" && Just "$?"
}


# Safe: Send keys to tmux
send_tmux_keys() {
    local session="$1" window="$2" command="$3"
    tmux send-keys -t "${session}:${window}" "$command" Enter && Just "$?"
}

# Set pane title
set_pane_title() {
    local session="$1" target="$2" title="$3"
    tmux select-pane -t "${session}:${target}" -T "$title"
}

# =============================================
# Monitoring Functions with Monadic Composition
# =============================================

# Create summary window with monadic error handling
_create_summary_window() {
    local session="$1"

    debug "create_summary_window: Begin"

    # Create window with Maybe handling
    debug "create_summary_window: Creating a new window Summary in session ${session}"
    window=$(create_tmux_window "$session" "Summary") || return
    debug "create_summary_window: window ${window} created"

    # Send commands with safe composition
    debug "create_summary_window: print header "
    send_tmux_keys "$session" "Summary" \
        "echo 'BTRFS SYSTEM MONITOR - SUMMARY VIEW'" || return

    debug "create_summary_window: show btrfs filesystem and device stats"
    debug "create_summary_window: show btrfs filesystem and device stats for '/'"
    send_tmux_keys "$session" "Summary" \
        "while true; do clear; btrfs filesystem show; echo; btrfs device stats /; sleep 10; done"

    debug "create_summary_window: show btrfs filesystem and device stats for '/boot2': TODO"

    debug "create_summary_window: End"
}
#
__create_summary_window() {
    local session="$1"
    shift
    local mount_points=("$@")
    local window_index=1 #0 My tmux setting start numbering it from 1, not 0.
    local window_title="Summary"

    debug "create_summary_window: Begin"

    # Return if no mount points
    if [[ ${#mount_points[@]} -eq 0 ]]; then
        warn "No Btrfs mount points found"
        return 1
    fi

    debug "create_summary_window: session='${session}', mount_points_count='${#mount_points[@]}', mount_points='${mount_points[*]}', window_index='${window_index}'"

    # Create window with Maybe handling
    debug "create_summary_window: Creating a new window Summary in session ${session}"
    window=$(create_tmux_window "$session" "${window_title}") || return
    debug "create_summary_window: window='${window}' created"

    debug "create_summary_window: run process creating a tmux pane for each mount point'"
    for mount_point in "${mount_points[@]}"; do
        [[ -z "$mount_point" ]] && continue
        debug "create_summary_window: Run process creating a tmux pane for mount_point '${mount_point}'"

        debug "create_summary_window: print header "
        send_tmux_keys "$session" "$window_title" \
            "echo 'BTRFS SYSTEM MONITOR - SUMMARY VIEW'" || return

        debug "create_summary_window: show btrfs filesystem and device stats for mount_point='${mount_point}'"
        send_tmux_keys "$session" "$window_title" \
            "while true; do clear; btrfs filesystem show; echo; btrfs device stats /; sleep 10; done"
    done

    debug "create_summary_window: End"
}
#
# Create summary window with mount point information
create_summary_window() {
    local session="$1"
    shift
    local mount_points=("$@")

    debug "create_summary_window: Begin"
    debug "Mount points: ${#mount_points[@]} - ${mount_points[*]}"

    # Create window with Maybe handling
    window=$(create_tmux_window "$session" "Summary") || return
    debug "create_summary_window: window='${window}' created"

    # Generate summary command
    local summary_cmd="echo 'BTRFS SYSTEM MONITOR - SUMMARY VIEW'"
    summary_cmd+="; echo"
    summary_cmd+="; echo '=== ALL BTRFS FILESYSTEMS (btrfs filesystem show) ==='"
    summary_cmd+="; echo"
    summary_cmd+="; btrfs filesystem show"

    # Add per-mount point stats if mount points exist
    if [[ ${#mount_points[@]} -gt 0 ]]; then
        summary_cmd+="; echo"
        summary_cmd+="; echo '=== MOUNT POINT DEVICE STATS (btrfs device stats <mount_point>) ==='"

        for mp in "${mount_points[@]}"; do
            [[ -z "$mp" ]] && continue
            summary_cmd+="; echo"
            summary_cmd+="; echo '---- $mp ----'"
            debug "create_summary_window: btrfs device stats ${mp}"
            summary_cmd+="; btrfs device stats $mp"
        done
    fi

    # Add per-mount point summary if mount points exist
    if [[ ${#mount_points[@]} -gt 0 ]]; then
        summary_cmd+="; echo"
        summary_cmd+="; echo '=== MOUNT POINT SUMMARY (btrfs filesystem df <mount_point>) ==='"

        for mp in "${mount_points[@]}"; do
            [[ -z "$mp" ]] && continue
            summary_cmd+="; echo"
            summary_cmd+="; echo '---- $mp ----'"
            debug "create_summary_window: btrfs filesystem df ${mp}"
            summary_cmd+="; btrfs filesystem df '$mp'"
        done
    fi

    # Create refresh command
    local refresh_cmd="while true; do clear; $summary_cmd; sleep 10; done"

    # Send commands
    debug "create_summary_window: send_tmux_keys ${session} Summary ${refresh_cmd}"
    send_tmux_keys "$session" "Summary" "$refresh_cmd" || return

    debug "create_summary_window: End"
}

# Create pane layout (pure functional style)
create_pane_layout() {
    local session="$1"
    local window_index="$2"
    local mount_point="$3"

    # Create panes in a functional way
    create_tmux_pane "$session" "$window_index" "-h" "1" &&
    create_tmux_pane "$session" "$window_index" "-v" "1" &&
    create_tmux_pane "$session" "$window_index" "-v" "2" || return 1

    # Configure panes functionally
    for pane_index in {1..4}; do
        # Get pane properties purely
        local pane_target="${window_index}.${pane_index}"
        local pane_title
        pane_title=$(get_pane_title "$pane_index") || continue
        local pane_cmd
        pane_cmd=$(get_pane_command "$pane_index" "$mount_point") || continue

        # Create refresh command purely
        local refresh_cmd="while true; do clear; $pane_cmd; sleep 5; done"

        # Effectful operations with error handling
        send_tmux_keys "$session" "$pane_target" "clear" &&
        send_tmux_keys "$session" "$pane_target" "$refresh_cmd" &&
        set_pane_title "$session" "$pane_target" "$pane_title" || {
            error "Failed to configure pane $pane_target"
            continue
        }
    done

    return 0
}

# Create filesystem monitoring window for each mount point (functional style)
_create_filesystem_window() {
    local session="$1"
    shift
    local mount_points=("$@")

    # Pure: Return if no mount points
    [[ ${#mount_points[@]} -eq 0 ]] && {
        warn "No Btrfs mount points found"
        return 1
    }

    # Pure: Log initial state (immutable)
    debug "create_filesystem_window: session='${session}', mount_points_count='${#mount_points[@]}', mount_points='${mount_points[*]}'"

    # Process each mount point immutably
    for mount_point in "${mount_points[@]}"; do
        [[ -z "$mount_point" ]] && continue

        # Pure: Generate window name immutably
        local base_window_name
        base_window_name=$(generate_window_name "$mount_point") || {
            error "generate_window_name failed for: $mount_point"
            continue
        }
        local window_name="FS-${base_window_name}"

        # Effectful: Create window
        local window_index
        window_index=$(create_tmux_window "$session" "$window_name") || {
            error "create_tmux_window failed for: $window_name"
            continue
        }
        debug "create_filesystem_window: window_index='$window_index'"

        # Effectful: Create pane layout
        create_pane_layout "$session" "$window_index" "$mount_point" || {
            error "Failed to create pane layout for $window_name"
            continue
        }
    done

    return 0
}
#
# Create filesystem monitoring window for each mount point
create_filesystem_window() {
    local session="$1"
    shift
    local mount_points=("$@")
    local window_index=1 #0 My tmux setting start numbering it from 1, not 0.

    # Return if no mount points
    if [[ ${#mount_points[@]} -eq 0 ]]; then
        warn "No Btrfs mount points found"
        return 1
    fi

    debug "create_filesystem_window: session='${session}', mount_points_count='${#mount_points[@]}', mount_points='${mount_points[*]}', window_index='${window_index}'"

    # Process each mount point
    debug "create_filesystem_window: run process creating a tmux window for each mount point'"
    for mount_point in "${mount_points[@]}"; do
        [[ -z "$mount_point" ]] && continue

        debug "create_filesystem_window: Run process creating a tmux window for mount_point '${mount_point}'"

        # Generate window name
        window_name=$(generate_window_name "$mount_point") || {
            error "create_filesystem_window: generate_window_name failed for: $mount_point"
            continue
        }
        debug "create_filesystem_window: window_name='$window_name' for mount_point='$mount_point'"
        debug "create_filesystem_window: Add prefix 'FS-' to the window_name"
        window_name="FS-${window_name}"
        debug "create_filesystem_window: window_name='$window_name' for mount_point='$mount_point'"

        # Create window and get numerical index
        debug "create_filesystem_window: session='$session', window_name='$window_name' and window_index='$window_index'"
        window_index=$(create_tmux_window "$session" "$window_name") || {
            error "create_filesystem_window: create_tmux_window failed for: $window_name"
            continue
        }
        debug "create_filesystem_window: A window created. session='$session', window_name='$window_name' and window_index='$window_index'"
        debug "create_filesystem_window: Tweak the window_index"
        window_index=$(echo $window_index | awk -F[:.] '{print $2}')
        debug "create_filesystem_window: session='$session', window_name='$window_name' and window_index='$window_index'"

        # Create 2x2 grid of panes in the window
        # Step 1: Horizontal split (creates right pane)
        #debug "create_filesystem_window: Do horizontal split. session='session', window_index='$window_index', direction='-h', pane_id=''"
        #if ! create_tmux_pane "$session" "$window_index" "-h"; then
        debug "create_filesystem_window: Do horizontal split. session='session', window_index='$window_index', direction='-h', pane_id='1'"
        if ! create_tmux_pane "$session" "$window_index" "-h" "1"; then
        #if ! create_tmux_pane_2 "$window_index" "-h"; then
            error "create_filesystem_window: Failed horizontal split in $window_name"
            continue
        fi
        debug "create_filesystem_window: The new pane-2 created an the right of pane-1 from spliting pane-1"

        # Step 2: Vertical split on left pane
        debug "create_filesystem_window: Do vertical split. session='$session', window_index='$window_index', direction='-v', pane_id='1'"
        if ! create_tmux_pane "$session" "$window_index" "-v" "1"; then
            error "create_filesystem_window: Failed vertical split on left pane in $window_name"
            continue
        fi
        debug "create_filesystem_window: The new pane-3 created at the bottom of pane-1 from spliting pane-1 vertically, but then my tmux setting rearrange the numbering of the new created pane to pane-2"

        # Step 3: Vertical split on right pane
        debug "create_filesystem_window: Do vertical split. session='$session', window_index='$window_index', direction='-v', pane_id='3'"
        if ! create_tmux_pane "$session" "$window_index" "-v" "3"; then
            error "create_filesystem_window: Failed vertical split on right pane in $window_name"
            continue
        fi
        debug "create_filesystem_window: The new pane-4 created at the bottom of pane-3 from spliting pane-3 vertically"

        # Configure each pane
        #for pane_index in {0..3}; do
        for pane_index in {1..4}; do
            pane_target="${window_index}.${pane_index}"
            pane_title=$(get_pane_title "$pane_index") || continue
            pane_cmd=$(get_pane_command "$pane_index" "$mount_point") || continue
            refresh_cmd="while true; do clear; $pane_cmd; sleep 5; done"
            clear_cmd="clear"

            # Clear and run refresh command
            send_tmux_keys "$session" "$pane_target" "$clear_cmd" || continue
            send_tmux_keys "$session" "$pane_target" "$refresh_cmd" || continue

            # Set pane title
            debug "create_filesystem_window: Run set_pane_title function with session='${session}', pane_target='${pane_target}', pane_title='${pane_title}'"
            set_pane_title "$session" "$pane_target" "$pane_title"
        done

        debug "create_filesystem_window: End process for mount point '${mount_point}'"
    done

    debug "create_filesystem_window: End"
}

# Create log window
create_log_window() {
    local session="$1"

    window=$(create_tmux_window "$session" "Logs") || return
    #window_title="Logs"
    #pane_index=1
    #pane_target="${window_title}.${pane_index}"
    #pane_title="Journal-1"
    #cmd="journalctl -f -u btrfs"
    send_tmux_keys "$session" "Logs" "clear" || return
    send_tmux_keys "$session" "Logs" "journalctl -f -u btrfs*"
    #send_tmux_keys "$session" "Logs" "journalctl -f | grep -i btrfs"
    set_pane_title "$session" "Logs" "Journal-1"

    #window_index=$(echo $window | awk -F[:.] '{print $2}')
    #window_title="Logs"
    #pane_title="Journal-2"
    #debug "create_log_window: Do vertical split. session='$session', window_index='$window', direction='-v', pane_id='1'"
    #if ! create_tmux_pane "$session" "$window_index" "-v" "1"; then
    #    error "create_log_window: Failed vertical split on pane in $window_name"
    #    continue
    #fi
    #debug "create_log_window: The new pane-2 created at the bottom of pane-1 from spliting pane-1 vertically"
    #pane_index=2
    #pane_target="${window_index}.${pane_index}"
    #cmd="journalctl -a -f | grep -i btrfs"
    #send_tmux_keys "$session" "$pane_target" "$cmd" || continue
    #set_pane_title "$session" "$pane_target" "$pane_title"
}

# Configure tmux session
configure_tmux_session() {
    local session="$1" primary_script="$2"

    tmux set-option -t "$session" -g status-interval 5
    tmux set-option -t "$session" -g status-right \
        "#[fg=cyan]#($primary_script | wc -l) Btrfs Filesystems"
    tmux set-window-option -t "$session" -g automatic-rename off
}

# =============================================
# Main Controller with Monadic Error Handling
# =============================================

main() {

    #--------------------------------------------------------
    # Get primary script path with Maybe
    #--------------------------------------------------------
    debug "main: Get primary script path with Maybe"
    primary_script=$(get_primary_script_path) || {
        echo "ERROR: btrfs-primary-mounts.sh not found!" >&2
        error "main: btrfs-primary-mounts.sh not found!"
        return 1
    }
    debug "main: primary_script=${primary_script}"

    #--------------------------------------------------------
    # Get session name with Maybe
    #--------------------------------------------------------
    debug "main: Get session name with Maybe"
    session_name=$(generate_session_name) || {
        echo "ERROR: Failed to generate session name" >&2
        error "main: Failed to generate session name"
        return 1
    }
    debug "main: session_name=${session_name}"

    #--------------------------------------------------------
    # Get mount points with monadic bind
    #--------------------------------------------------------
    #debug "main: Get mount points with monadic bind"
    #mount_points=$(get_btrfs_mount_points "$primary_script") || {
    #    echo "ERROR: Failed to get mount points" >&2
    #    error "main: Failed to get mount points"
    #    return 1
    #}
    #debug "main: mount_points=${mount_points}"
    #
    debug "main: Get mount points with monadic bind"
    mapfile -t mount_points_arr < <(get_btrfs_mount_points "$primary_script" || {
        echo "ERROR: Failed to get mount points" >&2
        error "main: Failed to get mount points"
        return 1
    })
    debug "main: Found ${#mount_points_arr[@]} mount points"

    #--------------------------------------------------------
    # Create a new tmux session with the name we got above, and a window name "Dashboard"
    #--------------------------------------------------------
    debug "main: Create tmux session with session_name=${session_name} and window_name=Dashboard"
    if ! tmux new-session -d -s "$session_name" -n "Dashboard"; then
        echo "ERROR: Failed to create tmux session" >&2
        error "main: Failed to create tmux session"
        return 1
    fi
    debug "main: tmux session ${session_name} created"


    #--------------------------------------------------------
    # 1. Create tmux window "Summary"
    #--------------------------------------------------------
    # Setup windows with safe composition
    debug "main: Create tmux window: Summary, with session_name='$session_name' and mount_points_arr[@]='${mount_points_arr[@]}'"
    #create_summary_window "$session_name"
    create_summary_window "$session_name" "${mount_points_arr[@]}"

    #--------------------------------------------------------
    # 2. Create tmux window "FS"
    #--------------------------------------------------------
    # Process each mount point
    debug "main: Create tmux window: FS, with session_name='$session_name' and mount_points_arr[@]='${mount_points_arr[@]}'"
    #while IFS= read -r mount_point; do
    #    [[ -n "$mount_point" ]] || continue
    #    create_filesystem_window "$session_name" "$mount_point"
    #    debug "main: create_filesystem_window ${session_name} ${mount_point}"
    #done <<< "$mount_points"
    #create_filesystem_window "$session_name" "${mount_points[@]}"
    create_filesystem_window "$session_name" "${mount_points_arr[@]}"

    #--------------------------------------------------------
    # 3. Create tmux window "Log"
    #--------------------------------------------------------
    debug "main: Create tmux window: Log, with session_name='$session_name'"
    create_log_window "$session_name"


    #--------------------------------------------------------
    # Configure tmux
    #--------------------------------------------------------
    debug "main: configure_tmux_session ${session_name} ${primary_script}"
    configure_tmux_session "$session_name" "$primary_script"

    #--------------------------------------------------------
    # Attach the created tmux session
    #--------------------------------------------------------
    debug "main: Final attachment"
    tmux select-window -t "$session_name:Summary"
    tmux attach -t "$session_name" || echo "Attach failed, use: tmux attach -t $session_name"
}

# Execute main with error handling
#if ! main; then
#    exit 1
#fi
#
if ! main "${args[@]}"; then  # Note: use "${args[@]}" instead of "$@"
  exit 1
fi


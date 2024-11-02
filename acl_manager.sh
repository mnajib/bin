#!/usr/bin/env bash

# acl_manager.sh - A simple script to manage ACLs

# I/O Functions
io_print_message() {
    echo "$1"
}

io_print_error() {
    io_print_message "Error: $1"
    exit 1
}

io_show_usage() {
    script_name=$(io_get_script_name)  # Updated to use io_get_script_name
    io_print_message "Usage: $script_name [option] [username] [file/directory] [permissions]"
    io_print_message
    io_print_message "Options:"
    io_print_message "  set    : Set ACL for a user on a specified file or directory."
    io_print_message "            Example: $script_name set username /path/to/file rwx"
    io_print_message
    io_print_message "  get    : Get ACL for a specified file or directory."
    io_print_message "            Example: $script_name get /path/to/file"
    io_print_message
    io_print_message "  remove : Remove ACL for a user on a specified file or directory."
    io_print_message "            Example: $script_name remove username /path/to/file"
    io_print_message
    io_print_message "  -h     : Show this help message."
    io_print_message
    io_print_message "Note:"
    io_print_message "  Permissions can be specified as 'r' (read), 'w' (write), 'x' (execute)."
    io_print_message "  You can combine them, e.g., 'rw' for read and write."
}

io_get_script_name() {
    # Returns the name of the script without the directory
    echo "$(basename "$0")"
}

# Pure Functions
pure_build_set_acl_command() {
    local username="$1"
    local file="$2"
    local permissions="$3"

    if [[ -e "$file" ]]; then
        echo "setfacl -m u:$username:$permissions \"$file\""
    else
        echo "error"
    fi
}

pure_build_get_acl_command() {
    local file="$1"

    if [[ -e "$file" ]]; then
        echo "getfacl \"$file\""
    else
        echo "error"
    fi
}

pure_build_remove_acl_command() {
    local username="$1"
    local file="$2"

    if [[ -e "$file" ]]; then
        echo "setfacl -x u:$username \"$file\""
    else
        echo "error"
    fi
}

# Function to execute a command
io_execute_command() {
    local command="$1"
    eval "$command"  # Execute the command
}

# Main Logic
if [ "$#" -lt 2 ]; then
    io_show_usage
    exit 1
fi

command_type="$1"

case "$command_type" in
    set)
        if [ "$#" -ne 4 ]; then
            io_print_error "Please provide username, file/directory, and permissions."
        fi
        command=$(pure_build_set_acl_command "$2" "$3" "$4")
        if [[ "$command" == "error" ]]; then
            io_print_error "Could not set ACL. File does not exist."
        fi
        io_execute_command "$command"  # Execute the constructed command
        ;;
    get)
        if [ "$#" -ne 2 ]; then
            io_print_error "Please provide file/directory."
        fi
        command=$(pure_build_get_acl_command "$2")
        if [[ "$command" == "error" ]]; then
            io_print_error "Could not get ACL. File does not exist."
        fi
        io_execute_command "$command"  # Execute the constructed command
        ;;
    remove)
        if [ "$#" -ne 3 ]; then
            io_print_error "Please provide username and file/directory."
        fi
        command=$(pure_build_remove_acl_command "$2" "$3")
        if [[ "$command" == "error" ]]; then
            io_print_error "Could not remove ACL. File does not exist."
        fi
        io_execute_command "$command"  # Execute the constructed command
        ;;
    -h|--help)
        io_show_usage
        ;;
    *)
        io_print_error "Invalid option '$1'."
        ;;
esac


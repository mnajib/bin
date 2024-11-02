#!/usr/bin/env bash

# acl_manager.sh - A simple script to manage ACLs

# IO Functions
print_message() {
    echo "$1"
}

show_usage() {
    script_name=$(get_script_name)
    print_message "Usage: $script_name [option] [username] [file/directory] [permissions]"
    print_message
    print_message "Options:"
    print_message "  set    : Set ACL for a user on a specified file or directory."
    print_message "            Example: $script_name set username /path/to/file rwx"
    print_message "            This will grant user 'username' read, write, and execute permissions on '/path/to/file'."
    print_message
    print_message "  get    : Get ACL for a specified file or directory."
    print_message "            Example: $script_name get /path/to/file"
    print_message "            This will display the ACL for '/path/to/file'."
    print_message
    print_message "  remove : Remove ACL for a user on a specified file or directory."
    print_message "            Example: $script_name remove username /path/to/file"
    print_message "            This will remove the ACL for 'username' on '/path/to/file'."
    print_message
    print_message "  -h     : Show this help message."
    print_message
    print_message "Note:"
    print_message "  Permissions can be specified as 'r' (read), 'w' (write), 'x' (execute)."
    print_message "  You can combine them, e.g., 'rw' for read and write."
    print_message "  Ensure the specified file or directory exists before running the commands."
}

get_script_name() {
    # Returns the name of the script without the directory
    echo "$(basename "$0")"
}

# Maybe Monad Implementation
maybe() {
    local value="$1"
    local if_just="$2"
    local if_nothing="$3"

    if [[ -n "$value" ]]; then
        eval "$if_just"
    else
        eval "$if_nothing"
    fi
}

# Pure Functions
set_acl() {
    local username="$1"
    local file="$2"
    local permissions="$3"
    # Check if file exists before setting ACL
    if [[ -e "$file" ]]; then
        echo "setfacl -m u:$username:$permissions $file"
    else
        echo ""  # Simulating Nothing (failure case)
    fi
}

get_acl() {
    local file="$1"
    # Check if file exists before getting ACL
    if [[ -e "$file" ]]; then
        echo "getfacl $file"
    else
        echo ""  # Simulating Nothing (failure case)
    fi
}

remove_acl() {
    local username="$1"
    local file="$2"
    # Check if file exists before removing ACL
    if [[ -e "$file" ]]; then
        echo "setfacl -x u:$username $file"
    else
        echo ""  # Simulating Nothing (failure case)
    fi
}

# Main Logic
if [ "$#" -lt 2 ]; then
    show_usage
    exit 1
fi

case "$1" in
    set)
        if [ "$#" -ne 4 ]; then
            print_message "Error: Please provide username, file/directory, and permissions."
            show_usage
            exit 1
        fi
        cmd=$(set_acl "$2" "$3" "$4")
        maybe "$cmd" \
            'print_message "$cmd"' \
            'print_message "Error: File does not exist or could not set ACL."'
        ;;
    get)
        if [ "$#" -ne 2 ]; then
            print_message "Error: Please provide file/directory."
            show_usage
            exit 1
        fi
        cmd=$(get_acl "$2")
        maybe "$cmd" \
            'print_message "$cmd"' \
            'print_message "Error: File does not exist or could not get ACL."'
        ;;
    remove)
        if [ "$#" -ne 3 ]; then
            print_message "Error: Please provide username and file/directory."
            show_usage
            exit 1
        fi
        cmd=$(remove_acl "$2" "$3")
        maybe "$cmd" \
            'print_message "$cmd"' \
            'print_message "Error: File does not exist or could not remove ACL."'
        ;;
    -h|--help)
        show_usage
        ;;
    *)
        print_message "Error: Invalid option '$1'."
        show_usage
        exit 1
        ;;
esac


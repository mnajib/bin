#!/usr/bin/env bash

# acl_manager.sh - A simple script to manage ACLs

get_script_name() {
    # Returns the name of the script without the directory
    echo "$(basename "$0")"
}

show_usage() {
    script_name=$(get_script_name)
    echo "Usage: $script_name [option] [username] [file/directory] [permissions]"
    echo
    echo "Options:"
    echo "  set    : Set ACL for a user on a specified file or directory."
    echo "            Example: $script_name set username /path/to/file rwx"
    echo "            This will grant user 'username' read, write, and execute permissions on '/path/to/file'."
    echo
    echo "  get    : Get ACL for a specified file or directory."
    echo "            Example: $script_name get /path/to/file"
    echo "            This will display the ACL for '/path/to/file'."
    echo
    echo "  remove : Remove ACL for a user on a specified file or directory."
    echo "            Example: $script_name remove username /path/to/file"
    echo "            This will remove the ACL for 'username' on '/path/to/file'."
    echo
    echo "  -h     : Show this help message."
    echo
    echo "Note:"
    echo "  Permissions can be specified as 'r' (read), 'w' (write), 'x' (execute)."
    echo "  You can combine them, e.g., 'rw' for read and write."
    echo "  Ensure the specified file or directory exists before running the commands."
}

set_acl() {
    local username="$1"
    local file="$2"
    local permissions="$3"
    setfacl -m u:"$username":"$permissions" "$file"
    echo "ACL set for user '$username' on '$file' with permissions '$permissions'."
}

get_acl() {
    local file="$1"
    getfacl "$file"
}

remove_acl() {
    local username="$1"
    local file="$2"
    setfacl -x u:"$username" "$file"
    echo "ACL removed for user '$username' on '$file'."
}

if [ "$#" -lt 2 ]; then
    show_usage
    exit 1
fi

case "$1" in
    set)
        if [ "$#" -ne 4 ]; then
            echo "Error: Please provide username, file/directory, and permissions."
            show_usage
            exit 1
        fi
        set_acl "$2" "$3" "$4"
        ;;
    get)
        if [ "$#" -ne 2 ]; then
            echo "Error: Please provide file/directory."
            show_usage
            exit 1
        fi
        get_acl "$2"
        ;;
    remove)
        if [ "$#" -ne 3 ]; then
            echo "Error: Please provide username and file/directory."
            show_usage
            exit 1
        fi
        remove_acl "$2" "$3"
        ;;
    -h|--help)
        show_usage
        ;;
    *)
        echo "Error: Invalid option '$1'."
        show_usage
        exit 1
        ;;
esac


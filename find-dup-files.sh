#!/usr/bin/env bash

function check_fdupes_exists() {
    if ! command -v fdupes &> /dev/null; then
        echo "Error: fdupes command not found. Please install it."
        exit 1
    fi
}

function check_rdfind_exists() {
    if ! command -v rdfind &> /dev/null; then
        echo "Error: rdfind command not found. Please install it."
        exit 1
    fi
}

function escape_path() {
    local path="$1"
    echo "$path" | sed 's/[[:space:]]/\\ /g'
}

function find_duplicate_files_fdupes() {
    local path="$1"
    local escaped_path=$(escape_path "$path")

    if [[ -d "$path" ]]; then
        fdupes -r "$escaped_path"
    else
        echo "$(get_function_name): Error: '$path' is not a directory or does not exist."
    fi
}

function find_duplicate_files_hash() {
    local path="$1"
    local escaped_path=$(escape_path "$path")

    if [[ -d "$path" ]]; then
        find "$escaped_path" -type f -print0 | xargs -0 sha256sum | sort | uniq -D
    else
        echo "$(get_function_name): Error: '$path' is not a directory or does not exist."
    fi
}

function find_duplicate_files_rdfind() {
    local path="$1"
    local escaped_path=$(escape_path "$path")

    if [[ -d "$path" ]]; then
        rdfind -m minimal -x size,mtime,cksum "$escaped_path"
    else
        echo "$(get_function_name): Error: '$path' is not a directory or does not exist."
    fi
}

# Main execution
check_requirements
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <directory_path> [-m method]"
    echo "  -m method: Specify the search method (fdupes, hash, rdfind)"
    exit 1
fi

path="$1"
method=""

while getopts ":m:" opt; do
    case $opt in
        m)
            method="$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument."
            exit 1
            ;;
    esac
done

case "$method" in
    fdupes)
        find_duplicate_files_fdupes "$path"
        ;;
    hash)
        find_duplicate_files_hash "$path"
        ;;
    rdfind)
        find_duplicate_files_rdfind "$path"
        ;;
    *)
        echo "Invalid search method. Please use fdupes, hash, or rdfind."
        exit 1
        ;;
esac

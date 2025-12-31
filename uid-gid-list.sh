#!/usr/bin/env bash

#
# NOTE:
#
# environment.systemPackages = [
#   (pkgs.writeShellScriptBin "check-ids" ''
#     # ... paste the script content here ...
#   '')
# ];
#

# Default Settings
MIN=400
MAX=999
SORT_BY="id"

# Help Menu
usage() {
    echo "Usage: $0 [-n] [-i]"
    echo "  -n    Sort by Name (alphabetical)"
    echo "  -i    Sort by ID (numerical) [Default]"
    exit 1
}

# Parse Flags
while getopts "ni" opt; do
    case "$opt" in
        n) SORT_BY="name" ;;
        i) SORT_BY="id" ;;
        *) usage ;;
    esac
done

# Set Sort Column based on choice
# For awk output "name: id", Name is field 1, ID is field 2
if [[ "$SORT_BY" == "name" ]]; then
    SORT_CMD="sort -k1"
else
    SORT_CMD="sort -k2 -n"
fi

echo "--- Range: $MIN-$MAX | Sorting by: $SORT_BY ---"

print_results() {
    local file=$1
    local label=$2
    echo -e "\n[$label]"
    printf "%-20s %-10s\n" "NAME" "ID"
    printf "%-20s %-10s\n" "----" "--"

    awk -F: -v min="$MIN" -v max="$MAX" \
        '$3 >= min && $3 <= max { printf "%-20s %-10s\n", $1, $3 }' "$file" | $SORT_CMD
}

print_results "/etc/passwd" "Users"
print_results "/etc/group" "Groups"

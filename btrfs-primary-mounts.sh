#!/usr/bin/env bash
#
# Btrfs Unique Mount Points Script
# List primary mount points for each Btrfs filesystem
# Demonstrates two methods to list first mount point per unique Btrfs device
#

# Method 1: Two-pass awk approach (pipeline version)
# Pros: Clear separation of concerns, easier debugging
# Cons: Slightly less efficient due to pipe
method1() {
    mount | awk '/type btrfs/ {print $1, $3}' | awk '
    {
        if (!($1 in devices)) {
            devices[$1] = $2
        }
    }
    END {
        for (device in devices) {
            print devices[device]
        }
    }'
}

# Method 2: Single-pass awk approach
# Pros: More efficient, maintains original order
# Cons: Slightly more complex awk logic
method2() {
    mount | awk '
    /type btrfs/ {
        if (!seen_devices[$1]) {
            mount_points[++count] = $3
            seen_devices[$1] = 1
        }
    }
    END {
        for (i = 1; i <= count; i++) {
            print mount_points[i]
        }
    }'
}

main() {
  # Show menu for selection
  echo "Select method:"
  echo "1) Two-pass pipeline (method1)"
  echo "2) Single-pass awk (method2)"
  echo "3) Run both for comparison"
  read -rp "Enter choice [1-3]: " choice

  # Execute selected method
  case "$choice" in
      1) method1 ;;
      2) method2 ;;
      3) 
          echo -e "\n=== Method 1 Output ==="
          method1
          echo -e "\n=== Method 2 Output ==="
          method2
          ;;
      *) echo "Invalid choice" ;;
  esac
}

#main
#method1
method2

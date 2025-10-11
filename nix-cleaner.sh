#!/usr/bin/env bash
#
# nix-cleaner.sh - List or delete derivations and generations interactively or by args
#

set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 [options]

Options:
  --list-derivations user <username>
  --list-derivations system
  --list-generations user <username>
  --list-generations system

  --delete-derivation <path>
  --delete-generation user <username> <gen-num>
  --delete-generation system <gen-num>

Interactive mode:
  --pick-derivations user <username>
  --pick-derivations system
  --pick-generations user <username>
  --pick-generations system
EOF
}

has_fzf() { command -v fzf >/dev/null 2>&1; }

human_size() {
  # Convert bytes → human readable
  local bytes="$1"
  local kib=$((1024))
  local mib=$((1024*1024))
  local gib=$((1024*1024*1024))
  if (( bytes >= gib )); then printf "%.2fG" "$(echo "$bytes/$gib" | bc -l)"
  elif (( bytes >= mib )); then printf "%.2fM" "$(echo "$bytes/$mib" | bc -l)"
  elif (( bytes >= kib )); then printf "%.2fK" "$(echo "$bytes/$kib" | bc -l)"
  else echo "${bytes}B"
  fi
}

with_size() {
  # Query closure size for each path
  while read -r path; do
    size=$(nix path-info -S "$path" 2>/dev/null | awk '{print $2}')
    if [[ -n "$size" ]]; then
      echo "$(human_size "$size") | $path"
    else
      echo "?? | $path"
    fi
  done
}

list_derivations_user() {
  local user="$1"
  nix-store --query --requisites "/nix/var/nix/profiles/per-user/$user/profile" | grep '\.drv$' | with_size
}

list_derivations_system() {
  sudo nix-store --query --requisites /nix/var/nix/profiles/system | grep '\.drv$' | with_size
}

list_generations_user() {
  local user="$1"
  nix-env --list-generations --profile "/nix/var/nix/profiles/per-user/$user/profile" \
    | while read -r gen rest; do
        path="/nix/var/nix/profiles/per-user/$user/profile-$gen-link"
        size=$(nix path-info -S "$path" 2>/dev/null | awk '{print $2}')
        echo "$(human_size ${size:-0}) | $gen | $rest"
      done
}

list_generations_system() {
  sudo nix-env --list-generations --profile /nix/var/nix/profiles/system \
    | while read -r gen rest; do
        path="/nix/var/nix/profiles/system-$gen-link"
        size=$(nix path-info -S "$path" 2>/dev/null | awk '{print $2}')
        echo "$(human_size ${size:-0}) | $gen | $rest"
      done
}

delete_derivation() {
  local drv="$1"
  echo ">>> Deleting derivation: $drv"
  sudo nix-store --delete "$drv"
}

delete_generation_user() {
  local user="$1" gen="$2"
  echo ">>> Deleting user generation: $gen for $user"
  nix-env --delete-generations -p "/nix/var/nix/profiles/per-user/$user/profile" "$gen"
}

delete_generation_system() {
  local gen="$1"
  echo ">>> Deleting system generation: $gen"
  sudo nix-env --delete-generations -p /nix/var/nix/profiles/system "$gen"
}

pick_and_delete() {
  local mode="$1" who="$2" user="${3:-}"

  case "$mode-$who" in
    derivations-user) list=$(list_derivations_user "$user") ;;
    derivations-system) list=$(list_derivations_system) ;;
    generations-user) list=$(list_generations_user "$user") ;;
    generations-system) list=$(list_generations_system) ;;
  esac

  if [[ -z "$list" ]]; then
    echo "No items found."
    exit 0
  fi

  if has_fzf; then
    selected=$(echo "$list" | fzf --multi --prompt="Select $mode to delete: ")
  else
    echo "$list" | nl -w2 -s". "
    read -rp "Enter numbers (space separated) to delete: " nums
    selected=$(echo "$list" | nl -w2 -s". " | awk -v sel="$nums" '
      BEGIN{split(sel,a)}
      {for(i in a){if($1==a[i]){for(j=2;j<=NF;j++)printf "%s ",$j; print ""}}}')
  fi

  if [[ -z "$selected" ]]; then
    echo "Nothing selected."
    exit 0
  fi

  echo ">>> You selected:"
  echo "$selected"
  read -rp "Confirm delete? (y/N): " confirm
  if [[ "$confirm" == "y" ]]; then
    while read -r line; do
      if [[ "$mode" == "derivations" ]]; then
        drv=$(echo "$line" | awk -F'|' '{print $2}' | xargs)
        delete_derivation "$drv"
      else
        gen=$(echo "$line" | awk -F'|' '{print $2}' | xargs)
        if [[ "$who" == "user" ]]; then delete_generation_user "$user" "$gen"
        else delete_generation_system "$gen"; fi
      fi
    done <<< "$selected"
  else
    echo "Aborted."
  fi
}

# ---- Main ----
if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

case "$1" in
  --list-derivations)
    if [[ "$2" == "user" ]]; then list_derivations_user "$3"
    elif [[ "$2" == "system" ]]; then list_derivations_system
    else usage; fi
    ;;
  --list-generations)
    if [[ "$2" == "user" ]]; then list_generations_user "$3"
    elif [[ "$2" == "system" ]]; then list_generations_system
    else usage; fi
    ;;
  --delete-derivation) delete_derivation "$2" ;;
  --delete-generation)
    if [[ "$2" == "user" ]]; then delete_generation_user "$3" "$4"
    elif [[ "$2" == "system" ]]; then delete_generation_system "$3"
    else usage; fi
    ;;
  --pick-derivations)
    if [[ "$2" == "user" ]]; then pick_and_delete derivations user "$3"
    elif [[ "$2" == "system" ]]; then pick_and_delete derivations system
    else usage; fi
    ;;
  --pick-generations)
    if [[ "$2" == "user" ]]; then pick_and_delete generations user "$3"
    elif [[ "$2" == "system" ]]; then pick_and_delete generations system
    else usage; fi
    ;;
  *) usage ;;
esac


#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────
# 🧭 Help
usage() {
  cat <<EOF
Usage: $0 [OPTIONS]

Options:
  --user <name>           Specify user to inspect
  --derivations-user      List user derivations
  --derivations-system    List system derivations
  --generations-user      List user generations
  --generations-system    List system generations (requires sudo)
  --prune-user            Delete old user generations
  --prune-system          Delete old system generations (requires sudo)
  --gc                    Run nix garbage collection (requires sudo)
  --all                   Show all info for user and system
  -h, --help              Show this help message

Examples:
  $0 --user alice --derivations-user
  $0 --generations-system --gc
  $0 --user bob --all --prune-user
EOF
}

# ─────────────────────────────────────────────
# 🧠 Flags
user=""
show_derivations_user=false
show_derivations_system=false
show_generations_user=false
show_generations_system=false
prune_user=false
prune_system=false
run_gc=false

# ─────────────────────────────────────────────
# 🧠 Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --user)               user="$2"; shift 2 ;;
    --derivations-user)   show_derivations_user=true; shift ;;
    --derivations-system) show_derivations_system=true; shift ;;
    --generations-user)   show_generations_user=true; shift ;;
    --generations-system) show_generations_system=true; shift ;;
    --prune-user)         prune_user=true; shift ;;
    --prune-system)       prune_system=true; shift ;;
    --gc)                 run_gc=true; shift ;;
    --all)
      show_derivations_user=true
      show_derivations_system=true
      show_generations_user=true
      show_generations_system=true
      shift
      ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

# ─────────────────────────────────────────────
# 🔍 Derivations: user
list_user_derivations() {
  echo "🔹 Derivations for user: $user"
  profile_path="/nix/var/nix/profiles/per-user/$user/profile"
  if [[ -e "$profile_path" ]]; then
    nix-store --query --deriver "$profile_path" || echo "No derivation found"
  else
    echo "Profile not found for user: $user"
  fi
  echo
}

# 🔍 Derivations: system
list_system_derivations() {
  echo "🔹 System Derivations:"
  find /nix/store -maxdepth 1 -type d -name '*-nixos-system-*' | sort
  echo
}

# 🕰️ Generations: user
list_user_generations() {
  echo "🔹 Generations for user: $user"
  profile_path="/nix/var/nix/profiles/per-user/$user/profile"
  if [[ -e "$profile_path" ]]; then
    nix profile history --profile "$profile_path" || echo "No history found"
  else
    echo "Profile not found for user: $user"
  fi
  echo
}

# 🕰️ Generations: system
list_system_generations() {
  echo "🔹 System Generations:"
  sudo ls -l /nix/var/nix/profiles/system | grep -E '^lrwxrwxrwx' | awk '{print $9, "->", $11}' || echo "Permission denied or no generations found"
  echo
}

# 🧹 Prune: user
prune_user_generations() {
  echo "🧹 Pruning old generations for user: $user"
  nix profile wipe-history --profile "/nix/var/nix/profiles/per-user/$user/profile" || echo "No history to prune"
  echo
}

# 🧹 Prune: system
prune_system_generations() {
  echo "🧹 Pruning old system generations"
  sudo nix-env --delete-generations old || echo "No old generations found"
  echo
}

# 🧹 Garbage collection
run_garbage_collection() {
  echo "🧹 Running nix garbage collection"
  sudo nix-collect-garbage -d
  echo
}

# ─────────────────────────────────────────────
# 🚀 Main
echo "📦 Nix/NixOS Scan & Cleanup"
echo "==========================="

[[ -n "$user" && $show_derivations_user == true ]] && list_user_derivations
[[ $show_derivations_system == true ]] && list_system_derivations
[[ -n "$user" && $show_generations_user == true ]] && list_user_generations
[[ $show_generations_system == true ]] && list_system_generations
[[ -n "$user" && $prune_user == true ]] && prune_user_generations
[[ $prune_system == true ]] && prune_system_generations
[[ $run_gc == true ]] && run_garbage_collection


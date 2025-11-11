#!/usr/bin/env bash

# 📜 Help message
show_help() {
  cat <<EOF
Usage:
  $0 <function> [args...]
  $0 --load <script> <function> [args...]
  $0 --list
  $0 --help

Options:
  --help        Show this help message
  --list        List available functions
  --load FILE   Load external script before dispatching

Available functions:
$(declare -F | awk '{print $3}' | grep -vE '^(_|main|show_help)$' | sed 's/^/  - /')
EOF
}

# 📋 List functions
list_functions() {
  declare -F | awk '{print $3}' | grep -vE '^(_|main|show_help)$'
}

# 🚀 Main dispatcher
main() {
  case "$1" in
    --help|-h)
      show_help
      exit 0
      ;;
    --list)
      list_functions
      exit 0
      ;;
    --load)
      shift
      script="$1"
      shift
      if [[ -f "$script" ]]; then
        source "$script"
        if declare -f "$1" > /dev/null; then
          func="$1"
          shift
          "$func" "$@"
        else
          echo "❌ Function '$1' not found in '$script'."
          exit 1
        fi
      else
        echo "❌ Script '$script' not found."
        exit 1
      fi
      ;;
    *)
      if declare -f "$1" > /dev/null; then
        func="$1"
        shift
        "$func" "$@"
      else
        echo "❌ Function '$1' not found."
        echo "Run '$0 --list' to see available functions."
        echo
        show_help
        exit 1
      fi
      ;;
  esac
}

main "$@"


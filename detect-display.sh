#!/usr/bin/env bash

print_help() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Detect active display sockets and their owning compositors (Xorg, Hyprland, XWayland), without relying on environment variables.

Options:
  --verbose       Show detailed info for each socket (path, PID, command line)
  --related       Show all processes related to each compositor, must combine with --verbose
  --rank          Show ranked display exports by compositor preference
  -h, --help      Show this help message and exit

Examples:
  $(basename "$0")                      # Show detected sockets and compositors
  $(basename "$0") --verbose            # Show full socket diagnostics
  $(basename "$0") --verbose --related  # Show full socket diagnostics, and related process
  $(basename "$0") --rank               # Show ranked display exports
EOF
}

get_x11_sockets() {
  ls /tmp/.X11-unix/X* 2>/dev/null
}

get_wayland_sockets() {
  ls /run/user/"$UID"/wayland-* 2>/dev/null | grep -v '\.lock$'
}

get_socket_info() {
  local socket="$1"
  local name pid cmdline compositor

  name=$(basename "$socket")
  pid=$(lsof -t "$socket" 2>/dev/null | head -n1)
  cmdline=$(ps -p "$pid" -o args= 2>/dev/null)

  if [[ -z "$pid" ]]; then
    compositor="Unknown"
  else
    local comm
    comm=$(ps -p "$pid" -o comm=)
    case "$comm" in
      Xorg|X) compositor="Xorg" ;;
      Xwayland) compositor="XWayland" ;;
      Hyprland) compositor="Hyprland" ;;
      *) compositor="$comm" ;;
    esac
  fi

  echo "$name|$socket|$pid|$compositor|$cmdline"
}

get_rank() {
  case "$1" in
    Xorg) echo 1 ;;
    Hyprland) echo 2 ;;
    XWayland) echo 3 ;;
    *) echo 9 ;;
  esac
}

get_related_processes() {
  local compositor="$1"
  ps -eo pid,ppid,comm,args | grep -i "$compositor" | grep -v grep
}

get_related_process_tree() {
  local compositor="$1"
  local root_pid="$2"

  local tmpfile
  tmpfile=$(mktemp)

  # Collect all processes that mention the compositor name
  #ps -eo pid=,ppid=,comm=,args= | awk -v comp="$compositor" '
  ps -eo pid=,ppid=,comm=,args= | awk -v root="$root_pid" -v comp="$compositor" '
    tolower($0) ~ tolower(comp) {
      pid=$1; ppid=$2; comm=$3;
      $1=""; $2=""; $3="";
      args=substr($0, index($0,$4));
      print pid "|" ppid "|" comm "|" args;
    }
  ' > "$tmpfile"

  declare -A proc_line
  declare -A children

  while IFS='|' read -r pid ppid comm args; do
    proc_line["$pid"]="$pid $ppid $comm $args"
    children["$ppid"]+="$pid "
  done < "$tmpfile"

  rm -f "$tmpfile"

  print_tree() {
    local parent="$1"
    local prefix="$2"
    local kids=(${children[$parent]})
    local count="${#kids[@]}"
    local i=0

    for child in "${kids[@]}"; do
      local guide="├─"
      (( i == count - 1 )) && guide="└─"
      echo "$prefix$guide ${proc_line[$child]}"
      print_tree "$child" "$prefix    "
      ((i++))
    done
  }

  # If root PID is known, start from it
  if [[ -n "$root_pid" && -n "${proc_line[$root_pid]}" ]]; then
    echo "${proc_line[$root_pid]}"
    print_tree "$root_pid" ""
  else
    # Otherwise print all matching roots
    for pid in "${!proc_line[@]}"; do
      echo "${proc_line[$pid]}"
    done
  fi
}

run_detection() {
  local verbose="${1:-0}"
  local rank="${2:-0}"
  local related="${3:-0}"
  local sockets=()
  mapfile -t x11_sockets < <(get_x11_sockets)
  mapfile -t wayland_sockets < <(get_wayland_sockets)
  sockets=("${x11_sockets[@]}" "${wayland_sockets[@]}")

  if [[ "${#sockets[@]}" -eq 0 ]]; then
    echo "⚠️  No active display sockets found."
    return 1
  fi

  if [[ "$EUID" -ne 0 ]]; then
    echo ""
    echo "⚠️  Some display sockets may be misclassified due to permission limits."
    echo "   Run with sudo to see full compositor ownership and command details."
  fi

  echo ""
  echo "🔍 Detected display sockets and owning compositors:"
  local display_map=()
  for sock in "${sockets[@]}"; do
    IFS='|' read -r name path pid compositor cmdline <<< "$(get_socket_info "$sock")"
    rank_val=$(get_rank "$compositor")
    display_map+=("$rank_val|$name|$compositor|$pid|$path|$cmdline")

    if [[ "$verbose" -eq 1 ]]; then
      echo "  - $name"
      echo "      Path      : $path"
      echo "      PID       : ${pid:-(none)}"
      echo "      Compositor: $compositor"
      echo "      Command   : ${cmdline:-(none)}"

      if [[ "$related" -eq 1 ]]; then
        echo "      Related processes:"
        #get_related_processes "$compositor" | while read -r line; do
        get_related_process_tree "$compositor" "$pid" | while read -r line; do
          echo "        $line"
        done
      fi
    else
      echo "  - $name → $compositor"
    fi
  done

  if [[ "$rank" -eq 1 ]]; then
    echo ""
    echo "🏆 Ranked display candidates:"
    IFS=$'\n' sorted=($(sort <<<"${display_map[*]}"))
    unset IFS
    for entry in "${sorted[@]}"; do
      IFS='|' read -r rank name compositor pid path cmdline <<< "$entry"
      if [[ "$name" =~ ^X([0-9]+)$ ]]; then
        echo "  export DISPLAY=:${BASH_REMATCH[1]}  # $compositor"
      else
        echo "  export DISPLAY=$name  # $compositor"
      fi
    done
  fi
}

test_get_x11_sockets() {
  echo "🧪 Testing get_x11_sockets..."
  get_x11_sockets | while read -r sock; do
    echo "  Found X11 socket: $sock"
  done
}

test_get_wayland_sockets() {
  echo "🧪 Testing get_wayland_sockets..."
  get_wayland_sockets | while read -r sock; do
    echo "  Found Wayland socket: $sock"
  done
}

test_get_socket_info() {
  echo "🧪 Testing get_socket_info..."
  local sockets=($(get_x11_sockets) $(get_wayland_sockets))
  for sock in "${sockets[@]}"; do
    IFS='|' read -r name path pid compositor cmdline <<< "$(get_socket_info "$sock")"
    echo "  $name → $compositor (PID: ${pid:-none})"
  done
}

test_get_rank() {
  echo "🧪 Testing get_rank..."
  for comp in Xorg Hyprland XWayland river unknown; do
    echo "  $comp → rank $(get_rank "$comp")"
  done
}

test_related_tree() {
  echo "🧪 Testing get_related_process_tree..."
  local sockets=($(get_x11_sockets) $(get_wayland_sockets))
  for sock in "${sockets[@]}"; do
    IFS='|' read -r name path pid compositor cmdline <<< "$(get_socket_info "$sock")"
    echo "  Tree for $name ($compositor):"
    get_related_process_tree "$compositor" "$pid" | sed 's/^/    /'
    echo ""
  done
}

main() {
  local verbose=0
  local rank=0
  local related=0

  for arg in "$@"; do
    case "$arg" in
      -h|--help)
        print_help
        return 0
        ;;
      --verbose)
        verbose=1
        ;;
      --rank)
        rank=1
        ;;
      --related)
        related=1
        ;;
      --test) test=1 ;;
      *)
        echo "❌ Unknown option: $arg"
        echo "Run with --help to see usage."
        return 1
        ;;
    esac
  done

  if [[ "$test" -eq 1 ]]; then
    test_get_x11_sockets
    test_get_wayland_sockets
    test_get_socket_info
    test_get_rank
    test_related_tree
    return
  fi

  run_detection "$verbose" "$rank" "$related"
}

main "$@"


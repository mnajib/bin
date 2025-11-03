#!/usr/bin/env bash

# ANSI colors
#RED='\033[0;31m'
#GREEN='\033[0;32m'
#YELLOW='\033[1;33m'
#BLUE='\033[0;34m'
#CYAN='\033[0;36m'
#MAGENTA='\033[0;35m'
#BOLD='\033[1m'
#RESET='\033[0m'
#--------------------------------------
# ANSI color codes (safe for most terminals)
RESET='\033[0m'
BOLD='\033[1m'

FG_RED='\033[31m'
FG_GREEN='\033[32m'
FG_YELLOW='\033[33m'
FG_BLUE='\033[34m'
FG_MAGENTA='\033[35m'
FG_CYAN='\033[36m'
FG_WHITE='\033[37m'

DIM='\033[2m'
#--------------------------------------

print_help() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Detect active display sockets and their owning compositors (Xorg, Hyprland, XWayland), without relying on environment variables.

Options:
  --verbose       Show detailed info for each socket (path, PID, command line)
  --related       Show all processes related to each compositor, must combine with --verbose
  --rank          Show ranked display exports by compositor preference
  --color         Print with colors
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
  #ps -eo pid=,ppid=,comm=,args= | awk -v root="$root_pid" -v comp="$compositor" '
  #  tolower($0) ~ tolower(comp) {
  #    pid=$1; ppid=$2; comm=$3;
  #    $1=""; $2=""; $3="";
  #    args=substr($0, index($0,$4));
  #    print pid "|" ppid "|" comm "|" args;
  #  }
  #' > "$tmpfile"
  ps -eo pid=,ppid=,comm=,args= | awk -v root="$root_pid" -v comp="$compositor" '
    tolower($0) ~ tolower(comp) || $2 == root {
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

      if [[ "$color" -eq 1 ]]; then
        guide="${FG_CYAN}${guide}${RESET}"
      #else
      #  guide="${RESET}${guide}"
      fi

      #echo "$prefix$guide ${proc_line[$child]}"
      #
      #if [[ "$color" -eq 1 ]]; then
      #  echo "$prefix$guide ${proc_line[$child]}"
      #else
      #  echo -e "${FG_BLUE}${guide}${RESET} ${proc_line[$child]}"
      #fi
      #
      echo -e "$prefix$guide ${proc_line[$child]}"

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

get_user_for_pid() {
  local pid="$1"
  ps -o user= -p "$pid" 2>/dev/null | awk '{print $1}'
}

print_pid_summary() {
  local verbose="$1"
  declare -n sockets_ref="$2"  # Pass array name by reference

  declare -A pid_to_sockets
  declare -A pid_to_compositor
  declare -A pid_to_command

  for sock in "${sockets_ref[@]}"; do
    IFS='|' read -r name path pid compositor cmdline <<< "$(get_socket_info "$sock")"
    [[ -n "$pid" ]] || continue
    pid_to_sockets["$pid"]+="$name "
    pid_to_compositor["$pid"]="$compositor"
    pid_to_command["$pid"]="$cmdline"
  done

  #echo -e "\n🧩 Compositor PID Summary:"
  echo -e "\nCompositor PID Summary:"
  for pid in "${!pid_to_sockets[@]}"; do
    local user="$(get_user_for_pid "$pid")"
    if [[ "$verbose" -eq 1 ]]; then
      echo "  $pid → ${pid_to_compositor[$pid]} → ${pid_to_command[$pid]}"
      echo "    User   : ${user:-unknown}"
      echo "    Sockets: ${pid_to_sockets[$pid]}"
    else
      echo "  PID $pid (${pid_to_compositor[$pid]}, user: ${user:-unknown}) serves: ${pid_to_sockets[$pid]}"
    fi
  done
}

add_unmapped_socket() {
  local name="$1"
  local path="$2"
  declare -n current_map="$3"

  # Create a copy
  declare -A updated_map
  for key in "${!current_map[@]}"; do
    updated_map["$key"]="${current_map[$key]}"
  done

  # Add new entry
  updated_map["$name"]="$path"

  # Print updated map as key=value pairs
  for key in "${!updated_map[@]}"; do
    echo "$key=${updated_map[$key]}"
  done
}

print_unmapped_sockets() {
  declare -n socket_map="$1"

  if (( ${#socket_map[@]} > 0 )); then
    echo -e "\nUnmapped display sockets:"
    for name in "${!socket_map[@]}"; do
      echo "  - $name → ${socket_map[$name]}"
    done
    echo "    These sockets exist but could not be mapped to a compositor process."
    echo "    Try running with sudo to see full ownership details."
  fi
}

run_detection() {
  local verbose="${1:-0}"
  local rank="${2:-0}"
  local related="${3:-0}"
  local color="${4:-0}"

  # Phase 1: Initialization
  declare -A pid_to_sockets pid_to_compositor pid_to_command unmapped_sockets
  local sockets=()
  mapfile -t x11_sockets < <(get_x11_sockets)
  mapfile -t wayland_sockets < <(get_wayland_sockets)
  sockets=("${x11_sockets[@]}" "${wayland_sockets[@]}")

  if [[ "${#sockets[@]}" -eq 0 ]]; then
    echo "No active display sockets found."
    return 1
  fi

  if [[ "$EUID" -ne 0 ]]; then
    echo -e "\nSome display sockets may be misclassified due to permission limits."
    echo "  Run with sudo to see full compositor ownership and command details."
  fi

  # Phase 2: Socket Classification
  echo -e "\nDetected display sockets and owning compositors:"
  local display_map=()

  for sock in "${sockets[@]}"; do
    IFS='|' read -r name path pid compositor cmdline <<< "$(get_socket_info "$sock")"

    if [[ -n "$pid" ]]; then
      # Group by PID
      pid_to_sockets["$pid"]+="${pid_to_sockets[$pid]:+, }$name"
      [[ -z "${pid_to_compositor[$pid]}" ]] && pid_to_compositor["$pid"]="$compositor"
      [[ -z "${pid_to_command[$pid]}" ]] && pid_to_command["$pid"]="$cmdline"
    else
      # Track unmapped sockets immutably
      while IFS='=' read -r k v; do
        unmapped_sockets["$k"]="$v"
      done < <(add_unmapped_socket "$name" "$path" unmapped_sockets)
    fi

    # Build display map for ranking
    rank_val=$(get_rank "$compositor")
    display_map+=("$rank_val|$name|$compositor|$pid|$path|$cmdline")

    # Verbose or concise output
    if [[ "$verbose" -eq 1 ]]; then
      echo "  - $name"
      echo "      Path      : $path"
      echo "      PID       : ${pid:-(none)}"
      echo "      Compositor: $compositor"
      echo "      Command   : ${cmdline:-(none)}"
      if [[ "$related" -eq 1 ]]; then
        echo "      Related processes:"
        get_related_process_tree "$compositor" "$pid" | while read -r line; do
          echo "        $line"
        done
      fi
    else
      echo "  - $name → $compositor"
    fi
  done

  # Phase 3: Unmapped Socket Summary
  print_unmapped_sockets unmapped_sockets

  # Phase 4: Compositor PID Summary
  print_pid_summary "$verbose" sockets

  # Phase 5: Ranked Display Output
  if [[ "$rank" -eq 1 ]]; then
    echo -e "\nRanked display candidates:"
    IFS=$'\n' sorted=($(sort <<<"${display_map[*]}"))
    unset IFS
    for entry in "${sorted[@]}"; do
      IFS='|' read -r rank name compositor pid path cmdline <<< "$entry"
      if [[ "$name" =~ ^X([0-9]+)$ ]]; then
        [[ "$color" -eq 1 ]] \
          && echo -e "  export DISPLAY=${FG_CYAN}:${BASH_REMATCH[1]}${RESET}  # ${FG_MAGENTA}${compositor}${RESET}" \
          || echo "  export DISPLAY=:${BASH_REMATCH[1]}  # $compositor"
      else
        [[ "$color" -eq 1 ]] \
          && echo -e "  export DISPLAY=${FG_CYAN}${name}${RESET}  # ${FG_MAGENTA}${compositor}${RESET}" \
          || echo "  export DISPLAY=$name  # $compositor"
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
  local color=0

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
      --color) color=1 ;;
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

  run_detection "$verbose" "$rank" "$related" "$color"
}

main "$@"


#!/usr/bin/env bash

# Function to display help message
display_help() {
  local script_name=$(basename "$0") # Get the script name without the path

  echo "Usage: $script_name start {server|client} [options]"
  echo
  echo "Commands:"
  echo "  server            Start the Barrier server."
  echo "  client            Start the Barrier client."
  echo
  echo "Options for server:"
  echo "  --server <hostname>        The hostname of the server."
  echo "  --config-file <path>       Path to the server configuration file."
  echo
  echo "Options for client:"
  echo "  --client <hostname>        The name of the client."
  echo "  --server <hostname>        The hostname or IP address of the server."
  echo
  echo "Example:"
  echo "   ~/bin/barrier-launcher.sh start server --server khadijah --config-file ~/.config/barrier/barrier-khadijah.conf"
  exit 0
}

# Function to run the Barrier client
run_client() {
  local client="$1"   # Client hostname
  local server="$2"   # Server hostname or IP address

  if [[ "$client" == "khadijah" ]]; then
    #export DISPLAY=:1
    DISPLAY=:1 barrierc --no-daemon --disable-crypto --restart --name "$client" "$server"
  else
    # Execute the Barrier client with specified options
    barrierc --no-daemon --disable-crypto --restart --name "$client" "$server"
  fi
}

# Function to run the Barrier server
run_server() {
  local server="$1"               # Server hostname
  local server_config_file="$2"   # Path to the server config file

  # Execute the Barrier server with specified options
  barriers --no-daemon --name "$server" --restart --disable-crypto --config "${server_config_file}"
}

# Function to validate input parameters for starting a server
validate_server_input() {
  local server_name="$1"
  local config_file="$2"

  if [[ -z "$server_name" || -z "$config_file" ]]; then
    display_help
    return 1 # Indicate failure (Nothing)
  fi

  return 0 # Indicate success (Just)
}

# Function to validate input parameters for starting a client
validate_client_input() {
  local client_name="$1"
  local server_name="$2"

  if [[ -z "$client_name" || -z "$server_name" ]]; then
    display_help
    return 1 # Indicate failure (Nothing)
  fi

  return 0 # Indicate success (Just)
}

# Function to handle optional values (simulating Maybe monad)
maybe() {
  local value="$1"

  if [[ -z "$value" ]]; then
    echo "Error: Expected value, but got None."
    return 1 # Indicate failure (Nothing)
  else
    echo "$value" # Just return the value (Just value)
    return 0     # Indicate success (Just)
  fi
}

# Main function to orchestrate the execution based on command and options
main() {
  if [[ $# -lt 3 ]]; then
    display_help
    exit 1
  fi

  local command="$1"

  case "$command" in
    start)
      local mode="$2"
      shift 2

      case "$mode" in
        server)
          local server_name=""
          local config_file=""

          while [[ $# -gt 0 ]]; do
            case "$1" in
              --server)
                shift
                server_name="$1"
                ;;
              --config-file)
                shift
                config_file="$1"
                ;;
              *)
                display_help
                exit 1
                ;;
            esac
            shift
          done

          validate_server_input "$server_name" "$config_file" || exit 1

          # Check if config file exists using Maybe-like handling and run the server in background.
          maybe "$config_file" || exit 1

          run_server "$server_name" "$config_file" &
          ;;

        client)
          local client_name=""
          local server_name=""

          while [[ $# -gt 0 ]]; do
            case "$1" in
              --client)
                shift
                client_name="$1"
                ;;
              --server)
                shift
                server_name="$1"
                ;;
              *)
                display_help
                exit 1
                ;;
            esac
            shift
          done

          validate_client_input "$client_name" "$server_name" || exit 1

          # Start the client after a short delay to ensure the server is up (if applicable).
          sleep 2
          run_client "$client_name" "$server_name"
          ;;

        *)
          display_help
          exit 1
          ;;
      esac

      ;;

    *)
      display_help
      exit 1
      ;;

  esac

}

# Entry point of the script
main "$@"


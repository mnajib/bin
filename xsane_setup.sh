#!/usr/bin/env bash

LAUNCHER="$HOME/bin/xsane_launcher.sh"
DOTDESKTOP="$HOME/.local/share/applications/xsane-launcher.desktop"

# Function to display help message
display_help() {
    echo "Usage: $0 [options]"
    echo
    echo "This script sets up a launcher for XSane, a scanner application."
    echo
    echo "Options:"
    echo "  -h, --help      Display this help message."
    echo
    echo "After running this script, you can launch XSane from your application menu or by running:"
    echo "  $LAUNCHER"
    exit 0
}

# Function to check if xsane is installed
check_xsane() {
    if ! command -v xsane &> /dev/null; then
        echo "Error: xsane is not installed. Please install it first."
        return 1
    fi
    echo "XSane is installed."
    return 0
}

# Function to check if the user is part of the scanner group
check_scanner_group() {
    if ! groups "$USER" | grep -q "\bscanner\b"; then
        echo "You are not part of the 'scanner' group. Adding you to the group..."
        sudo usermod -aG scanner "$USER"
        echo "You need to log out and log back in for the changes to take effect."
        return 1
    fi
    echo "You are part of the 'scanner' group."
    return 0
}

# Function to get the available scanner devices
get_scanner_devices() {
  #echo $(scanimage -L | grep -oP "\`[^\`]+\'" | sed 's/^`//' | sed "s/'$//)
  echo $(scanimage -L | grep -oP "\`[^\`]+\'" | sed "s/^\`//;s/'$//")
}

# Function to prompt the user to select a scanner device
get_scanner_device() {
    devices=($(get_scanner_devices))
    if [ ${#devices[@]} -eq 0 ]; then
        echo "No scanner device found. Please check your scanner connection."
        return 1
    fi

    echo "Available scanner devices:"
    for i in "${!devices[@]}"; do
        echo "$((i + 1))) ${devices[$i]}"
    done

    read -p "Select a device by number (1-${#devices[@]}): " choice
    if [[ "$choice" -ge 1 && "$choice" -le ${#devices[@]} ]]; then
        echo "${devices[$((choice - 1))]}"
        #return 0
    else
        echo "Invalid selection."
        return 1
    fi
}

#select_scanner_device() {
#}

# Function to create the launcher script
create_launcher_script() {
    #LAUNCHER_SCRIPT="$HOME/launch_xsane.sh"
    #local LAUNCHER_SCRIPT="$LAUNCHER"
    local LAUNCHER_SCRIPT="$1"
    local SCANNER_DEVICE=$(select_scanner_device)

    # Create launcher script with proper error handling and comments.
    {
        echo "#!/bin/bash"
        echo ""
        echo "# Check if a device argument is provided"
        echo "if [ \"\$#\" -eq 1 ]; then"
        echo "    DEVICE=\"\$1\""
        echo "#else"
        echo "#    DEVICE=\"\$(get_scanner_device)\""
        echo "esle"
        echo "     DEVICE=\"${SCANNER_DEVICE}\""
        echo "fi"
        echo ""
        echo "# Launch XSane with the selected device"
        echo "[ -n \"\$DEVICE\" ] && xsane -d \"\$DEVICE\" || { echo 'No device selected. Exiting.'; exit 1; }"
    } > "$LAUNCHER_SCRIPT"

    chmod +x "$LAUNCHER_SCRIPT"
    echo "Launcher script created at $LAUNCHER_SCRIPT."
}

# Function to create the desktop entry
create_desktop_entry() {
    #DESKTOP_ENTRY="$HOME/.local/share/applications/xsane-launcher.desktop"
    #local DESKTOP_ENTRY="$DOTDESKTOP"
    local DESKTOP_ENTRY="$1"

    # Create desktop entry with error handling.
    {
        echo "[Desktop Entry]"
        echo "Name=XSane Scanner"
        echo "Exec=$HOME/launch_xsane.sh"
        echo "Type=Application"
        echo "Terminal=false"
        echo "Icon=xsane"
        echo "Categories=Graphics;Scanner;"
    } > "$DESKTOP_ENTRY"

    chmod +x "$DESKTOP_ENTRY"
    echo "Desktop entry created at $DESKTOP_ENTRY."
}

# Function to run all default functions and handle errors.
run_all() {
    check_xsane || exit 1
    check_scanner_group || exit 1

    create_launcher_script "$LAUNCHER" || exit 1
    create_desktop_entry "$DOTDESKTOP" || exit 1

    echo "All setup tasks completed successfully."
}

# Function to display the menu and handle user choices.
display_menu() {
    while true; do
        clear
        echo "Select an option:"
        echo "1) Check if XSane is installed"
        echo "2) Check if you are in the 'scanner' group"
        echo "3) Create launcher script for XSane"
        echo "4) Create desktop entry for XSane launcher"
        echo "5) Run all setup tasks"
        echo "6) Exit"

        read -p "Enter your choice [1-6]: " choice

        case $choice in
            1) check_xsane ;;
            2) check_scanner_group ;;
            3) create_launcher_script "$LAUNCHER" ;;
            4) create_desktop_entry "$DOTDESKTOP" ;;
            5) run_all ;;
            6) exit 0 ;;
            *)
                echo "Invalid choice. Please select a number between 1 and 6." 
                sleep 2
                ;;
        esac

        read -p "Press Enter to continue..."
    done
}

# Main script execution starts here.
if [[ $1 == "-h" || $1 == "--help" ]]; then
   display_help
fi

display_menu

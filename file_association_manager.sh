#!/usr/bin/env bash

# Define the path to the mimeapps.list file
mimeapps_file="$HOME/.config/mimeapps.list"

# Function to set default application for a MIME type
set_default_app() {
    mime_type=$1
    app_desktop_file=$2

    # Check if the mimeapps.list file exists
    if [ ! -f "$mimeapps_file" ]; then
        echo "[Default Applications]" > "$mimeapps_file"
    fi

    # Set the default application for the MIME type
    sed -i "/^\[$mime_type\]/d" "$mimeapps_file"
    echo "[$mime_type]" >> "$mimeapps_file"
    echo "default=$app_desktop_file" >> "$mimeapps_file"
    echo "Default application for $mime_type set to $app_desktop_file"
}

# Function to list all MIME types
list_mime_types() {
    echo "Listing all MIME types:"
    echo "-----------------------"
    grep -o '^\[[^]]*\]' "$mimeapps_file" | tr -d '[]'
}

# Main menu
echo "File Association Manager"
echo "-----------------------"
echo "1. Set Default Application"
echo "2. List All MIME Types"
echo "3. Exit"

read -p "Enter your choice: " choice

case $choice in
    1)
        read -p "Enter MIME type (e.g., application/pdf): " mime_type
        read -p "Enter desktop file for the application (e.g., evince.desktop): " app_desktop_file
        set_default_app "$mime_type" "$app_desktop_file"
        ;;
    2)
        list_mime_types
        ;;
    3)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid choice. Exiting..."
        exit 1
        ;;
esac

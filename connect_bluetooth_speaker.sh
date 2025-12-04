#!/usr/bin/env bash

# Define your Bluetooth device
DEVICE="AD:6E:44:0D:92:C0"

# Unblock Bluetooth
rfkill unblock all

# Start Bluetooth control
{
    echo "power on"
    echo "agent on"
    echo "scan on"
    sleep 5  # Allow some time for scanning
    echo "pair $DEVICE"
    sleep 5  # Wait for pairing to complete
    echo "connect $DEVICE"
    echo "trust $DEVICE"
    echo "exit"
} | bluetoothctl

echo "Attempted to connect to device $DEVICE."


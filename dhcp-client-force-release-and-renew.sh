#!/usr/bin/env bash
#
# Command to release/renew a DHCP IP address in Linux
#
#ip a                                             # Get ip address and interface information on Linux
#ip a s eth0                                      # Find the current ip address for the eth0 interface in Linux
#

# Method #1
#dhclient -v -r eth0                              # Force Linux to renew IP address using a DHCP for eth0 interface

# Method #2
#systemctl restart network.service                # Restart networking service and obtain a new IP address via DHCP on Ubuntu/Debian Linux
#systemctl restart networking.service             # Restart networking service and obtain a new IP address via DHCP on a CentOS/RHEL/Fedora Linux

# Method #3
#nmcli con                                        # Use NetworkManager to obtain info about Linux IP address and interfaces
#nmcli con down id 'enp6s0'                       # Take down Linux interface enp6s0 and release IP address in Linux
#nmcli con up id 'enp6s0'                         # Obtain a new IP address for Linux interface enp6s0 and release IP address using DHCP

# Method #4
#sudo dhcpcd -k                                   # Use the dhcpcd as the client to obtain a new release
#sudo dhcpcd                                      # Get the new one.
#sudo dhcpcd -k eth0 && dhcpcd -n eth0            # Get a new IP address for Linux interface called eth0 and release IP address using the dhcpcd as the client.

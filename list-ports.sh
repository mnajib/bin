#!/usr/bin/env bash

#echo "--- Listening TCP/UDP Ports ---"
## -t (TCP), -u (UDP), -l (Listening), -n (Numeric ports), -p (Show Process)
#sudo ss -tunlp | grep LISTEN
#
#echo -e "\n--- Open Unix Domain Sockets ---"
## -x (Unix Sockets)
#sudo ss -xlnp

# Function to print section headers in bold
print_header() {
    echo -e "\n\e[1;34m>>> $1\e[0m"
}

print_header "TCP & UDP LISTENING PORTS"
# Uses awk to print the header (NR==1) OR lines containing LISTEN
sudo ss -tunlp | awk 'NR==1 || /LISTEN/' | column -t

print_header "UNIX DOMAIN SOCKETS (LISTENING)"
# -x for unix, -l for listening, -p for process
sudo ss -xlnp | awk 'NR==1 || /LISTEN/' | column -t

# This shows ports NixOS has explicitly opened in iptables/nftables
print_header "PORTS ON RUNTIME FIREWALL"
sudo nft list ruleset | grep -E 'tcp|udp'

#!/usr/bin/env bash

echo "--- Listening TCP/UDP Ports ---"
# -t (TCP), -u (UDP), -l (Listening), -n (Numeric ports), -p (Show Process)
sudo ss -tunlp | grep LISTEN

echo -e "\n--- Open Unix Domain Sockets ---"
# -x (Unix Sockets)
sudo ss -xlnp

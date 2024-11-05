#!/bin/bash

INTERFACE="eth0"

# Directories for PCAP and scan results
PCAP_DIR="/tmp/pcap_vuln_hosts"
SCAN_DIR="/tmp/vuln_hosts"

mkdir -p "$PCAP_DIR"
mkdir -p "$SCAN_DIR"

# File containing the list of hosts to scan
HOST_DISCOVERY_FILE="/tmp/port_scan/active_hosts.txt"
if [ ! -s "$HOST_DISCOVERY_FILE" ]; then
    echo "No active hosts found in $HOST_DISCOVERY_FILE. Exiting."
    exit 1
fi

echo "Discovered hosts for detailed vulnerability scanning:"
cat "$HOST_DISCOVERY_FILE"
echo ""

# Function to run vulnerability scans with a timeout
run_vuln_scan () {
    HOST=$1
    SCAN_NAME="vuln_scan_$HOST"

    echo "Starting Wireshark capture for $SCAN_NAME on $INTERFACE..."
    tshark -i $INTERFACE -w "$PCAP_DIR/capture_$SCAN_NAME.pcap" &
    WS_PID=$!

    sleep 2  # Give tshark time to start

    echo "Running detailed Nmap vulnerability scan on $HOST..."
    timeout 300 nmap -O -sV -sC $HOST -oX "$SCAN_DIR/$SCAN_NAME.xml"

    # Check if Nmap scan completed successfully or timed out
    if [ $? -eq 124 ]; then
        echo "Warning: Nmap scan $SCAN_NAME timed out after 5 minutes."
    else
        echo "Nmap scan $SCAN_NAME completed successfully."
    fi

    # Stop Wireshark capture
    echo "Stopping Wireshark capture for $SCAN_NAME on host $HOST..."
    kill $WS_PID
    echo "Capture saved to $PCAP_DIR/capture_$SCAN_NAME.pcap"
}

# Loop through each discovered host and perform vulnerability scans with timeout
for HOST in $(cat "$HOST_DISCOVERY_FILE"); do
    run_vuln_scan $HOST
done

echo "All vulnerability scans completed. Results and captures are saved in $SCAN_DIR and $PCAP_DIR respectively."

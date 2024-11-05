#!/bin/bash

# Check if a host IP was provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <host_IP>"
    exit 1
fi

# Define the target host from the argument
HOST=$1
INTERFACE="eth0"

# Directories for PCAP and scan results
PCAP_DIR="/tmp/pcap_vuln_hosts"
SCAN_DIR="/tmp/vuln_hosts"

# Create directories for PCAP and scan results
mkdir -p "$PCAP_DIR"
mkdir -p "$SCAN_DIR"

echo "Target host for detailed vulnerability scan: $HOST"

# Function to run a detailed Nmap vulnerability scan
run_vuln_scan () {
    SCAN_NAME="vuln_scan_single_$HOST"

    echo "Starting Wireshark capture for $SCAN_NAME on $INTERFACE..."
    tshark -i $INTERFACE -w "$PCAP_DIR/capture_${SCAN_NAME}.pcap" &
    WS_PID=$!

    sleep 2  # Ensure tshark is ready

    echo "Running detailed Nmap vulnerability scan on $HOST with a 3-minute timeout..."
    timeout 180 nmap -O -sV -sC $HOST -oX "$SCAN_DIR/${SCAN_NAME}.xml"

    if [ $? -eq 124 ]; then
        echo "Warning: Nmap vulnerability scan on $HOST timed out after 3 minutes."
    else
        echo "Nmap vulnerability scan on $HOST completed successfully."
    fi

    echo "Stopping Wireshark capture for $SCAN_NAME on host $HOST..."
    kill $WS_PID
    echo "Capture saved to $PCAP_DIR/capture_${SCAN_NAME}.pcap"
}

# Run the vulnerability scan function for the single target host
run_vuln_scan

echo "Vulnerability scan for $HOST completed, with captures saved in $PCAP_DIR"

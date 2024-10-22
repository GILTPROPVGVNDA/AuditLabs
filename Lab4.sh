#!/bin/bash

INTERFACE="eth0"

# Set directories for PCAP and scan results
PCAP_DIR="/tmp/pcap_vuln_hosts"
SCAN_DIR="/tmp/vuln_hosts"

# Create directories for PCAP and scan results
mkdir -p "$PCAP_DIR"
mkdir -p "$SCAN_DIR"

# Check for the existence of the discovered hosts file
HOST_DISCOVERY_FILE="/tmp/port_scan/active_hosts.txt"
if [ ! -s "$HOST_DISCOVERY_FILE" ]; then
    echo "No active hosts found in $HOST_DISCOVERY_FILE. Exiting."
    exit 1
fi

echo "Discovered hosts for detailed vulnerability scanning:"
cat "$HOST_DISCOVERY_FILE"
echo ""

# Function to run detailed vulnerability scans
run_vuln_scan () {
    HOST=$1
    SCAN_NAME="vuln_scan_$HOST"

    echo "Starting Wireshark capture for $SCAN_NAME on $INTERFACE..."
    tshark -i $INTERFACE -w "$PCAP_DIR/capture_$SCAN_NAME.pcap" &
    WS_PID=$!

    sleep 2  # Ensure tshark is running

    echo "Running detailed Nmap vulnerability scan on $HOST..."
    sudo nmap -O -sV -sC $HOST -oX "$SCAN_DIR/$SCAN_NAME.xml"

    # Stop Wireshark capture
    echo "Stopping Wireshark capture for $SCAN_NAME on host $HOST..."
    kill $WS_PID
    echo "Capture saved to $PCAP_DIR/capture_$SCAN_NAME.pcap"
}

# Loop through each discovered host and perform vulnerability scans
for HOST in $(cat "$HOST_DISCOVERY_FILE"); do
    run_vuln_scan $HOST
done

echo "All vulnerability scans completed and separate captures saved in $PCAP_DIR"

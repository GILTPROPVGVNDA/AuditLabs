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
PCAP_DIR="/tmp/port_pcap"
SCAN_DIR="/tmp/port_scan"

# Create directories for PCAP and scan results
mkdir -p "$PCAP_DIR"
mkdir -p "$SCAN_DIR"

echo "Target host: $HOST"

# Function to run Nmap port scans
run_nmap_port_scan () {
    SCAN_FLAG=$1
    SCAN_NAME=$2

    echo "Starting Wireshark capture for ${SCAN_NAME}_single on $HOST..."
    tshark -i $INTERFACE -w "$PCAP_DIR/capture_${SCAN_NAME}_single_$HOST.pcap" &
    WS_PID=$!

    sleep 2  # Ensure tshark is ready

    echo "Running Nmap port scan ($SCAN_FLAG) on $HOST..."
    timeout 30 nmap $SCAN_FLAG -p- $HOST -oX "$SCAN_DIR/${SCAN_NAME}_single_$HOST.xml"

    if [ $? -eq 124 ]; then
        echo "Warning: Nmap scan $SCAN_NAME on $HOST timed out after 30 seconds."
    else
        echo "Nmap scan $SCAN_NAME on $HOST completed successfully."
    fi

    echo "Stopping Wireshark capture for ${SCAN_NAME}_single on $HOST..."
    kill $WS_PID
    echo "Capture saved to $PCAP_DIR/capture_${SCAN_NAME}_single_$HOST.pcap"
}

# Run scans with different flags for the single target host
run_nmap_port_scan "-sS" "scan_sS"
run_nmap_port_scan "-sT" "scan_sT"
run_nmap_port_scan "-sU" "scan_sU"
run_nmap_port_scan "-sY" "scan_sY"
run_nmap_port_scan "-sN" "scan_sN"
run_nmap_port_scan "-sF" "scan_sF"
run_nmap_port_scan "-sX" "scan_sX"
run_nmap_port_scan "-sA" "scan_sA"
run_nmap_port_scan "-sW" "scan_sW"
run_nmap_port_scan "-sM" "scan_sM"
run_nmap_port_scan "-sZ" "scan_sZ"
run_nmap_port_scan "-sO" "scan_sO"

echo "All port scans for $HOST completed and captures saved in $PCAP_DIR"

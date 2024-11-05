#!/bin/bash

INTERFACE="eth0"

# Set the directories for PCAP and scan results
PCAP_DIR="/tmp/port_pcap"
SCAN_DIR="/tmp/port_scan"

# Create directories for PCAP and scan results
mkdir -p "$PCAP_DIR"
mkdir -p "$SCAN_DIR"

# File to store discovered hosts
HOST_DISCOVERY_FILE="$SCAN_DIR/active_hosts.txt"
echo "Performing fast host discovery scan in the range 10.0.2.0/24..."
nmap -sn 10.0.2.0/24 -T5 | awk '/Nmap scan report/{print $NF}' > "$HOST_DISCOVERY_FILE"

# Check if any hosts were found
if [ ! -s "$HOST_DISCOVERY_FILE" ]; then
    echo "No active hosts found. Exiting."
    exit 1
fi

echo "Discovered hosts:"
cat "$HOST_DISCOVERY_FILE"
echo ""

# Function to run Nmap port scans with a 5-minute timeout
run_nmap_port_scan () {
    SCAN_FLAG=$1
    SCAN_NAME=$2
    HOST=$3

    echo "Starting Wireshark capture for $SCAN_NAME on host $HOST..."
    tshark -i $INTERFACE -w "$PCAP_DIR/capture_${SCAN_NAME}_$HOST.pcap" &
    WS_PID=$!

    sleep 2  # Ensure tshark is ready

    echo "Running Nmap port scan ($SCAN_FLAG) on $HOST with a 5-minute timeout..."
    timeout 300 nmap $SCAN_FLAG -p- $HOST -oX "$SCAN_DIR/${SCAN_NAME}_$HOST.xml"

    # Check if the scan completed successfully or timed out
    if [ $? -eq 124 ]; then
        echo "Scan $SCAN_NAME on $HOST exceeded 5 minutes and was skipped."
    else
        echo "Scan $SCAN_NAME on $HOST completed successfully."
    fi

    # Stop Wireshark capture
    echo "Stopping Wireshark capture for $SCAN_NAME on host $HOST..."
    kill $WS_PID
    echo "Capture saved to $PCAP_DIR/capture_${SCAN_NAME}_$HOST.pcap"
}

# Loop through each discovered host and perform port scans
for HOST in $(cat "$HOST_DISCOVERY_FILE"); do
    run_nmap_port_scan "-sS" "scan_sS" $HOST
    run_nmap_port_scan "-sT" "scan_sT" $HOST
    run_nmap_port_scan "-sU" "scan_sU" $HOST
    run_nmap_port_scan "-sY" "scan_sY" $HOST
    run_nmap_port_scan "-sN" "scan_sN" $HOST
    run_nmap_port_scan "-sF" "scan_sF" $HOST
    run_nmap_port_scan "-sX" "scan_sX" $HOST
    run_nmap_port_scan "-sA" "scan_sA" $HOST
    run_nmap_port_scan "-sW" "scan_sW" $HOST
    run_nmap_port_scan "-sM" "scan_sM" $HOST
    run_nmap_port_scan "-sZ" "scan_sZ" $HOST
    run_nmap_port_scan "-sO" "scan_sO" $HOST
done

echo "All port scans completed and separate captures saved in $PCAP_DIR"

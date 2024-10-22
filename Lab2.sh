#!/bin/bash

INTERFACE="eth0"

PCAP_DIR="/tmp/pcap_dir"
SCAN_DIR="/tmp/scan_dir"

mkdir -p "$PCAP_DIR"
mkdir -p "$SCAN_DIR"

run_nmap_scan () {
    SCAN_NAME=$2

    echo "Starting Wireshark capture for $SCAN_NAME on $INTERFACE..."
    sudo tshark -i $INTERFACE -w "$PCAP_DIR/capture_$SCAN_NAME.pcap" &
    WS_PID=$!

    sleep 2  

    echo "Running Nmap scan: $SCAN_NAME"
    sudo nmap 10.0.2.0/24 $1 -oX "$SCAN_DIR/$SCAN_NAME.xml"
    
    if [ $? -eq 0 ]; then
        echo "Nmap scan $SCAN_NAME completed successfully."
    else
        echo "Error: Nmap scan $SCAN_NAME failed."
    fi

    echo "Stopping Wireshark capture for $SCAN_NAME..."
    sudo kill $WS_PID

    if [ $? -eq 0 ]; then
        echo "Capture saved to $PCAP_DIR/capture_$SCAN_NAME.pcap"
    else
        echo "Error: Could not stop Wireshark or save the capture."
    fi
}

run_nmap_scan "-sL" "skan_sL"
run_nmap_scan "-sP" "skan_sP"
run_nmap_scan "-P0" "skan_P0"
run_nmap_scan "-PE" "skan_PE"
run_nmap_scan "-PP" "skan_PP"
run_nmap_scan "-PM" "skan_PM"
run_nmap_scan "-PR" "skan_PR"
run_nmap_scan "-n" "skan_n"
run_nmap_scan "-R" "skan_R"
run_nmap_scan "--system-dns" "skan_sysdns"
run_nmap_scan "--dns-servers 9.9.9.9" "skan_dns9999"
run_nmap_scan "--disable-arp-ping" "skanNoArp"

echo "All scans completed and separate captures saved in $PCAP_DIR"

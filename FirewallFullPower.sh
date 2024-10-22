#!/bin/bash


sudo iptables -F
sudo iptables -X
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT DROP

echo "All firewall rules have been blocked. Default policies are set to DROP."

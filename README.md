# AuditLabs
## Skryty do wykonania Lab2, Lab3 oraz Lab4
*Skrypty wykorzystują Nmap do skanowania oraz tshark do zbierania pakietów*

- Skrypty przygotowane są dla sieci 10.0.2.0/24.
- Aby uruchomić dany skrypt należy mu nadać uprawnienia chmod +x
- najlepiej uruchomić skrypt z uprawnieniami sudoera (nie koniecznie sudo, wystarczy uzytkownik)

Wyniki są zapisane w następującej postaci:
```
/tmp/
├── pcap_dir/                 
│   └── [Przechwytywania z Lab2]
│
├── scan_dir/                  
│   └── [skany z Lab2]
│
├── port_pcap/                 
│   └── [Przechwytywania z Lab3]
│
├── port_scan/                 
│   └── [skany z Lab3]
│
└── vuln_hosts/                
    └── [Przechwytywania i wyniki z Lab4]
```
Przydatne komendy:
Włączenie całkowitego firewalla Windows (PowerShell):

```netsh advfirewall set allprofiles firewallpolicy blockinbound,blockoutbound```

Włączenie całkowitego firewalla Linux (Bash):
```
sudo iptables -F
sudo iptables -P INPUT DROP
sudo iptables -P OUTPUT DROP
sudo iptables -P FORWARD DROP
```

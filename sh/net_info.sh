#!/bin/bash

# Title and IP Addresses
echo -e "\e[1;34mYour IP Addresses:\e[0m"
ip -4 addr show | grep -oP '(?<=inet\s)\d+\.\d+\.\d+\.\d+' | grep -v "127.0.0.1" | while read ip; do
    echo -e "\e[1;32m- $ip\e[0m"
done

echo ""

# Title and Open Ports
echo -e "\e[1;34mOpen Ports:\e[0m"
netstat -tuln | grep -E '0.0.0.0|([0-9]{1,3}\.){3}[0-9]{1,3}' | awk '{print $4}' | cut -d':' -f2 | sort -n | uniq | while read port; do
    echo -e "\e[1;32m- $port\e[0m"
done

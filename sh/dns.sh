#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

clear

clear_dns_cache()
{
    PS3='Clear DNS cache: '
    options=("Yes" "No")
    select opt in "${options[@]}"
    do
        case $opt in
            "Yes")
                sudo killall -HUP mDNSResponder
                echo -e "${GREEN}DNS cache has been flushed${NC}"
                break
                ;;
            "No")
                echo -e "${RED}Skipped${NC}"
                break
                ;;
        esac
    done
}

banner()
{
  echo "+------------------------------------------+"
  printf "| %-40s |\n" "`date`"
  echo "|                                          |"
  printf "|`tput bold` %-40s `tput sgr0`|\n" "$@"
  echo "+------------------------------------------+"
}

banner "DNS Updater v0.1"
sleep 1
printf "\n"

echo -e "${YELLOW}Network Services${NC}"
networksetup -listallnetworkservices
printf "\n"

echo -e "${YELLOW}Current DNS servers${NC}"
networksetup -getdnsservers Wi-Fi
printf "\n"

PS3='Select DNS server: '

options=("Google" "Cloudflare" "Opendns" "Quad9" "Neustar" "SafeDNS" "Verisign" "Comodo" "DNSwatch" "Dyn" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Google")
            networksetup -setdnsservers Wi-Fi 8.8.8.8 8.8.4.4
            echo -e "${GREEN}DNS updated${NC}"
            clear_dns_cache
            break
            ;;
        "Cloudflare")
            networksetup -setdnsservers Wi-Fi 1.1.1.1 1.0.0.1
            echo -e "${GREEN}DNS updated${NC}"
            clear_dns_cache
            break
            ;;
        "Opendns")
            networksetup -setdnsservers Wi-Fi 208.67.222.222 208.67.220.220
            echo -e "${GREEN}DNS updated${NC}"
            clear_dns_cache
            break
            ;;
        "Quad9")
            networksetup -setdnsservers Wi-Fi 9.9.9.9 149.112.112.112
            echo -e "${GREEN}DNS updated${NC}"
            clear_dns_cache
            break
            ;;
        "Neustar")
            networksetup -setdnsservers Wi-Fi 156.154.70.1 156.154.71.1
            echo -e "${GREEN}DNS updated${NC}"
            clear_dns_cache
            break
            ;;
        "SafeDNS")
            networksetup -setdnsservers Wi-Fi 195.46.39.39 195.46.39.40
            echo -e "${GREEN}DNS updated${NC}"
            clear_dns_cache
            break
            ;;
        "Verisign")
            networksetup -setdnsservers Wi-Fi 64.6.64.6 64.6.65.6
            echo -e "${GREEN}DNS updated${NC}"
            clear_dns_cache
            break
            ;;
        "Comodo")
            networksetup -setdnsservers Wi-Fi 8.26.56.26 8.20.247.20
            echo -e "${GREEN}DNS updated${NC}"
            clear_dns_cache
            break
            ;;
        "DNSwatch")
            networksetup -setdnsservers Wi-Fi 84.200.69.80 84.200.70.40
            echo -e "${GREEN}DNS updated${NC}"
            clear_dns_cache
            break
            ;;
        "Quit")
            break
            ;;
        *) echo -e "${RED}Invalid option $REPLY${NC}";;
    esac
done
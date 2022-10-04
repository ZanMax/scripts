#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

clear

banner()
{
  echo "+------------------------------------------+"
  printf "| %-40s |\n" "`date`"
  echo "|                                          |"
  printf "|`tput bold` %-40s `tput sgr0`|\n" "$@"
  echo "+------------------------------------------+"
}

banner "Fix DNS v0.1"
sleep 1
printf "\n"

PS3='Select options: '

options=("Enable" "Restart" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Enable")
            sudo systemctl unmask systemd-resolved.service
            sudo systemctl enable systemd-resolved.service
            sudo systemctl start systemd-resolved.service
            break
            ;;
        "Restart")
            sudo systemctl restart systemd-resolved.service
            break
            ;;
        "Quit")
            break
            ;;
        *) echo -e "${RED}Invalid option $REPLY${NC}";;
    esac
done
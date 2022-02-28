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

banner "GO BUILD v0.1"
printf "\n"

read -p 'Source name: ' gosource
printf "\n"
read -p 'Output name: ' out
printf "\n"

PS3='Select OS: '

options=("MacOS" "Linux" "Windows" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "MacOS")
            printf "\n"
            echo -e "${GREEN}->  MacOS ... ${NC}"
            go build -o $out $gosource
            ;;
        "Linux")
            printf "\n"
            echo -e "${GREEN}-> Linux ... ${NC}"
            env GOOS=linux GOARCH=amd64 go build -o $out $gosource
            ;;
        "Windows")
            printf "\n"
            echo -e "${GREEN}-> Windows ... ${NC}"
            env GOOS=windows GOARCH=amd64 go build -o $out $gosource
            ;;
        "Quit")
            break
            ;;
        *) echo -e "${RED}Invalid option $REPLY${NC}";;
    esac
done
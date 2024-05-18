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

banner "New Project Starter v0.1"
printf "\n"

PS3='Select service: '

options=("FastAPI" "Flask" "Django" "Go" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "FastAPI")
            printf "\n"
            echo -e "${GREEN}-> Init FastAPI ... ${NC}"
            break
            ;;
        "Flask")
            printf "\n"
            echo -e "${GREEN}-> Init Flask ... ${NC}"
            break
            ;;
        "Django")
            printf "\n"
            echo -e "${GREEN}-> Init Django ... ${NC}"
            break
            ;;
        "Go")
            printf "\n"
            echo -e "${GREEN}-> Init Go ... ${NC}"
            break
            ;;
        "Quit")
            break
            ;;
        *) echo -e "${RED}Invalid option $REPLY${NC}";;
    esac
done
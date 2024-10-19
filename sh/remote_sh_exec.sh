#!/bin/bash

# Define the list of hosts
hosts=(
  "user1@192.168.1.100"
  "user2@192.168.1.101"
)

# Loop through each host and execute the command
for host in "${hosts[@]}"; do
  echo "Executing on $host"
  ssh "$host" "bash ~/script.sh"
  echo -e "----\n"
done
#!/bin/bash

# Check if the script is run with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or using sudo."
    exit 1
fi

# Define the file path
NETPLAN_FILE="/etc/netplan/50-cloud-init.yaml"

# Define the content to add
CONFIG_CONTENT=$(cat <<EOL
network:
  ethernets:
    eno1np0:
      dhcp4: true
      optional: true
    eno2np1:
      dhcp4: true
      optional: true
  version: 2
EOL
)

# Check if the file exists
if [ -f "$NETPLAN_FILE" ]; then
    echo "File $NETPLAN_FILE exists."
    
    # Check if the content is already present
    if grep -q "eno1np0" "$NETPLAN_FILE" && grep -q "eno2np1" "$NETPLAN_FILE"; then
        echo "Configuration already exists in $NETPLAN_FILE."
    else
        echo "Adding configuration to $NETPLAN_FILE."
        echo "$CONFIG_CONTENT" | sudo tee "$NETPLAN_FILE" > /dev/null
    fi
else
    echo "File $NETPLAN_FILE does not exist. Creating it."
    echo "$CONFIG_CONTENT" | sudo tee "$NETPLAN_FILE" > /dev/null
fi

# Apply the netplan configuration
echo "Applying netplan configuration..."
sudo netplan apply

echo "Done."
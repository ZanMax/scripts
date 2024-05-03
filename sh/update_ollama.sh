#!/bin/bash

curl -fsSL https://ollama.com/install.sh | sh

# Define the file to be updated
FILE="/etc/systemd/system/ollama.service"

# Define the line to be added
LINE="Environment=\"OLLAMA_HOST=0.0.0.0\""

# Check if the line already exists in the file
grep -qF "$LINE" "$FILE"

# If the line does not exist, append it to the file
if [ $? -ne 0 ]; then
    # Append the line to the existing [Service] section
    sudo sed -i '/\[Service\]/a '"$LINE"'' "$FILE"
fi

sudo systemctl daemon-reload
sudo systemctl stop ollama
sudo systemctl start ollama

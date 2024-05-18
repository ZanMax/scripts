#!/bin/bash

curl -fsSL https://ollama.com/install.sh | sh

# Define the file to be updated
FILE="/etc/systemd/system/ollama.service"

# Define the lines to be added
LINE_HOST="Environment=\"OLLAMA_HOST=0.0.0.0\""
LINE_MODELS="Environment=\"OLLAMA_MAX_LOADED_MODELS=2\""

# Check if the OLLAMA_HOST line already exists in the file
grep -qF "$LINE_HOST" "$FILE"

# If the OLLAMA_HOST line does not exist, append it to the file
if [ $? -ne 0 ]; then
    # Append the OLLAMA_HOST line to the existing [Service] section
    sudo sed -i '/\[Service\]/a '"$LINE_HOST"'' "$FILE"
fi

# Check if the OLLAMA_MAX_LOADED_MODELS line already exists in the file
grep -qF "$LINE_MODELS" "$FILE"

# If the OLLAMA_MAX_LOADED_MODELS line does not exist, append it after OLLAMA_HOST line
if [ $? -ne 0 ]; then
    # Insert the OLLAMA_MAX_LOADED_MODELS line after the OLLAMA_HOST line
    sudo sed -i '/'"$LINE_HOST"'/a '"$LINE_MODELS"'' "$FILE"
fi

sudo systemctl daemon-reload
sudo systemctl stop ollama
sudo systemctl start ollama

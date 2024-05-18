#!/bin/bash

# Function to get the latest version number from GitHub API
get_latest_version() {
  curl -s https://api.github.com/repos/ollama/ollama/releases/latest | grep -oP '"tag_name": "v\K[0-9.]+'
}

# Get the latest version from GitHub
latest_version=$(get_latest_version)
echo "Latest version on GitHub: v$latest_version"

# Get the local version
local_version=$(ollama -v | grep -oP '\d+\.\d+\.\d+')
echo "Local version: v$local_version"

# Compare versions
if [ "$(printf '%s\n' "$latest_version" "$local_version" | sort -V | head -n1)" != "$latest_version" ]; then
  echo "Local version is lower than the latest version. Updating..."
  ./update_ollama.sh
else
  echo "Local version is up to date."
fi


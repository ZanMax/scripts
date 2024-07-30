#!/bin/bash

# Check if URL is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <YouTube URL>"
  exit 1
fi

URL=$1

# Get the available formats
echo "Fetching available formats..."
yt-dlp -F "$URL"

# Prompt the user to select a format
echo "Enter the format code you want to download:"
read FORMAT_CODE

# Download the selected format
echo "Downloading video..."
yt-dlp -f "$FORMAT_CODE" "$URL"

echo "Download complete."


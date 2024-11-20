#!/bin/bash

# Define colors for logging
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to log messages
log() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Check if necessary packages are installed
log "Checking for necessary packages..."
REQUIRED_PACKAGES=("tightvncserver" "websockify" "novnc")
MISSING_PACKAGES=()

for pkg in "${REQUIRED_PACKAGES[@]}"; do
  if ! dpkg -l | grep -qw "$pkg"; then
    MISSING_PACKAGES+=("$pkg")
  fi
done

if [ ${#MISSING_PACKAGES[@]} -gt 0 ]; then
  warn "Missing packages: ${MISSING_PACKAGES[*]}"
  log "Installing missing packages..."
  sudo apt update && sudo apt install -y "${MISSING_PACKAGES[@]}"
  if [ $? -ne 0 ]; then
    error "Failed to install missing packages. Exiting."
    exit 1
  fi
else
  log "All necessary packages are installed."
fi

# Kill all running VNC sessions
log "Killing all running VNC sessions..."
vncserver -kill :* > /dev/null 2>&1
if [ $? -eq 0 ]; then
  log "Successfully killed all VNC sessions."
else
  warn "No running VNC sessions found."
fi

# Remove leftover lock files
log "Removing leftover lock files (if any)..."
rm -f /tmp/.X*-lock /tmp/.X11-unix/X* > /dev/null 2>&1
log "Lock files cleaned."

# Start the VNC server
log "Starting VNC server on display :1 with resolution 1920x1080..."
vncserver :1 -geometry 1920x1080
if [ $? -ne 0 ]; then
  error "Failed to start VNC server. Check logs in ~/.vnc/*.log"
  exit 1
fi

# Start noVNC using websockify
log "Starting noVNC on http://0.0.0.0:6080..."
websockify 0.0.0.0:6080 localhost:5901 --web=/usr/share/novnc
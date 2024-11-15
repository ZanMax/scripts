#!/bin/bash

# Check if running as root
if [[ $EUID -ne 0 ]]; then
  echo "Please run this script as root or with sudo."
  exit 1
fi

# Function to list available disks
list_disks() {
  echo "Available disks:"
  lsblk -o NAME,SIZE,MODEL,TYPE | grep 'disk' | awk '{print "/dev/" $1, "-", $2, "-", $3}'
}

echo "=== SSD Health Check Script ==="
echo "Please select your SSD type:"
echo "1) NVMe"
echo "2) SATA"
read -p "Enter the number (1 or 2): " ssd_type

# Prompt for device name based on the selection
if [ "$ssd_type" == "1" ]; then
  echo "Listing available NVMe devices..."
  list_disks
  read -p "Enter NVMe device path (e.g., /dev/nvme0): " DEVICE
  if [[ ! -e $DEVICE ]]; then
    echo "Error: Device $DEVICE not found."
    exit 1
  fi

  echo "=== NVMe SSD Health Check ==="
  echo "-----------------------------"

  # General NVMe device information
  echo "1. Device Information:"
  nvme id-ctrl $DEVICE
  echo

  # SMART Health Information
  echo "2. SMART Health Information:"
  nvme smart-log $DEVICE
  echo

  # SMART Error Log
  echo "3. SMART Error Log (Last 10 Entries):"
  nvme error-log $DEVICE | tail -n 10
  echo

  # Check temperature
  echo "4. Temperature Monitoring:"
  TEMP=$(nvme smart-log $DEVICE | grep "temperature" | awk '{print $3}')
  echo "Current Temperature: $TEMP Celsius"
  echo

  # Check for critical warnings
  echo "5. Critical Warnings:"
  nvme smart-log $DEVICE | grep "critical_warning" | awk '{print $3}'
  echo "If any value is non-zero, there may be an issue."
  echo

elif [ "$ssd_type" == "2" ]; then
  echo "Listing available SATA devices..."
  list_disks
  read -p "Enter SATA device path (e.g., /dev/sda): " DEVICE
  if [[ ! -e $DEVICE ]]; then
    echo "Error: Device $DEVICE not found."
    exit 1
  fi

  echo "=== SATA SSD Health Check ==="
  echo "-----------------------------"

  # Check if smartctl is installed
  if ! command -v smartctl &> /dev/null; then
    echo "smartctl is not installed. Please install it with 'sudo apt install smartmontools'."
    exit 1
  fi

  # SMART Health Information
  echo "1. SMART Health Information:"
  smartctl -H $DEVICE
  echo

  # Complete SMART Data Overview
  echo "2. Full SMART Data:"
  smartctl -a $DEVICE
  echo

  # SMART Error Log
  echo "3. SMART Error Log (Last 5 Entries):"
  smartctl -l error $DEVICE | tail -n 10
  echo

  # Temperature (if supported)
  echo "4. Temperature:"
  TEMP=$(smartctl -A $DEVICE | grep -i "temperature" | awk '{print $10}')
  if [ -z "$TEMP" ]; then
    echo "Temperature data not available for this device."
  else
    echo "Current Temperature: $TEMP Celsius"
  fi
  echo

  # Wear Leveling (for SSDs with Wear Leveling support)
  echo "5. Wear Level Indicator:"
  smartctl -A $DEVICE | grep -i "wear_leveling_count\|media_wearout_indicator" || echo "No wear leveling data available."
  echo

else
  echo "Invalid option. Please enter 1 for NVMe or 2 for SATA."
  exit 1
fi

echo "-----------------------------"
echo "SSD Health Check Complete."
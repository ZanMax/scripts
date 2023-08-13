#!/bin/bash

# Nessesary Packages: smartmontools, udev, nvme-cli (optional), jq, bc
# sudo apt -y install smartmontools udev nvme-cli jq bc

# Check for necessary commands
if ! command -v smartctl &> /dev/null; then
    echo "Please install 'smartmontools' to use this script."
    exit 1
fi

if ! command -v udevadm &> /dev/null; then
    echo "Please install 'udev' to use this script."
    exit 1
fi

# Check if nvme-cli is installed for NVMe drives
if ! command -v nvme &> /dev/null; then
    echo "Warning: 'nvme-cli' not found. NVMe drive details might be limited."
fi

# Function to check if a device is NVMe
is_nvme() {
    local device="$1"
    if [[ "$device" == nvme* ]]; then
        return 0   # 0 means true in bash
    else
        return 1   # 1 means false in bash
    fi
}

# Function to convert bytes to GB or TB
convert_bytes() {
    local bytes="$1"

    local gb=$(( bytes / 1024**3 ))
    if (( gb < 1024 )); then
        echo "${gb}GB"
    else
        local tb=$(echo "scale=2; $bytes / (1024^4)" | bc)
        echo "${tb}TB"
    fi
}

# Iterate over all disk devices
for disk in $(lsblk -dn -o NAME | grep -v loop); do
    device="/dev/${disk}"
    brand=""
    capacity=""

    if is_nvme "$disk"; then
        type="NVMe SSD"
        if command -v nvme &> /dev/null; then
            brand=$(nvme id-ctrl "$device" --output-format=json | jq -r '.mn' 2>/dev/null)
            capacity=$(nvme id-ctrl "$device" --output-format=json | jq -r '.tnvmcap' 2>/dev/null)
        fi
        # If nvme-cli didn't provide capacity, use lsblk as fallback
        if [ -z "$capacity" ] || [ "$capacity" == "null" ]; then
            capacity=$(lsblk -dn -o SIZE,NAME | grep "$disk" | awk '{print $1}')
        else
            capacity=$(convert_bytes "$capacity")
        fi
    else
        type="Other Drive"
        brand=$(smartctl -i "$device" | grep "Device Model:" | awk '{print $3}')
        capacity=$(smartctl -i "$device" | grep "User Capacity:" | awk -F'[' '{print $2}' | awk -F']' '{print $1}')
        
        # Check drive type
        rotation=$(udevadm info --query=property --name=${device} | grep "ID_ATA_ROTATION_RATE_RPM=" | cut -d'=' -f2)
        if [ "$rotation" == "0" ] || [ "$rotation" == "solid" ]; then
            type="SSD"
        elif [ -z "$rotation" ]; then
            # If no rotation info found, fallback to smartctl
            if smartctl -i ${device} | grep -iq "Solid State Device"; then
                type="SSD"
            else
                type="HDD"
            fi
        else
            type="HDD"
        fi
    fi

    echo -e "${device}:\n Type: ${type}\n Brand: ${brand}\n Capacity: ${capacity}\n"
done

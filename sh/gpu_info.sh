#!/bin/bash

# Check for necessary tools
if ! command -v lspci &> /dev/null; then
    echo "Error: lspci is not installed."
    exit 1
fi

if ! command -v dmidecode &> /dev/null; then
    echo "Error: dmidecode is not installed."
    exit 1
fi

echo "Fetching GPU and PCIe slot information..."
echo "=============================================="
echo -e "GPU Description\t\t\tPCIe Speed\tLink Width\tPCIe Slot"
echo "--------------------------------------------------------------"

# Extract PCI slot information from dmidecode
declare -A SLOT_MAP
while read -r SLOT BUS; do
    SLOT_MAP["$BUS"]=$SLOT
done < <(sudo dmidecode -t slot | awk '
    /Designation:/ {slot=$2}
    /Bus Address:/ {bus=$3; print slot, bus}')

# Get GPU devices from lspci
GPUS=$(lspci | grep -i "vga compatible controller" | grep -i nvidia)

# Loop through each GPU
echo "$GPUS" | while read -r line; do
    # Extract bus ID and GPU description
    BUS_ID=$(echo "$line" | awk '{print $1}')
    GPU_DESC=$(echo "$line" | sed -E 's/.*NVIDIA Corporation (.+)/\1/')

    # Get detailed PCI info
    PCI_INFO=$(sudo lspci -s "$BUS_ID" -vvv 2>/dev/null)

    # Extract PCIe speed and width
    LINK_STATUS=$(echo "$PCI_INFO" | grep -Eo "LnkSta:.*" | head -n 1)
    PCI_SPEED=$(echo "$LINK_STATUS" | grep -Eo "Speed [^,]+" | awk '{print $2}')
    LINK_WIDTH=$(echo "$LINK_STATUS" | grep -Eo "Width [^,]+" | awk '{print $2}')

    # Get physical slot from SLOT_MAP
    PHYSICAL_SLOT=${SLOT_MAP["0000:$BUS_ID"]:-"Unknown"}

    # Handle missing data
    PCI_SPEED=${PCI_SPEED:-"Unknown"}
    LINK_WIDTH=${LINK_WIDTH:-"Unknown"}

    # Print the information in the desired format
    printf "%-30s %-10s %-10s %-10s\n" "$GPU_DESC" "$PCI_SPEED" "$LINK_WIDTH" "$PHYSICAL_SLOT"
done
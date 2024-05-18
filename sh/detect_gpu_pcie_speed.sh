#!/bin/bash

# Check if the lspci command is available
if ! command -v lspci &> /dev/null; then
    echo "lspci could not be found. Please install it first."
    exit 1
fi

# Check for each GPU in the system and get its PCIe speed
echo "Detecting PCIe speeds of GPUs..."
for device in $(lspci | grep -i 'VGA\|3D\|2D' | cut -d ' ' -f 1); do
    echo "GPU $device details:"
    pcie_info=$(lspci -vvv -s $device | grep -E "LnkCap|LnkSta")

    if [ -z "$pcie_info" ]; then
        echo "No PCIe information available for GPU $device. Run as root or check GPU compatibility."
    else
        echo "$pcie_info"
    fi
done

echo "Detection complete."
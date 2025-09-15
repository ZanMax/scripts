#!/bin/bash

# ==============================================================================
# Mellanox ConnectX-6 Debug Information Collector for Ubuntu 22.04
# ==============================================================================
# This script collects necessary system information to diagnose issues with
# Mellanox network card detection.
#
# Usage:
#   chmod +x mellanox_debug.sh
#   sudo ./mellanox_debug.sh > mellanox_debug_output.txt
#
# Share the resulting 'mellanox_debug_output.txt' file for troubleshooting.
# ==============================================================================

echo "### Mellanox Debug Information Collector ###"
echo "### Script started at: $(date)"
echo "=============================================================================="

# Section 1: Basic System Information
# ------------------------------------------------------------------------------
# Provides context about the Operating System and hardware environment.
echo "[+] 1. Basic System & Kernel Information"
echo "------------------------------------------------"
echo "Kernel Version:"
uname -a
echo ""
echo "Ubuntu Version:"
lsb_release -a
echo ""
echo "CPU Information:"
lscpu | grep -E "Model name|Architecture|CPU\(s\)|Vendor ID"
echo ""
echo "Memory Information:"
free -h
echo "=============================================================================="
echo ""

# Section 2: PCI Hardware Detection
# ------------------------------------------------------------------------------
# This is the most critical step. If the card doesn't appear here, it's likely
# a hardware seating, BIOS, or physical card issue.
echo "[+] 2. PCI Device Scan"
echo "------------------------------------------------"
echo "Searching for Mellanox devices with lspci..."
lspci -nn | grep -i "Mellanox"
echo ""

# Get the PCI device ID for more detailed checks.
# It will use the first Mellanox device found.
MELLANOX_PCI_ID=$(lspci -nn | grep -i "Mellanox" | awk '{print $1}' | head -n 1)

if [ -n "$MELLANOX_PCI_ID" ]; then
    echo "Found Mellanox device at PCI Bus ID: $MELLANOX_PCI_ID"
    echo ""
    echo "Verbose lspci output for $MELLANOX_PCI_ID (Link Status, Capabilities):"
    lspci -vvv -s "$MELLANOX_PCI_ID"
    echo ""
    echo "Kernel driver in use for $MELLANOX_PCI_ID:"
    lspci -ks "$MELLANOX_PCI_ID"
    echo ""
else
    echo "!!! WARNING: No Mellanox device found with lspci."
    echo "!!! Please check physical seating of the card and UEFI/BIOS settings."
    echo ""
fi

echo "Full hardware list from lshw (Network devices only):"
lshw -c network
echo "=============================================================================="
echo ""

# Section 3: Kernel Logs (dmesg & journalctl)
# ------------------------------------------------------------------------------
# Checks for errors or messages related to the mlx5 driver, RDMA,
# firmware loading, and IOMMU initialization.
echo "[+] 3. Kernel Log Analysis"
echo "------------------------------------------------"
echo "dmesg logs for mlx5, mellanox, rdma, infiniband, and pcie errors:"
dmesg | grep -iE "mlx5|mellanox|rdma|infiniband|pcie.*(error|fail|nack)"
echo ""
echo "dmesg logs for IOMMU / VT-d status:"
dmesg | grep -iE "DMAR|IOMMU|AMD-Vi"
echo ""
echo "journalctl boot logs for mlx5 and mellanox:"
journalctl -b 0 | grep -iE "mlx5|mellanox"
echo "=============================================================================="
echo ""


# Section 4: Driver & Module Information
# ------------------------------------------------------------------------------
# Checks which drivers are installed (in-kernel vs. MLNX_OFED) and loaded.
echo "[+] 4. Driver and Kernel Module Status"
echo "------------------------------------------------"
echo "Loaded kernel modules related to Mellanox:"
lsmod | grep -iE "mlx5|ib_uverbs|rdma"
echo ""
echo "Checking for MLNX_OFED installation (ofed_info):"
# This command will fail if MLNX_OFED is not installed, which is useful info.
if command -v ofed_info &> /dev/null; then
    ofed_info -s
else
    echo "ofed_info command not found. MLNX_OFED drivers are likely not installed."
fi
echo ""
echo "Installed packages related to RDMA and Mellanox:"
dpkg -l | grep -iE "rdma-core|mlnx|ofed|mstflint"
echo "=============================================================================="
echo ""


# Section 5: Firmware and Card Status
# ------------------------------------------------------------------------------
# Uses the Mellanox Firmware Tools (MFT) to query the card directly.
# This can reveal if the card is responsive, even if the kernel driver failed.
echo "[+] 5. Mellanox Firmware Tools (MFT) Status"
echo "------------------------------------------------"
if ! command -v mst &> /dev/null; then
    echo "MFT tools not found. To install, run:"
    echo "  sudo apt update && sudo apt install -y mstflint"
    echo "Skipping firmware checks."
else
    echo "Starting MFT service..."
    mst start >/dev/null 2>&1
    echo ""
    echo "MST device status:"
    mst status -v
    echo ""
    echo "Querying firmware information with mlxfwmanager:"
    mlxfwmanager --query
fi
echo "=============================================================================="
echo ""


# Section 6: Network Interface Status
# ------------------------------------------------------------------------------
# Checks if the OS has created any network interfaces for the card.
echo "[+] 6. Network Interface Level"
echo "------------------------------------------------"
echo "IP address and interface status:"
ip -br a
echo ""
echo "Detailed IP link information:"
ip -d link
echo ""

# Find network interfaces provided by the Mellanox card
if [ -n "$MELLANOX_PCI_ID" ]; then
    echo "Searching for network interfaces associated with PCI device $MELLANOX_PCI_ID..."
    # The interface name is usually in /sys/bus/pci/devices/<pci_id>/net/
    NET_INTERFACES=$(ls "/sys/bus/pci/devices/0000:$MELLANOX_PCI_ID/net/" 2>/dev/null)
    if [ -n "$NET_INTERFACES" ]; then
        for iface in $NET_INTERFACES; do
            echo ""
            echo "--- Found interface: $iface ---"
            echo "ethtool info for $iface:"
            ethtool "$iface"
            echo ""
            echo "ethtool driver info for $iface:"
            ethtool -i "$iface"
            echo "----------------------------------"
        done
    else
        echo "No network interfaces found for this PCI device in sysfs."
    fi
fi
echo "=============================================================================="


echo ""
echo "### Script finished at: $(date)"
echo "### Please review the output file 'mellanox_debug_output.txt' for errors and warnings."
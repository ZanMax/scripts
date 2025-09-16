#!/bin/bash
# check_mellanox.sh
# Script to verify Mellanox ConnectX-6 functionality

echo "=== Mellanox ConnectX-6 Verification ==="

# 1. Check if mlx5 driver is loaded
echo -e "\n[1] Checking driver..."
lsmod | grep mlx5_core >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ mlx5_core driver is loaded"
else
    echo "❌ mlx5_core driver NOT loaded"
fi

# 2. Show Mellanox devices
echo -e "\n[2] lspci output:"
lspci | grep -i mell

# 3. Check available devices with ibstat
echo -e "\n[3] ibstat output:"
if command -v ibstat >/dev/null 2>&1; then
    ibstat
else
    echo "⚠️ ibstat not installed"
fi

# 4. Show link status with ibv_devinfo
echo -e "\n[4] ibv_devinfo output:"
if command -v ibv_devinfo >/dev/null 2>&1; then
    ibv_devinfo | grep -E "hca_id|fw_ver|state|phys_state|transport"
else
    echo "⚠️ ibv_devinfo not installed"
fi

# 5. Check network interfaces
echo -e "\n[5] Network interfaces (ip link):"
ip -o link show | grep mlx

# 6. Check ethtool link status
for iface in $(ip -o link show | awk -F': ' '{print $2}' | grep mlx); do
    echo -e "\n[6] Checking interface: $iface"
    sudo ethtool $iface | grep -E "Link detected|Speed|Port|Supported"
done

echo -e "\n=== Done. If links show as UP with speed, your ConnectX-6 is working ==="

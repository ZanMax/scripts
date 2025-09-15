#!/bin/bash
# Check if Ubuntu is booted in UEFI or Legacy BIOS mode

echo "=== UEFI Boot Check ==="

# Check for /sys/firmware/efi directory
if [ -d /sys/firmware/efi ]; then
    echo "Boot Mode: UEFI"
else
    echo "Boot Mode: Legacy BIOS"
    exit 0
fi

# Check if efivars are accessible
if [ -d /sys/firmware/efi/efivars ]; then
    echo "EFI Variables: Present"
else
    echo "EFI Variables: Not found (unexpected in UEFI mode)"
fi

# Check Secure Boot status using mokutil if installed
if command -v mokutil >/dev/null 2>&1; then
    SB_STATE=$(mokutil --sb-state 2>/dev/null)
    echo "Secure Boot: $SB_STATE"
else
    echo "Secure Boot: mokutil not installed (run: sudo apt install mokutil)"
fi

# Check efibootmgr for UEFI boot entries
if command -v efibootmgr >/dev/null 2>&1; then
    echo "UEFI Boot Entries:"
    efibootmgr -v | grep "Boot"
else
    echo "efibootmgr not installed (run: sudo apt install efibootmgr)"
fi


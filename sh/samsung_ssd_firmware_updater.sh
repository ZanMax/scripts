#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
MAGENTA='\033[0;35m'
YELLOW='\033[1;33m'
NC='\033[0m' # No color

# Inform the user about the firmware page
echo -e "${MAGENTA}You can find firmware using this URL:${NC}"
echo -e "${YELLOW}https://semiconductor.samsung.com/consumer-storage/support/tools/${NC}"

# Prompt the user to enter the firmware URL
read -p "Please enter the URL for the firmware ISO: " iso_url

# Check if the URL is provided
if [ -z "$iso_url" ]; then
    echo -e "${RED}Error: Firmware URL is required. Exiting.${NC}"
    exit 1
fi

# Install necessary tools
echo -e "${MAGENTA}Installing required packages...${NC}"
apt-get -y install gzip unzip wget cpio

# Prepare directories
echo -e "${MAGENTA}Preparing directories...${NC}"
mkdir -p /tmp/samsung/rootfs/mnt

# Download the firmware ISO
echo -e "${MAGENTA}Downloading the firmware ISO...${NC}"
wget -O /tmp/samsung/file.iso $iso_url

# Mount the ISO and extract files
echo -e "${MAGENTA}Mounting and extracting the firmware...${NC}"
mount /tmp/samsung/file.iso /tmp/samsung/rootfs/mnt/
cd /tmp/samsung/rootfs
gzip -dc /tmp/samsung/rootfs/mnt/initrd | cpio -idv --no-absolute-filenames
cp -r /tmp/samsung/rootfs/root/fumagician/* /tmp/samsung/

# Clean up
echo -e "${MAGENTA}Cleaning up...${NC}"
umount /tmp/samsung/rootfs/mnt
rm -rf /tmp/samsung/rootfs
rm /tmp/samsung/file.iso

# Run the firmware update tool
cd /tmp/samsung
echo -e "${GREEN}Running the firmware update tool...${NC}"
./fumagician
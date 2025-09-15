#!/bin/bash
set -e

MLNX_VER="MLNX_OFED-24.10-3.2.5.0"
MLNX_FILE="MLNX_OFED_LINUX-24.10-3.2.5.0-ubuntu22.04-x86_64.tgz"
MLNX_URL="https://www.mellanox.com/downloads/ofed/${MLNX_VER}/${MLNX_FILE}"

echo "=== Step 1: Remove old DOCA/OFED packages if present ==="

# Find and remove doca-* packages
DOCA_PKGS=$(dpkg -l | awk '/doca-/{print $2}')
if [ -n "$DOCA_PKGS" ]; then
  echo "Removing DOCA packages: $DOCA_PKGS"
  sudo apt-get remove --purge -y $DOCA_PKGS
fi

# Find and remove mlnx-ofed-* packages
OFED_PKGS=$(dpkg -l | awk '/mlnx-ofed-/{print $2}')
if [ -n "$OFED_PKGS" ]; then
  echo "Removing MLNX_OFED packages: $OFED_PKGS"
  sudo apt-get remove --purge -y $OFED_PKGS
fi

# Special case: mlnx-ofed-kernel-utils may linger
if dpkg -l | grep -q mlnx-ofed-kernel-utils; then
  echo "Purging mlnx-ofed-kernel-utils"
  sudo dpkg --purge mlnx-ofed-kernel-utils || true
fi

# Clean up
sudo apt-get autoremove --purge -y
sudo apt-get clean

echo "=== Step 2: Install prerequisites ==="
sudo apt update
sudo apt install -y build-essential dkms libnuma-dev libnl-3-dev libnl-route-3-dev \
                   tcl tk dpatch chrpath debhelper autotools-dev automake autoconf \
                   libtool flex bison fakeroot zlib1g-dev wget

echo "=== Step 3: Download MLNX_OFED ${MLNX_VER} ==="
if [ ! -f "${MLNX_FILE}" ]; then
  wget -O ${MLNX_FILE} ${MLNX_URL} || {
    echo "Download failed. If Mellanox EULA blocks direct download, manually place ${MLNX_FILE} in this directory."
    exit 1
  }
else
  echo "${MLNX_FILE} already exists, skipping download."
fi

echo "=== Step 4: Extract package ==="
tar -xvf ${MLNX_FILE}
cd MLNX_OFED_LINUX-24.10-3.2.5.0-ubuntu22.04-x86_64

echo "=== Step 5: Run installer ==="
sudo ./mlnxofedinstall --add-kernel-support

echo "=== Step 6: Restart OFED services ==="
sudo /etc/init.d/openibd restart

echo "=== Step 7: Verify installation ==="
ofed_info -s || echo "Check installation manually with: ofed_info -s"

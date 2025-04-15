#!/bin/bash

# --- Script to Manage NVIDIA Drivers (Remove, Install Recommended, or Show Info) ---

# Exit immediately if a command exits with a non-zero status
set -e

# --- Function Definitions ---

# Function to display help message
show_help() {
  echo "Usage: sudo $0 [OPTION]"
  echo "Manage NVIDIA driver installation on Ubuntu."
  echo
  echo "Options:"
  echo "  --remove       Purge all NVIDIA drivers and related packages installed via apt."
  echo "                 Requires sudo privileges."
  echo "  --install      Automatically install the 'recommended' NVIDIA driver using ubuntu-drivers."
  echo "                 Installs build tools and kernel headers first."
  echo "                 Requires sudo privileges."
  echo "  --info         Detect NVIDIA GPU, list available drivers, and show manual installation instructions."
  echo "                 Does NOT require sudo privileges."
  echo "  --help         Display this help message."
  echo
  echo "If no option is provided, this help message is shown."
  echo "Note: --remove and --install require running the script with 'sudo'."
}

# Function to remove NVIDIA drivers
remove_drivers() {
  # Check for root privileges (redundant if called via sudo ./script, but good practice)
  if [[ $EUID -ne 0 ]]; then
     echo "ERROR: The --remove option must be run as root or with sudo."
     exit 1
  fi

  echo "---------------------------------------------"
  echo " WARNING: About to purge all NVIDIA packages "
  echo "---------------------------------------------"
  read -p "Are you sure you want to proceed? (y/N): " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
      echo "Operation cancelled."
      exit 0
  fi

  echo ">>> Stopping display manager (if running)..."
  # Try common display managers, ignore errors if not found/running
  systemctl stop display-manager.service >/dev/null 2>&1 || true
  systemctl stop gdm.service >/dev/null 2>&1 || true
  systemctl stop lightdm.service >/dev/null 2>&1 || true
  systemctl stop sddm.service >/dev/null 2>&1 || true
  echo "Done."

  echo ">>> Purging NVIDIA packages..."
  apt purge -y 'nvidia-*' 'libnvidia-*'
  echo "Done."

  echo ">>> Removing orphaned dependencies..."
  apt autoremove -y
  echo "Done."

  echo ">>> Cleaning apt cache..."
  apt clean
  echo "Done."

  echo ">>> Removing NVIDIA configuration files (if any left)..."
  rm -f /etc/modprobe.d/nvidia-*.conf
  rm -f /etc/modprobe.d/blacklist-nvidia.conf
  rm -f /etc/modprobe.d/blacklist-nouveau.conf
  echo "Done."

  echo ">>> Updating initramfs..."
  update-initramfs -u
  echo "Done."

  echo "------------------------------------------------------"
  echo " NVIDIA Driver Removal Complete."
  echo " It is HIGHLY recommended to REBOOT your system now:"
  echo "   sudo reboot"
  echo "------------------------------------------------------"
}

# Function to install the recommended NVIDIA driver
install_recommended_driver() {
  # Check for root privileges
  if [[ $EUID -ne 0 ]]; then
     echo "ERROR: The --install option must be run as root or with sudo."
     exit 1
  fi

  echo "---------------------------------------------"
  echo " Attempting to install recommended NVIDIA driver "
  echo "---------------------------------------------"
  read -p "This will install necessary build tools, kernel headers, and run 'ubuntu-drivers autoinstall'. Proceed? (y/N): " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
      echo "Operation cancelled."
      exit 0
  fi

  echo ">>> Updating package list..."
  apt update
  echo "Done."

  echo ">>> Installing necessary build tools and kernel headers..."
  apt install -y build-essential linux-headers-$(uname -r)
  echo "Done."

  echo ">>> Attempting to automatically install recommended drivers..."
  # Run the autoinstall command
  ubuntu-drivers autoinstall
  echo "Done."

  echo "------------------------------------------------------"
  echo " Recommended NVIDIA Driver Installation Initiated."
  echo " Monitor the output above for any errors."
  echo " If successful, it is HIGHLY recommended to REBOOT your system now:"
  echo "   sudo reboot"
  echo " After rebooting, verify with:"
  echo "   nvidia-smi"
  echo "------------------------------------------------------"
}


# Function to show GPU info and installation instructions
show_driver_info() {
  echo "---------------------------------------------"
  echo " Detecting NVIDIA GPU(s)..."
  echo "---------------------------------------------"

  # Use lspci to find NVIDIA devices
  gpu_info=$(lspci | grep -i 'nvidia')

  if [ -z "$gpu_info" ]; then
    echo "No NVIDIA GPU detected using lspci."
  else
    echo "Found NVIDIA GPU(s):"
    echo "$gpu_info"
    echo
  fi

  echo "---------------------------------------------"
  echo " Checking available drivers via ubuntu-drivers..."
  echo " (Note: 'udevadm hwdb is deprecated' messages are normal and can be ignored)"
  echo "---------------------------------------------"

  # Run ubuntu-drivers devices to list compatible drivers
  ubuntu-drivers devices

  echo
  echo "---------------------------------------------"
  echo " Manual Driver Installation Example"
  echo "---------------------------------------------"
  echo "1. Identify the desired driver package name from the list above."
  echo "   Look for the line ending with '(recommended)' for the suggested version."
  echo "   Example package name: nvidia-driver-570"
  echo
  echo "2. Use the following command structure to install MANUALLY (replace <package_name>):"
  echo "   sudo apt update"
  echo "   sudo apt install <package_name>"
  echo
  echo "   Example for installing nvidia-driver-570 manually:"
  echo "   sudo apt update"
  echo "   sudo apt install nvidia-driver-570"
  echo
  echo "   (Alternatively, use the '--install' option of this script for automatic recommended installation)"
  echo
  echo "3. After installation, **reboot your system**:"
  echo "   sudo reboot"
  echo
  echo "4. After rebooting, verify the installation with:"
  echo "   nvidia-smi"
  echo "---------------------------------------------"
}


# --- Main Script Logic ---

# Check if any argument is provided
if [ $# -eq 0 ]; then
  show_help
  exit 0
fi

# Parse the first argument
case "$1" in
  --remove)
    # Ensure script is run with sudo for this option
    if [[ $EUID -ne 0 ]]; then echo "ERROR: Use 'sudo ./manage_nvidia.sh --remove'"; exit 1; fi
    remove_drivers
    ;;
  --install)
    # Ensure script is run with sudo for this option
    if [[ $EUID -ne 0 ]]; then echo "ERROR: Use 'sudo ./manage_nvidia.sh --install'"; exit 1; fi
    install_recommended_driver
    ;;
  --info)
    show_driver_info
    ;;
  --help)
    show_help
    ;;
  *)
    echo "Error: Invalid option '$1'"
    echo
    show_help
    exit 1
    ;;
esac

exit 0
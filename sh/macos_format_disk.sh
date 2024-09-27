#!/bin/bash

# Function to list all disks
list_disks() {
  echo "Available Disks:"
  diskutil list
}

# Function to format the selected disk
format_disk() {
  read -p "Enter the disk identifier (e.g., disk4): " disk_identifier
  read -p "Enter the name you want for the drive: " disk_name

  echo "Choose a file system:"
  echo "1) APFS"
  echo "2) HFS+"
  echo "3) ExFAT"
  echo "4) MS-DOS (FAT32)"
  
  read -p "Enter the number corresponding to the file system you want: " fs_choice

  case $fs_choice in
    1)
      fs_type="APFS"
      ;;
    2)
      fs_type="HFS+"
      ;;
    3)
      fs_type="ExFAT"
      ;;
    4)
      fs_type="MS-DOS"
      ;;
    *)
      echo "Invalid file system choice."
      exit 1
      ;;
  esac

  echo "Formatting /dev/$disk_identifier with $fs_type..."
  
  # Perform disk erase
  sudo diskutil eraseDisk $fs_type "$disk_name" /dev/$disk_identifier

  echo "Disk /dev/$disk_identifier has been formatted with $fs_type."
}

# Main script starts here
list_disks
format_disk
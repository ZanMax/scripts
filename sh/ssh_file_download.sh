#!/bin/bash

# Prompt the user for the host
read -p "Enter the host: " host

# Prompt the user for the username
read -p "Enter the username: " username

# Prompt the user for the remote file path
read -p "Enter the remote file path: " remote_file

# Prompt the user for the local directory path
read -p "Enter the local directory path: " local_dir

# Copy the remote file to the local directory
scp "$username@$host:$remote_file" "$local_dir"

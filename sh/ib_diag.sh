#!/bin/bash

# Set the output file name
output_file="ib_diag_$(date +%Y%m%d_%H%M%S).txt"

# Function to execute a command and append its output to the file
execute_command() {
    echo "Command: $1" | tee -a "$output_file"
    eval "$1" | tee -a "$output_file"
    echo "" | tee -a "$output_file"
}

# Check if the script is being run with sudo
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run with sudo." 
    exit 1
fi

# Clear the output file
echo "" > "$output_file"

# Execute InfiniBand diagnostic commands
execute_command "ibstat"
execute_command "ibstatus"
execute_command "ibswitches"
execute_command "ibhosts"
execute_command "ibdiagnet -r"

echo "InfiniBand diagnostic information collected successfully."
echo "Output saved to: $output_file"
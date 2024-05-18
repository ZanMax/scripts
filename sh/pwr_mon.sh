#!/bin/bash

# Interval in seconds for refreshing the data
refresh_interval=1

# Sleep interval in seconds for display readability
display_sleep_interval=2

# Function to calculate power consumption
calculate_power() {
    local total_power=0
    declare -a T0=($(sudo cat /sys/class/powercap/*/energy_uj))
    sleep $refresh_interval
    declare -a T1=($(sudo cat /sys/class/powercap/*/energy_uj))

    for i in "${!T0[@]}"; do 
        local power=$(awk "BEGIN {printf \"%.1f\", $((${T1[i]} - ${T0[i]})) / $refresh_interval / 1e6}")
        echo "System Power Consumption: $power W"
        total_power=$(awk "BEGIN {print $total_power + $power}")
    done

    echo "GPU Power Usage:"
    local gpu_powers=($(nvidia-smi --query-gpu=power.draw --format=csv,noheader,nounits))
    for gpu_power in "${gpu_powers[@]}"; do
        echo "$gpu_power W"
        total_power=$(awk "BEGIN {print $total_power + $gpu_power}")
    done

    echo "Total Power Consumption: $total_power W"
}

# Check if the required directory exists
if [ ! -d "/sys/class/powercap" ]; then
    echo "Powercap directory not found. This script may not work on your system."
    exit 1
fi

# Main loop
while true; do
    clear
    calculate_power
    sleep $display_sleep_interval
done

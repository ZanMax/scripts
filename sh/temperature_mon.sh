#!/bin/bash

# Nessesary Packages: lm-sensors
# sudo apt -y install lm-sensors

# Detect CPU Brand
cpu_brand=$(grep -m 1 "vendor_id" /proc/cpuinfo | awk '{print $3}')

if [[ $cpu_brand == "GenuineIntel" ]]; then
    # Intel-based temperature extraction
    # Get overall CPU Package temperature
    cpu_temp=$(sensors | awk '/Package id 0:/ {print $4}')
    
    # Get NVME temperature
    nvme_temp=$(sensors | awk '/Composite/ {print $2}')
    
    # Get PCH temperature
    pch_temp=$(sensors | awk '/temp1:/ {print $2}' | head -1)
    
    echo "CPU Temperature: $cpu_temp"
    echo "NVME Temperature: $nvme_temp"
    echo "PCH Temperature: $pch_temp"

elif [[ $cpu_brand == "AuthenticAMD" ]]; then
    # AMD-based temperature extraction
    # Get GPU temperature from the amdgpu sensor
    gpu_temp=$(sensors | awk '/edge/ {print $2}')
    
    # Get CPU temperature from the k10temp sensor
    cpu_temp=$(sensors | awk '/Tctl/ {print $2}')
    
    # Get NVME temperature from the nvme-pci sensor
    nvme_temp=$(sensors | awk '/Composite/ {print $2}')
    
    echo "CPU Temperature: $cpu_temp"
    echo "GPU Temperature: $gpu_temp"
    echo "NVME Temperature: $nvme_temp"

else
    echo "Unknown processor vendor."
fi

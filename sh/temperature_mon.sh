#!/bin/bash

# Get CPU temperature from the k10temp sensor
cpu_temp=$(sensors | awk '/Tctl/ {print $2}')

# Get GPU temperature from the amdgpu sensor
gpu_temp=$(sensors | awk '/edge/ {print $2}')

# Get NVME temperature from the nvme-pci sensor
nvme_temp=$(sensors | awk '/Composite/ {print $2}')

echo "CPU Temperature: $cpu_temp"
echo "GPU Temperature: $gpu_temp"
echo "NVME Temperature: $nvme_temp"
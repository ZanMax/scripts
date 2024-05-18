#!/bin/bash

# Search for NVIDIA and AMD GPUs and store the result
gpu_info=$(lspci | grep -E "NVIDIA|AMD")

# Check if AMD GPU is found
if echo "$gpu_info" | grep -q "AMD"; then
    echo "AMD GPU found. Executing rocm-smi."
    rocm-smi
# Check if NVIDIA GPU is found
elif echo "$gpu_info" | grep -q "NVIDIA"; then
    echo "NVIDIA GPU found. Executing nvidia-smi."
    nvidia-smi
else
    echo "No AMD or NVIDIA GPU found."
fi

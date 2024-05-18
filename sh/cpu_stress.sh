#!/bin/bash

# sudo apt-get install stress

# Get the number of CPU cores
NUM_CORES=$(grep -c ^processor /proc/cpuinfo)

# Load all cores for 60 seconds (you can adjust the time as needed)
stress --cpu $NUM_CORES --timeout 60s

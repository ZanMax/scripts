#!/bin/bash
sudo cat access.log | awk '{print $4}' | uniq -c | sort -rn | head
#!/bin/bash
#
# Connect to remote IP
#
# arguments: remote IP, port, ip indise, port inside
#
#

"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" "http://127.0.0.1:8080"

ssh -L 8080:192.168.88.1:80 user@34.49.54.180
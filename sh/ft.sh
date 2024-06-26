#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 -m <mode> -l <local_file> -r <remote_file> -u <user> -h <host> -k <key>"
    echo "  -m <mode>         Mode of transfer: upload or download"
    echo "  -l <local_file>   Path to the local file"
    echo "  -r <remote_file>  Path to the remote file"
    echo "  -u <user>         Remote server username"
    echo "  -h <host>         Remote server host"
    echo "  -k <key>          Path to the SSH key file"
    exit 1
}

# Parse command line arguments
while getopts ":m:l:r:u:h:k:" opt; do
    case $opt in
        m) mode=$OPTARG ;;
        l) local_file=$OPTARG ;;
        r) remote_file=$OPTARG ;;
        u) user=$OPTARG ;;
        h) host=$OPTARG ;;
        k) key=$OPTARG ;;
        \?) echo "Invalid option -$OPTARG" >&2; usage ;;
        :) echo "Option -$OPTARG requires an argument." >&2; usage ;;
    esac
done

# Check if all required arguments are provided
if [ -z "$mode" ] || [ -z "$local_file" ] || [ -z "$remote_file" ] || [ -z "$user" ] || [ -z "$host" ] || [ -z "$key" ]; then
    usage
fi

# Perform the requested transfer
if [ "$mode" == "upload" ]; then
    scp -i "$key" "$local_file" "$user@$host:$remote_file"
elif [ "$mode" == "download" ]; then
    scp -i "$key" "$user@$host:$remote_file" "$local_file"
else
    echo "Invalid mode specified. Use 'upload' or 'download'."
    usage
fi

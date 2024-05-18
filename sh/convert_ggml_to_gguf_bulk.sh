#!/bin/bash

# Configuration Variables
input_directory="/path/to/input/directory"  # Update with the path to your input directory containing .bin files
output_directory="/root/AI/result"  # Change this if you want a different output directory
path_convert_llama="/path/to/convert-llama-ggml-to-gguf.py"  # Update with the actual path to your Python script

# Check if input directory exists
if [ ! -d "$input_directory" ]; then
    echo "Error: Directory $input_directory does not exist!"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$output_directory"

# Iterate over each .bin file in the input directory and process it
for input_path in "$input_directory"/*.bin; do
    # Check if file exists (this is necessary in case no .bin files are found)
    if [ ! -f "$input_path" ]; then
        echo "No .bin files found in $input_directory"
        break
    fi

    # Define the output path based on input file's name
    base_name=$(basename "$input_path" .bin)   # remove the .bin extension
    output_path="$output_directory/$base_name.gguf"  # append the .gguf extension

    # Run the Python conversion script
    python3 "$path_convert_llama" --input "$input_path" --output "$output_path"

    # Print the result to the user
    if [ $? -eq 0 ]; then
        echo "Converted $input_path to $output_path successfully!"
    else
        echo "Conversion failed for $input_path."
    fi
done

#!/bin/bash

output_directory="/path/to/results"
path_convert_llama="/path/to/convert-llama-ggml-to-gguf.py"

echo "Please enter the path to the GGML model:"
read input_path

if [ ! -f "$input_path" ]; then
    echo "Error: File $input_path does not exist!"
    exit 1
fi

base_name=$(basename "$input_path" .bin)
output_path="$output_directory/$base_name.gguf"

python3 "$path_convert_llama" --input "$input_path" --output "$output_path"

if [ $? -eq 0 ]; then
    echo "Conversion successful! Output saved to $output_path"
else
    echo "Conversion failed."
fi

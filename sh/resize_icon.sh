#!/bin/bash

# Check for ImageMagick installation
if ! type convert &> /dev/null; then
    echo "ImageMagick is not installed. Please install it to continue."
    exit 1
fi

# Check if an image file was provided as an argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <ImagePath>"
    exit 1
fi

IMAGE_PATH="$1"
SIZES=(512 256 128 64 32 16)

# Extract the base path without the size
BASE_PATH="${IMAGE_PATH%_*}"

# Loop through the sizes and create resized images with corrected naming
for size in "${SIZES[@]}"; do
    OUTPUT_FILE="${BASE_PATH}_${size}x${size}.png"
    convert "$IMAGE_PATH" -resize ${size}x${size}! "$OUTPUT_FILE"
    echo "Generated $OUTPUT_FILE"
done

echo "Resizing complete."

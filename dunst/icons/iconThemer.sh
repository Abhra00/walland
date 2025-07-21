#!/bin/bash

# Usage: ./recolor.sh input_dir "#from_color" "#to_color"
# Example: ./recolor.sh ./images "#ff0000" "#00ff00"

INPUT_DIR="$1"
FROM_COLOR="#C0CAF5"
TO_COLOR="#FFFFFF"
OUTPUT_DIR="${INPUT_DIR}/recolored"

# Ensure all arguments are provided
if [ -z "$INPUT_DIR" ] ; then
    echo "Usage: $0 <directory>"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Loop through images
for img in "$INPUT_DIR"/*.{png,jpg,jpeg}; do
    [ -e "$img" ] || continue  # skip if no files match
    filename=$(basename "$img")
    
    echo "Processing $filename ..."
    
    magick "$img" -fuzz 10% -fill "$TO_COLOR" -opaque "$FROM_COLOR" "$OUTPUT_DIR/$filename"
done

echo "Done! Converted images saved in: $OUTPUT_DIR"


#!/usr/bin/env bash

# Ensure ImageMagick is installed
if ! command -v convert &>/dev/null; then
  echo "ImageMagick is not installed. Install it using: sudo apt install imagemagick"
  exit 1
fi

# Set directory to current directory or user-specified directory
dir="${1:-.}"

# Convert all .png files to .jpg
for img in "$dir"/*.png; do
  [ -e "$img" ] || continue # Skip if no files match
  filename="${img%.*}"
  magick "$img" "$filename.jpg"
  echo "Converted: $img -> $filename.jpg"
done

echo "Conversion complete."

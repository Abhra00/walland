#!/usr/bin/env bash

# Take input directory as first argument, default to current dir
base_dir="${1:-.}"

# Check if directory exists
if [ ! -d "$base_dir" ]; then
  echo "❌ Directory not found: $base_dir"
  exit 1
fi

# Loop through all subdirectories (recursively)
find "$base_dir" -type d | while read -r dir; do
  jpg2png.sh $dir
  cp $dir/*.png $HOME/walls
done

echo "done"

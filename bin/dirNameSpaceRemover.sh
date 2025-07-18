#!/bin/bash

# Input directory, default to current dir
base_dir="${1:-.}"

# Check if directory exists
if [ ! -d "$base_dir" ]; then
  echo "❌ Directory not found: $base_dir"
  exit 1
fi

# Recursively find only directories with spaces in their names, deepest first
find "$base_dir" -depth -type d -name "* *" | while IFS= read -r dir; do
  parent_dir=$(dirname "$dir")
  base_name=$(basename "$dir")
  new_base_name="${base_name// /_}"
  new_path="$parent_dir/$new_base_name"

  echo "🔄 Renaming: '$dir' → '$new_path'"
  mv "$dir" "$new_path"
done

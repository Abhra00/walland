#!/usr/bin/env bash
#  ┏┳┓┓┏┏┓┳┳┓┏┓  ┏┓┓ ┏┳┏┳┓┏┓┓┏┏┓┳┓
#   ┃ ┣┫┣ ┃┃┃┣ ━━┗┓┃┃┃┃ ┃ ┃ ┣┫┣ ┣┫
#   ┻ ┛┗┗┛┛ ┗┗┛  ┗┛┗┻┛┻ ┻ ┗┛┛┗┗┛┛┗
#

theme_dir="$HOME/.config/wal/colorschemes"
postrun_script="$HOME/.config/wal/postrun.sh"
scriptsDir="$HOME/.config/hypr/scripts"
rofi_theme="$HOME/.config/rofi/themeSwitcher.rasi"
wall_collection_dir="$HOME/.local/share/wallCollection"
wall_selection_dir="$HOME/walls/"
theme_mode_file="$HOME/.local/share/themeMode"

# Create a temp file to map basenames to full paths
temp_map=$(mktemp)

# Map existing theme names
find "${theme_dir}" -type f | while read -r file; do
    base="$(basename "${file%.*}")"
    echo "$base" >>"$temp_map"
done

# Add "material-you" option at the end
echo "material-you" >>"$temp_map"

# Show names in rofi
selected_theme=$(rofi -dmenu -p "🌈" -theme "$rofi_theme" <"$temp_map")

# Clean up
rm "$temp_map"

# Exit if nothing selected
[[ -z "${selected_theme}" ]] && exit 0

# If selected "material-you"
if [[ "$selected_theme" == "material-you" ]]; then
    # Write theme name
    echo "material-you" >"$theme_mode_file"

    # Delete all wallpapers from wall_selection_dir
    rm -rf "${wall_selection_dir:?}"/*

    # Move selected theme wallpapers to selection dir
    cp "$wall_collection_dir/$selected_theme"/* "$wall_selection_dir"

    # Set a random wallpaper and generate theme
    "$scriptsDir/randWall.sh"

    exit 0
fi

# Else — save theme name and apply it
echo "$selected_theme" >"$theme_mode_file"

# Get full path of selected theme
selected_theme_fpath=$(find "${theme_dir}" -type f | while read -r file; do
    base="$(basename "${file%.*}")"
    if [ "$base" = "$selected_theme" ]; then
        echo "$file"
        break
    fi
done)

# Delete all wallpapers from wall_selection_dir
rm -rf "${wall_selection_dir:?}"/*

# Move selected theme wallpapers to selection dir
cp "$wall_collection_dir/$selected_theme"/* "$wall_selection_dir"

# Apply the theme
wal -e --theme -f "$selected_theme_fpath" -o "$postrun_script"

# Set random wallpaper
"$scriptsDir/randWall.sh"

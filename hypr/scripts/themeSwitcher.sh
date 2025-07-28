#!/usr/bin/env bash
#  ┏┳┓┓┏┏┓┳┳┓┏┓  ┏┓┓ ┏┳┏┳┓┏┓┓┏┏┓┳┓
#   ┃ ┣┫┣ ┃┃┃┣ ━━┗┓┃┃┃┃ ┃ ┃ ┣┫┣ ┣┫
#   ┻ ┛┗┗┛┛ ┗┗┛  ┗┛┗┻┛┻ ┻ ┗┛┛┗┗┛┛┗
#

# Declare needed variables
theme_dir="$HOME/.config/wal/colorschemes"
postrun_script="$HOME/.config/wal/postrun.sh"
scriptsDir="$HOME/.config/hypr/scripts"
rofi_theme="$HOME/.config/rofi/themeSwitcher.rasi"
wall_collection_dir="$HOME/.local/share/wallCollection"
wall_selection_dir="$HOME/walls/"

# Create a temp file to map basenames to full paths
temp_map=$(mktemp)

# Map the theme names in a temporary file
find "${theme_dir}" -type f | while read -r file; do
    base="$(basename "${file%.*}")"
    echo "$base" >>"$temp_map"
done

# Show mapped names in rofi
selected_theme=$(rofi -dmenu -p "🌈" -theme "$rofi_theme" <"$temp_map")

# Delete the temp file
rm "$temp_map"

# Exit immediately if there is no selection
[[ -z "${selected_theme}" ]] && exit 0

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

# Move selected theme wallpapers to wallpaper selection directory
cp "$wall_collection_dir"/"$selected_theme"/* "$wall_selection_dir"

# Set the theme using pywal
wal --theme -f "$selected_theme_fpath" -o "$postrun_script"

# Choose a random wallpaper
wall=$(find "${wall_selection_dir}" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | shuf -n 1)

echo $wall

# Find current focues monitor
focused_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')

# SWWW Config
FPS=60
TYPE="any"
DURATION=2
BEZIER=".43,1.19,1,.4"
SWWW_PARAMS="--transition-fps $FPS --transition-type $TYPE --transition-duration $DURATION --transition-bezier $BEZIER"

# Initiate swww if not running
swww query || swww-daemon --format xrgb

# Set wallpaper
swww img -o "${focused_monitor}" "${wall}" ${SWWW_PARAMS}

# Run magic script
"${scriptsDir}"/magic.sh "ThemeMagick 💫"

#!/usr/bin/env bash
#  ┳┓┏┓┳┓┳┓┓ ┏┏┓┓ ┓
#  ┣┫┣┫┃┃┃┃┃┃┃┣┫┃ ┃
#  ┛┗┛┗┛┗┻┛┗┻┛┛┗┗┛┗┛
#

# Set variables
wall_dir="$HOME/walls"
scriptsDir="$HOME/.config/hypr/scripts"
focused_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')
materialYouScrPath="$HOME/.config/wal/material-you-tool/material-you.py"

# Choose a random wallpaper
wall=$(find "$wall_dir" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | shuf -n 1)

# Check if wallpaper was found
if [[ -z "$wall" ]]; then
    echo "❌ No wallpaper found in $wall_dir"
    exit 1
fi

# Ensure hyprpaper is running
if ! pgrep -x "hyprpaper" >/dev/null; then
    echo "🚀 Starting hyprpaper..."
    hyprpaper &
    sleep 0.5 # Wait a bit to ensure the socket is ready
else
    echo "✅ hyprpaper is already running"
fi

# Preload the wallpaper
hyprctl hyprpaper preload "$wall"
sleep 0.1 # Optional small delay

# Set the wallpaper
hyprctl hyprpaper wallpaper "$focused_monitor,$wall"

# Check if the theme is material-you or not
if [[ $(<~/.local/share/themeMode) == "material-you" ]]; then
    python3 "${materialYouScrPath}" "${wall}"

    # Optional: delay before theme script
    sleep 0.2

    # Run theme script
    "$scriptsDir/magic.sh" "Material-You-Magick 💫"

    exit 0
fi

# Optional: delay before theme script
sleep 0.2

# Run theme script
"$scriptsDir/magic.sh" "ThemeMagick 💫"

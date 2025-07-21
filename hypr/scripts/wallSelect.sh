#!/usr/bin/env bash
#  ┓ ┏┏┓┓ ┓ ┏┓┏┓┓ ┏┓┏┓┏┳┓
#  ┃┃┃┣┫┃ ┃ ┗┓┣ ┃ ┣ ┃  ┃ 
#  ┗┻┛┛┗┗┛┗┛┗┛┗┛┗┛┗┛┗┛ ┻ 
#                        

# Thank you gh0stzk for the script 🤲 means a lot
# Copyright (C) 2021-2025 gh0stzk <z0mbi3.zk@protonmail.com>
# Licensed under GPL-3.0 license

# WallSelect - Dynamic wallpaper selector with intelligent caching system
# Features:
#   ✔ Multi-monitor support with scaling
#   ✔ Auto-updating menu (add/delete wallpapers without restart)
#   ✔ Parallel image processing (optimized CPU usage)
#   ✔ XXHash64 checksum verification for cache integrity
#   ✔ Orphaned cache detection and cleanup
#   ✔ Adaptive icon sizing based on screen resolution
#   ✔ Lockfile system for safe concurrent operations
#   ✔ Handle gif files separately
#   ✔ Rofi integration with theme support
#   ✔ Dynamic theming using pywal
#
#
# Dependencies:
#   → Core: hyprland, rofi, jq, xxhsum (xxhash)
#   → Media: swww, imagemagick
#   → GNU: findutils, coreutils, bc



# Set dir varialable
wall_dir="$HOME/walls"
cacheDir="$HOME/.cache/wallcache"
scriptsDir="$HOME/.config/hypr/scripts"

# Create cache dir if not exists
[ -d "$cacheDir" ] || mkdir -p "$cacheDir"


# Get focused monitor
focused_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')

# Get monitor width and DPI
monitor_width=$(hyprctl monitors -j | jq -r --arg mon "$focused_monitor" '.[] | select(.name == $mon) | .width')
scale_factor=$(hyprctl monitors -j | jq -r --arg mon "$focused_monitor" '.[] | select(.name == $mon) | .scale')

# Calculate icon size
icon_size=$(echo "scale=2; ($monitor_width * 14) / ($scale_factor * 96)" | bc)
rofi_override="element-icon{size:${icon_size}px;}"
rofi_command="rofi -i -show -dmenu -theme $HOME/.config/rofi/wallSelect.rasi -theme-str $rofi_override"

# Detect number of cores and set a sensible number of jobs
get_optimal_jobs() {
    local cores=$(nproc)
    (( cores <= 2 )) && echo 2 || echo $(( (cores > 4) ? 4 : cores-1 ))
}

PARALLEL_JOBS=$(get_optimal_jobs)

process_image() {
    local imagen="$1"
    local nombre_archivo=$(basename "$imagen")
    local cache_file="${cacheDir}/${nombre_archivo}"
    local md5_file="${cacheDir}/.${nombre_archivo}.md5"
    local lock_file="${cacheDir}/.lock_${nombre_archivo}"

    local current_md5=$(xxh64sum "$imagen" | cut -d' ' -f1)

    (
        flock -x 200
        if [ ! -f "$cache_file" ] || [ ! -f "$md5_file" ] || [ "$current_md5" != "$(cat "$md5_file" 2>/dev/null)" ]; then
            magick "$imagen" -resize 500x500^ -gravity center -extent 500x500 "$cache_file"
            echo "$current_md5" > "$md5_file"
        fi
        # Clean the lock file after processing
        rm -f "$lock_file"
    ) 200>"$lock_file"
}

# Export variables & functions
export -f process_image
export wall_dir cacheDir

# Clean old locks before starting
rm -f "${cacheDir}"/.lock_* 2>/dev/null || true

# Process files in parallel
find "$wall_dir" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" \) -print0 | \
    xargs -0 -P "$PARALLEL_JOBS" -I {} bash -c 'process_image "{}"'

# Clean orphaned cache files and their locks
for cached in "$cacheDir"/*; do
    [ -f "$cached" ] || continue
    original="${wall_dir}/$(basename "$cached")"
    if [ ! -f "$original" ]; then
        nombre_archivo=$(basename "$cached")
        rm -f "$cached" \
            "${cacheDir}/.${nombre_archivo}.md5" \
            "${cacheDir}/.lock_${nombre_archivo}"
    fi
done

# Clean any remaining lock files
rm -f "${cacheDir}"/.lock_* 2>/dev/null || true

# Check if rofi is already running
if pidof rofi > /dev/null; then
  pkill rofi
fi

# Launch rofi
wall_selection=$(find "${wall_dir}" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) -print0 |
    xargs -0 basename -a |
    LC_ALL=C sort -V |
    while IFS= read -r A; do
        if [[ "$A" =~ \.gif$ ]]; then
            printf "%s\n" "$A"  # Handle gifs by showing only file name
        else
            printf '%s\x00icon\x1f%s/%s\n' "$A" "${cacheDir}" "$A"  # Non-gif files with icon convention
        fi
    done | $rofi_command)

# SWWW Config
FPS=60
TYPE="any"
DURATION=2
BEZIER=".43,1.19,1,.4"
SWWW_PARAMS="--transition-fps $FPS --transition-type $TYPE --transition-duration $DURATION --transition-bezier $BEZIER"


# initiate swww if not running
swww query || swww-daemon --format xrgb

# full wallpaper path
wallpaper_path="${wall_dir}/${wall_selection}"

# set wallpaper & export wall-thumbnails to rofi folder
if [[ -n "$wall_selection" ]]; then

	# set wallpaper
	swww img -o "$focused_monitor" "${wallpaper_path}" $SWWW_PARAMS

	# generate pywal colors
	wait $!
	wal -n -e -i "${wallpaper_path}" --cols16 -o "${XDG_CONFIG_HOME:-$HOME/.config}/wal/postrun.sh"


	#-------Imagemagick magick 👀--------------#
	wait $!

	# convert and resize the current wallpaper & make it image for rofi with blur
	magick "$wallpaper_path" -strip -resize 1000 -gravity center -extent 1000 -blur "30x30" -quality 90 $HOME/.config/rofi/images/currentWalBlur.thumb

	# convert and resize the current wallpaper & make it image for rofi without blur
	magick "$wallpaper_path" -strip -resize 1000 -gravity center -extent 1000 -quality 90 $HOME/.config/rofi/images/currentWal.thumb

	# convert and resize the current wallpaper & make it image for rofi with square format
	magick "$wallpaper_path" -strip -thumbnail 500x500^ -gravity center -extent 500x500 $HOME/.config/rofi/images/currentWal.sqre

	# convert and resize the square formatted & make it image for rofi with drawing polygon
	magick $HOME/.config/rofi/images/currentWal.sqre \( -size 500x500 xc:white -fill "rgba(0,0,0,0.7)" -draw "polygon 400,500 500,500 500,0 450,0" -fill black -draw "polygon 500,500 500,0 450,500" \) -alpha Off -compose CopyOpacity -composite $HOME/.config/rofi/images/currentWalQuad.png && mv $HOME/.config/rofi/images/currentWalQuad.png $HOME/.config/rofi/images/currentWalQuad.quad


	# copy the wallpaper in current-wallpaper file
	wait $!
	ln -sf "$wallpaper_path" "$HOME/.local/share/bg"

	# send notification after completion
	wait $!
	notify-send -e -h string:x-canonical-private-synchronous:matugen_notif "WallSelect 💫" "Pywal & ImageMagick has completed its job" -i $HOME/.local/share/bg

fi


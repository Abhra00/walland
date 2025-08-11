#!/usr/bin/env bash
# ┏┓┏┓┓ ┏┓┳┓┏┓┳┏┓┓┏┓┏┓┳┓
# ┃ ┃┃┃ ┃┃┣┫┃┃┃┃ ┃┫ ┣ ┣┫
# ┗┛┗┛┗┛┗┛┛┗┣┛┻┗┛┛┗┛┗┛┛┗

# Dependencies: hyprpicker, wl-copy, notify-send, Waybar (with signal support)

# Set up config/cache location
loc="$HOME/.cache/colorpicker"
mkdir -p "$loc"
touch "$loc/colors"

# Max number of colors to store
limit=10

# Helper to check if command exists
check() {
    command -v "$1" >/dev/null
}

# List saved colors
[[ "$1" == "-l" ]] && {
    cat "$loc/colors"
    exit
}

# Output for Waybar JSON module
[[ "$1" == "-j" ]] && {
    text="$(head -n 1 "$loc/colors")"
    mapfile -t allcolors < <(tail -n +2 "$loc/colors" | sed '/^$/d')

    if [[ -z "$text" ]]; then
        # No colors picked yet
        text="#888888"
        tooltip="No color chosen"
    else
        tooltip="<b>   COLORS</b>\\n\\n"
        tooltip+="-> <b>$text</b>  <span color='$text'></span>\\n"

        for i in "${allcolors[@]}"; do
            tooltip+="   <b>$i</b>  <span color='$i'></span>\\n"
        done

        tooltip="${tooltip%\\n}" # Remove trailing newline
    fi

    cat <<EOF
{ "text":"<span color='$text'></span>", "tooltip":"$tooltip" }
EOF
    exit
}

# Pick color with hyprpicker
check hyprpicker || {
    notify-send "Color Picker" "❌ hyprpicker is not installed" -u critical
    exit 1
}

killall -q hyprpicker 2>/dev/null

# Pick color and trim newline
color="$(hyprpicker -a | tr -d '\n')"

# Validate color format
[[ "$color" =~ ^#?[0-9a-fA-F]{6}$ ]] || {
    notify-send "Color Picker" "❌ Invalid color format: $color" -u critical
    exit 1
}

# Ensure leading #
[[ "$color" != \#* ]] && color="#$color"

# Copy to clipboard (if wl-copy is installed)
check wl-copy && echo -n "$color" | wl-copy

# Save to history (deduplicated, limited)
prevColors="$(grep -vFx "$color" "$loc/colors" | head -n $((limit - 1)))"
{
    echo "$color"
    echo "$prevColors"
} >"$loc/colors"

# Notification
notify-send "Color Picker" "This color has been selected: $color" -i "$HOME/.local/share/bg.sqre"

# Signal Waybar to refresh
pkill -RTMIN+1 waybar

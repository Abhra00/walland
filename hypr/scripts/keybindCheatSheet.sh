#!/bin/bash
#  ┓┏┓┏┓┓┏┳┓┳┳┓┳┓  ┏┓┓┏┏┓┏┓┏┳┓┏┓┓┏┏┓┏┓┏┳┓
#  ┃┫ ┣ ┗┫┣┫┃┃┃┃┃━━┃ ┣┫┣ ┣┫ ┃ ┗┓┣┫┣ ┣  ┃
#  ┛┗┛┗┛┗┛┻┛┻┛┗┻┛  ┗┛┛┗┗┛┛┗ ┻ ┗┛┛┗┗┛┗┛ ┻
#

KEYBINDS_CONF="$HOME/.config/hypr/modules/keybinds.conf"

# --- Load variable definitions from keybinds.conf ---
# This will find all lines like `$var = something` and export them
eval "$(
    grep -E '^\$[a-zA-Z_][a-zA-Z0-9_]*\s*=' "$KEYBINDS_CONF" |
        sed -E 's/^\$//; s/\s*=\s*/=/' |
        while read -r line; do
            key="${line%%=*}"
            val="${line#*=}"
            # If value starts with .config or config, prefix $HOME
            if [[ "$val" =~ ^(\.config|config) ]]; then
                val="$HOME/$val"
            fi
            echo "export $key=\"$val\""
        done
)"

# --- Extract bind entries into a list ---
mapfile -t BINDINGS < <(
    grep -E '^\s*bind' "$KEYBINDS_CONF" |
        sed -E 's/\s*#.*$//' |
        awk -F, '{
        for (i=1; i<=NF; i++) gsub(/^[ \t]+|[ \t]+$/, "", $i)
        cmd = $3
        for (i=4; i<=NF; i++) cmd = cmd " " $i
        printf "<b>%s + %s</b>  <span color=\"gray\">%s</span>\n", $1, $2, cmd
    }'
)

# --- Show menu in rofi ---
CHOICE=$(printf '%s\n' "${BINDINGS[@]}" | rofi -dmenu -theme "$HOME/.config/rofi/hyprCheatSheet.rasi" -markup-rows -i -p "Hyprland Keybinds:")

# --- Execute selected choice ---
if [[ -n "$CHOICE" ]]; then
    RAW_CMD=$(echo "$CHOICE" | sed -n 's/.*<span color="gray">\([^<]*\)<\/span>.*/\1/p')

    # First pass: expand $variables from keybinds.conf
    EXPANDED_CMD=$(eval "echo \"$RAW_CMD\"")

    # If path starts with .config or config, prefix with $HOME
    if [[ "$EXPANDED_CMD" =~ ^(\.config|config) ]]; then
        EXPANDED_CMD="$HOME/$EXPANDED_CMD"
    fi

    # Run command
    if [[ "$EXPANDED_CMD" == exec* ]]; then
        eval "${EXPANDED_CMD#exec }"
    else
        hyprctl dispatch "$EXPANDED_CMD"
    fi
fi

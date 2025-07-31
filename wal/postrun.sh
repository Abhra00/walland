#!/usr/bin/env bash
#  ┏┓┏┓┏┓┏┳┓┳┓┳┳┳┓  ┏┓┓┏┓ ┏┏┓┓
#  ┃┃┃┃┗┓ ┃ ┣┫┃┃┃┃━━┃┃┗┫┃┃┃┣┫┃
#  ┣┛┗┛┗┛ ┻ ┛┗┗┛┛┗  ┣┛┗┛┗┻┛┛┗┗┛
#

# Source colors.sh file and fix sequences
source "${XDG_CACHE_HOME:-$HOME/.cache}/wal/colors.sh"

fix_sequences() {
    e=$'\e'
    sequences=$(cat)
    foreground_color="$(echo -e "${sequences}\c" | grep --color=never -Eo "${e}]10[^${e}\\\\]*?${e}\\\\" | grep --color=never -Eo "#[0-9A-Fa-f]{6}")"
    background_color="$(echo -e "${sequences}\c" | grep --color=never -Eo "${e}]11[^${e}\\\\]*?${e}\\\\" | grep --color=never -Eo "#[0-9A-Fa-f]{6}")"
    cursor_color="$(echo -e "${sequences}\c" | grep --color=never -Eo "${e}]12[^${e}\\\\]*?${e}\\\\" | grep --color=never -Eo "#[0-9A-Fa-f]{6}")"

    for term in /dev/pts/{0..9}*; do
        echo -e "\e]4;256;${cursor_color}\a\c" >"${term}" 2>/dev/null
        echo -e "\e]4;258;${background_color}\a\c" >"${term}" 2>/dev/null
        echo -e "\e]4;259;${foreground_color}\a\c" >"${term}" 2>/dev/null
    done
}

fix_sequences <"${XDG_CACHE_HOME:-$HOME/.cache}/wal/sequences"

# Upadte pywalfox colors
pywalfox update

# Export colors.env for waybar
jq -r '.colors | to_entries[] | "export COLOR\(.key[5:])=\(.value)"' "$HOME/.cache/wal/colors.json" >"$HOME/.config/waybar/colors.env"
jq -r '.special | to_entries[] | "export \U\(.key | gsub("-"; "_") | ascii_upcase)=\(.value)"' "$HOME/.cache/wal/colors.json" >>"$HOME/.config/waybar/colors.env"

# Chnage zathura colors
zathuraconf="${XDG_CONFIG_HOME:-$HOME/.config}/zathura/zathurarc"
mkdir -p "${zathuraconf%/*}"
mv -n "$zathuraconf" "$zathuraconf.bak"
ln -sf "${XDG_CACHE_HOME:-$HOME/.cache}/wal/zathurarc-pywal" "$zathuraconf"

# Copy qt colors
cp "$HOME/.cache/wal/qtct-colors.conf" "$HOME/.config/qt5ct/colors/pywalqtcolors.conf"
cp "$HOME/.cache/wal/qtct-colors.conf" "$HOME/.config/qt6ct/colors/pywalqtcolors.conf"

# Copy kvantum colors
cp "$HOME/.cache/wal/pywal.kvconfig" "$HOME/.config/Kvantum/pywal/pywal.kvconfig"
cp "$HOME/.cache/wal/pywal.svg" "$HOME/.config/Kvantum/pywal/pywal.svg"

# Copy cava confing and reload  it
cp "$HOME/.cache/wal/colors-cava" "$HOME/.config/cava/config"
pkill -SIGUSR2 cava

# Copy swayimg config
swayimgconf="${XDG_CONFIG_HOME:-$HOME/.config}/swayimg/config"
mkdir -p "${swayimgconf%/*}"
mv -n "$swayimgconf" "$swayimgconf.bak"
ln -sf "${XDG_CACHE_HOME:-$HOME/.cache}/wal/pywal-swayimg-config" "$swayimgconf"

# Refresh useful applications
"$HOME"/.config/hypr/scripts/refresh.sh

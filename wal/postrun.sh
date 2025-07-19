#!/usr/bin/env bash

dunstconf="${XDG_CONFIG_HOME:-$HOME/.config}/dunst/dunstrc"
zathuraconf="${XDG_CONFIG_HOME:-$HOME/.config}/zathura/zathurarc"

source "${XDG_CACHE_HOME:-$HOME/.cache}/wal/colors.sh"

mkdir -p "${dunstconf%/*}" "${zathuraconf%/*}"

mv -n "$dunstconf" "$dunstconf.bak"
mv -n "$zathuraconf" "$zathuraconf.bak"

ln -sf "${XDG_CACHE_HOME:-$HOME/.cache}/wal/dunstrc-pywal" "$dunstconf"
ln -sf "${XDG_CACHE_HOME:-$HOME/.cache}/wal/zathurarc-pywal" "$zathuraconf"

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

# Update pywalfox
pywalfox update

# Restart dunst
pkill dunst
setsid -f dunst

# Copy qt colors
cp $HOME/.cache/wal/qtct-colors.conf $HOME/.config/qt5ct/colors/pywalqtcolors.conf
cp $HOME/.cache/wal/qtct-colors.conf $HOME/.config/qt6ct/colors/pywalqtcolors.conf

# Copy kvantum colors
cp $HOME/.cache/wal/pywal.kvconfig $HOME/.config/Kvantum/pywal/pywal.kvconfig
cp $HOME/.cache/wal/pywal.svg $HOME/.config/Kvantum/pywal/pywal.svg

# Copy cava confing and reload  it
cp $HOME/.cache/wal/colors-cava $HOME/.config/cava/config
pkill -SIGUSR2 cava

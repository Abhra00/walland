#!/usr/bin/env bash
#  ┓ ┏┓┳┳┳┓┏┓┓┏┏┓┳┓
#  ┃ ┣┫┃┃┃┃┃ ┣┫┣ ┣┫
#  ┗┛┛┗┗┛┛┗┗┛┛┗┗┛┛┗
#

# Style-theme
style_theme="$HOME/.config/rofi/launcher4.rasi"

# Run
pkill rofi || true && rofi -show drun -theme "${style_theme}"

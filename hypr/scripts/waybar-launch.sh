#!/usr/bin/env bash
#  ┓ ┏┏┓┓┏┳┓┏┓┳┓  ┓ ┏┓┳┳┳┓┏┓┓┏
#  ┃┃┃┣┫┗┫┣┫┣┫┣┫━━┃ ┣┫┃┃┃┃┃ ┣┫
#  ┗┻┛┛┗┗┛┻┛┛┗┛┗  ┗┛┛┗┗┛┛┗┗┛┛┗
#

source "$HOME"/.config/waybar/colors.env
envsubst <~/.config/waybar/config.jsonc | waybar -c /dev/stdin &

#!/usr/bin/env bash
#  ┳┓┏┓┏┓┳┓┏┓┏┓┓┏
#  ┣┫┣ ┣ ┣┫┣ ┗┓┣┫
#  ┛┗┗┛┻ ┛┗┗┛┗┛┛┗
#

# kill already running processes
_ps=(waybar rofi dunst)
for _prs in "${_ps[@]}"; do
  if pidof "${_prs}" >/dev/null; then
    pkill "${_prs}"
  fi
done

# relaunch waybar
sleep 1
$HOME/.config/hypr/scripts/waybar-launch.sh

# relaunch dunst
sleep 0.5
dunst >/dev/null 2>&1 &

exit 0

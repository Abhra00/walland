#!/usr/bin/env bash
#  ┳┓┏┓┏┓┳┓┏┓┏┓┓┏
#  ┣┫┣ ┣ ┣┫┣ ┗┓┣┫
#  ┛┗┗┛┻ ┛┗┗┛┗┛┛┗
#

# kill already running processes
_ps=(waybar rofi swaync swayosd-server)
for _prs in "${_ps[@]}"; do
    if pidof "${_prs}" >/dev/null; then
        pkill "${_prs}"
    fi
done

# relaunch waybar
sleep 1
"$HOME"/.config/hypr/scripts/waybar-launch.sh

# relaunch swaync
sleep 0.5
swaync >/dev/null 2>&1 &

# relaunch swayosd-server
sleep 0.5
swayosd-server >/dev/null 2>&1 &

exit 0

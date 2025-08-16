#!/usr/bin/env bash
#  ┏┓┏┓┳┓┏┓┏┳┓┏┓┓┏┏┓┏┓┳┓
#  ┗┓┃ ┣┫┣┫ ┃ ┃ ┣┫┃┃┣┫┃┃
#  ┗┛┗┛┛┗┛┗ ┻ ┗┛┛┗┣┛┛┗┻┛
#

app_name="scratchpad-kitty"
workspace="special:scratch"

# Find kitty window
winid=$(hyprctl clients -j | jq -r ".[] | select(.title==\"$app_name\") | .address")

if [[ -z "$winid" ]]; then
    # State 1 → Not running → spawn floating kitty
    hyprctl dispatch exec "[float] kitty --title $app_name"
    sleep 0.3
    hyprctl dispatch focuswindow title:$app_name

else
    # Already exists → check workspace
    ws=$(hyprctl clients -j | jq -r ".[] | select(.title==\"$app_name\") | .workspace.name")
    curws=$(hyprctl activeworkspace -j | jq -r .name)

    if [[ "$ws" == "$curws" ]]; then
        # State 2 → In current ws → hide it
        hyprctl dispatch movetoworkspacesilent "$workspace,address:$winid"

    elif [[ "$ws" == "$workspace" ]]; then
        # State 3 → Hidden in special ws → bring back
        hyprctl dispatch movetoworkspacesilent "$curws,address:$winid"
        sleep 0.1
        hyprctl dispatch focuswindow title:$app_name

    else
        # Edge case → exists in some other ws → pull into current
        hyprctl dispatch movetoworkspacesilent "$curws,address:$winid"
        sleep 0.1
        hyprctl dispatch focuswindow title:$app_name
    fi
fi

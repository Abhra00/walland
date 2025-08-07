#!/usr/bin/env bash

# Icons for battery levels
charging_icons=(󰢜 󰂆 󰂇 󰂈 󰢝 󰂉 󰢞 󰂊 󰂋 󰂅)
discharging_icons=(󱃍 󰁺 󰁻 󰁼 󰁽 󰁿 󰁾 󰂀 󰂁 󰂂 󰁹)

low_threshold=25

for battery in /sys/class/power_supply/BAT?*; do
    # Skip if directory doesn't exist
    [ -d "$battery" ] || continue

    status=$(cat "$battery/status")
    percent=$(cat "$battery/capacity")

    # Clamp percent between 0 and 100
    percent=${percent//[^0-9]/}
    percent=${percent:-0}
    percent=$((percent > 100 ? 100 : percent))

    # Pick icon
    index=$((percent / 10))
    if [[ "$status" == "Charging" || "$status" == "Full" || "$status" == "Unknown" ]]; then
        icon="${charging_icons[$index]}"
        icon_color="green"
    else
        icon="${discharging_icons[$index]}"
        icon_color="magenta"
    fi

    # Color for percentage
    if ((percent <= low_threshold)); then
        percent_color="red"
    else
        percent_color="default"
    fi

    echo "#[fg=$icon_color]$icon #[fg=$percent_color]$percent%"
    exit 0
done

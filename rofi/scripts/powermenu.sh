#!/usr/bin/env bash
#  ┏┓┏┓┓ ┏┏┓┳┓┳┳┓┏┓┳┓┳┳
#  ┃┃┃┃┃┃┃┣ ┣┫┃┃┃┣ ┃┃┃┃
#  ┣┛┗┛┗┻┛┗┛┛┗┛ ┗┗┛┛┗┗┛
#

# Current Theme
theme='powermenu.rasi'

# CMDs
uptime="$(uptime -p | sed -e 's/up //g')"
host=$(hostnamectl hostname)

# Options
shutdown='󰐥'
reboot='󰜉'
lock='󰌾'
suspend='󰤄'
logout='󰈆'
yes=''
no=''

# Rofi CMD
rofi_cmd() {
    rofi -dmenu \
        -p "Goodbye ${USER}@${host}" \
        -mesg "Uptime: $uptime" \
        -theme ${theme}
}

# Confirmation CMD
confirm_cmd() {
    rofi -dmenu \
        -p 'Confirmation' \
        -mesg 'Are you Sure?' \
        -theme confirm.rasi
}

# Ask for confirmation
confirm_exit() {
    echo -e "$yes\n$no" | confirm_cmd
}

# Pass variables to rofi dmenu
run_rofi() {
    echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
}

# Execute Command
run_cmd() {
    selected="$(confirm_exit)"
    if [[ "$selected" == "$yes" ]]; then
        if [[ $1 == '--shutdown' ]]; then
            systemctl poweroff
        elif [[ $1 == '--reboot' ]]; then
            systemctl reboot
        elif [[ $1 == '--suspend' ]]; then
            systemctl suspend
        elif [[ $1 == '--logout' ]]; then
            hyprctl dispatch exit 0
        fi
    else
        exit 0
    fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
$shutdown)
    run_cmd --shutdown
    ;;
$reboot)
    run_cmd --reboot
    ;;
$lock)
    loginctl lock-session
    ;;
$suspend)
    run_cmd --suspend
    ;;
$logout)
    run_cmd --logout
    ;;
esac

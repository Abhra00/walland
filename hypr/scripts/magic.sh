#!/usr/bin/env bash
#  ┳┳┓┏┓┏┓┳┏┓
#  ┃┃┃┣┫┃┓┃┃
#  ┛ ┗┛┗┗┛┻┗┛
#

# utility variables
focused_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')
wallpaper_path=$(hyprctl hyprpaper listactive | grep "${focused_monitor}" | awk -F ' = ' '{print $2}')

# set gtk theme
gsettings set org.gnome.desktop.interface gtk-theme ""
gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3

#-------Imagemagick magick 👀--------------#

# convert and resize the current wallpaper & make it image for rofi with blur
magick "$wallpaper_path" -strip -resize 1000 -gravity center -extent 1000 -blur "30x30" -quality 90 "$HOME/.config/rofi/images/currentWalBlur.thumb"

# convert and resize the current wallpaper & make it image for rofi without blur
magick "$wallpaper_path" -strip -resize 1000 -gravity center -extent 1000 -quality 90 "$HOME/.config/rofi/images/currentWal.thumb"

# convert and resize the current wallpaper & make it image for rofi with square format
magick "$wallpaper_path" -strip -thumbnail 500x500^ -gravity center -extent 500x500 "$HOME/.config/rofi/images/currentWal.sqre"

# convert and resize the square formatted & make it image for rofi with drawing polygon
magick "$HOME/.config/rofi/images/currentWal.sqre" \( -size 500x500 xc:white -fill "rgba(0,0,0,0.7)" -draw "polygon 400,500 500,500 500,0 450,0" -fill black -draw "polygon 500,500 500,0 450,500" \) -alpha Off -compose CopyOpacity -composite "$HOME/.config/rofi/images/currentWalQuad.png" && mv "$HOME/.config/rofi/images/currentWalQuad.png" "$HOME/.config/rofi/images/currentWalQuad.quad"

# copy the wallpaper in current-wallpaper file
sleep 0.5
ln -sf "$wallpaper_path" "$HOME/.local/share/bg"

# send notification after completion
sleep 0.5
notify-send -e -h string:x-canonical-private-synchronous:matugen_notif "$1" "JOB DONE BOIIIII !!!!" -i "$HOME/.local/share/bg"

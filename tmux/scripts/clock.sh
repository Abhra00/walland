#!/usr/bin/env bash

clock=$(date '+%I')

case "$clock" in
"00") icon="󱑖 " ;;
"01") icon="󱑋 " ;;
"02") icon="󱑌 " ;;
"03") icon="󱑍 " ;;
"04") icon="󱑎 " ;;
"05") icon="󱑏 " ;;
"06") icon="󱑐 " ;;
"07") icon="󱑑 " ;;
"08") icon="󱑒 " ;;
"09") icon="󱑓 " ;;
"10") icon="󱑔 " ;;
"11") icon="󱑕 " ;;
"12") icon="󱑖 " ;;
esac

time=$(date '+%H:%M')
RESET="#[fg=default,bg=default,nobold,noitalics,nounderscore,nodim]"

echo "#[fg=blue,bg=default]${icon}${RESET}#[bg=default]${time}"

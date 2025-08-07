#!/usr/bin/env bash

accent="blue" # Or use an env or tmux variable if you want dynamic color
icon="#[fg=${accent}] "
path="#[fg=default]#{b:pane_current_path}"

echo "${icon}${path}"

#!/usr/bin/env bash

# Get current working directory of active pane
pane_path=$(tmux display -p -F "#{pane_current_path}")

# Try to get git branch
branch=$(git -C "$pane_path" rev-parse --abbrev-ref HEAD 2>/dev/null)

# If inside a git repo, display the branch with an icon
if [ -n "$branch" ]; then
    echo "#[fg=magenta] ${branch}"
fi

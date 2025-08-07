#!/usr/bin/env bash

accent="magenta"

# Each segment only renders if client_prefix is active
left="#[noreverse]#{?client_prefix,█,}"
icon="#[reverse]#{?client_prefix,,}"
right="#[noreverse]#{?client_prefix,█ ,}"

# Final combined client_prefix segment
echo "#[fg=${accent}]${left}${icon}${right}"

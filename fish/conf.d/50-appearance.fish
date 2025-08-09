#  ┏┓┏┓  ┏┓┏┓┏┓┏┓┏┓┳┓┏┓┳┓┏┓┏┓
#  ┣┓┃┫━━┣┫┃┃┃┃┣ ┣┫┣┫┣┫┃┃┃ ┣ 
#  ┗┛┗┛  ┛┗┣┛┣┛┗┛┛┗┛┗┛┗┛┗┗┛┗┛
#                            

# Source pywal colors
source ~/.cache/wal/colors.fish

# Custom colors
if status is-interactive
    # custom colors
    command cat ~/.cache/wal/sequences.txt 2> /dev/null
end

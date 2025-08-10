#  ┏┓┏┓  ┏┓┏┓┏┓┏┓┏┓┳┓┏┓┳┓┏┓┏┓
#  ┣┓┃┫━━┣┫┃┃┃┃┣ ┣┫┣┫┣┫┃┃┃ ┣ 
#  ┗┛┗┛  ┛┗┣┛┣┛┗┛┛┗┛┗┛┗┛┗┗┛┗┛
#                            

# Source pywal colors
source ~/.cache/wal/colors.fish

# Prompt & custom colors
if status is-interactive

    # custom colors
    command cat ~/.cache/wal/sequences.txt 2> /dev/null
    
    # starship prompt
    starship init fish | source
end

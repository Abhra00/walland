function fish_greeting
    echo -ne '\x1b[38;5;31m'  # Set colour to primary
    echo '                                        '
    echo '        ┏┓┏┓┏┓━━━━━┏┓━┏┓━━━━━━━━━━━━┏┓  '
    echo '        ┃┃┃┃┃┃━━━━━┃┃━┃┃━━━━━━━━━━━━┃┃  '
    echo '        ┃┃┃┃┃┃┏━━┓━┃┃━┃┃━┏━━┓━┏━┓━┏━┛┃  '
    echo '        ┃┗┛┗┛┃┗━┓┃━┃┃━┃┃━┗━┓┃━┃┏┓┓┃┏┓┃  '
    echo '        ┗┓┏┓┏┛┃┗┛┗┓┃┗┓┃┗┓┃┗┛┗┓┃┃┃┃┃┗┛┃  '
    echo '        ━┗┛┗┛━┗━━━┛┗━┛┗━┛┗━━━┛┗┛┗┛┗━━┛  '
    echo '        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  '
    echo '        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  '
    set_color normal
    blocks.sh
    fastfetch --key-padding-left 5
end

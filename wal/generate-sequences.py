#  ┏┓┏┓┳┓┏┓┳┓┏┓┏┳┓┏┓  ┏┓┳┓┏┓┳  ┏┓┏┓┏┓┳┳┏┓┳┓┏┓┏┓┏┓
#  ┃┓┣ ┃┃┣ ┣┫┣┫ ┃ ┣   ┣┫┃┃┗┓┃  ┗┓┣ ┃┃┃┃┣ ┃┃┃ ┣ ┗┓
#  ┗┛┗┛┛┗┗┛┛┗┛┗ ┻ ┗┛  ┛┗┛┗┗┛┻  ┗┛┗┛┗┻┗┛┗┛┛┗┗┛┗┛┗┛
#                                                



import json
from pathlib import Path

# === Config ===
colors_json_path = Path.home() / ".cache/wal/colors.json"
output_path = Path.home() / ".cache/wal/sequences.txt"
total_colors = 256  # Change to 88 if you want 88-color terminals

# === Load colors.json ===
with open(colors_json_path) as f:
    data = json.load(f)

# Get base colors from colors.json
colors = []
for i in range(16):
    key = f"color{i}"
    color = data["colors"].get(key)
    if not color:
        raise ValueError(f"{key} not found in colors.json!")
    colors.append(color)

# === Generate ANSI sequences ===
with open(output_path, "w") as f:
    for i in range(total_colors):
        hex_color = colors[i % len(colors)]
        f.write(f"\x1b]4;{i};{hex_color}\x1b\\")

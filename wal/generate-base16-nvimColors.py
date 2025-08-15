#!/usr/bin/env python3
# ┏┓┓┏┓ ┏┏┓┓   ┳┓┏┓┏┓┏┓┓┏┓  ┏┓┏┓┓ ┏┓┳┓┏┓
# ┃┃┗┫┃┃┃┣┫┃ ━━┣┫┣┫┗┓┣ ┃┣┓━━┃ ┃┃┃ ┃┃┣┫┗┓
# ┣┛┗┛┗┻┛┛┗┗┛  ┻┛┛┗┗┛┗┛┻┗┛  ┗┛┗┛┗┛┗┛┛┗┗┛


import json
from pathlib import Path
import colorsys

# --- Color utils ---
def hex_to_rgb(hex_color):
    hex_color = hex_color.lstrip("#")
    return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

def rgb_to_hex(rgb):
    return "#{:02X}{:02X}{:02X}".format(*rgb)

def adjust_lightness(hex_color, factor):
    r, g, b = [x / 255.0 for x in hex_to_rgb(hex_color)]
    h, l, s = colorsys.rgb_to_hls(r, g, b)
    l = max(0, min(1, l * factor))
    r, g, b = colorsys.hls_to_rgb(h, l, s)
    return rgb_to_hex((int(r * 255), int(g * 255), int(b * 255)))

def blend(hex1, hex2, ratio):
    r1, g1, b1 = hex_to_rgb(hex1)
    r2, g2, b2 = hex_to_rgb(hex2)
    r = int(r1 + (r2 - r1) * ratio)
    g = int(g1 + (g2 - g1) * ratio)
    b = int(b1 + (b2 - b1) * ratio)
    return rgb_to_hex((r, g, b))

# --- Load Pywal colors.json ---
colors_file = Path.home() / ".cache/wal/colors.json"
with open(colors_file) as f:
    data = json.load(f)

bg = data["special"]["background"]
fg = data["special"]["foreground"]
color = data["colors"]

# Base16 grey scale based on background/foreground
base00 = bg
base01 = adjust_lightness(bg, 1.45)
base02 = adjust_lightness(bg, 1.65)
base03 = adjust_lightness(bg, 1.95)
base04 = adjust_lightness(fg, 0.85)
base05 = fg
base06 = adjust_lightness(fg, 1.10)
base07 = adjust_lightness(fg, 1.20)

# Accents
base08 = color["color1"]   # Red
base09 = color["color9"]   # Orange / bright red
base0A = color["color11"]  # Yellow
base0B = color["color10"]  # Green
base0C = color["color14"]  # Cyan
base0D = color["color12"]  # Blue
base0E = color["color13"]  # Magenta
base0F = blend(color["color14"], color["color13"], 0.5)  # Cyan + Magenta blend

# --- Output Lua ---
ascii_header = """--  ┏┓┓┏┓ ┏┏┓┓   ┳┓┏┓┏┓┏┓┓┏┓  ┏┓┏┓┓ ┏┓┳┓┏┓
--  ┃┃┗┫┃┃┃┣┫┃ ━━┣┫┣┫┗┓┣ ┃┣┓━━┃ ┃┃┃ ┃┃┣┫┗┓
--  ┣┛┗┛┗┻┛┛┗┗┛  ┻┛┛┗┗┛┗┛┻┗┛  ┗┛┗┛┗┛┗┛┛┗┗┛
--                                        


"""
lua_template = ascii_header + "-- stylua: ignore\nreturn {\n"
for name, value in [
    ("base00", base00),
    ("base01", base01),
    ("base02", base02),
    ("base03", base03),
    ("base04", base04),
    ("base05", base05),
    ("base06", base06),
    ("base07", base07),
    ("base08", base08),
    ("base09", base09),
    ("base0A", base0A),
    ("base0B", base0B),
    ("base0C", base0C),
    ("base0D", base0D),
    ("base0E", base0E),
    ("base0F", base0F),
]:
    lua_template += f'  {name} = "{value}",\n'
lua_template += "}\n"

output_file = Path.home() / ".cache/wal/colors-base16.lua"
output_file.write_text(lua_template)
print(f"✅ Base16 Lua theme saved to {output_file}")


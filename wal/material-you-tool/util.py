#  ┳┳┓┏┓┏┳┓┏┓┳┓┳┏┓┓   ┓┏┏┓┳┳  ┳┳┏┳┓┳┓ ┏┓
#  ┃┃┃┣┫ ┃ ┣ ┣┫┃┣┫┃ ━━┗┫┃┃┃┃━━┃┃ ┃ ┃┃ ┗┓
#  ┛ ┗┛┗ ┻ ┗┛┛┗┻┛┗┗┛  ┗┛┗┛┗┛  ┗┛ ┻ ┻┗┛┗┛
#                                       


import math


def rgba_to_hex(rgba: list) -> str:
    return "#{:02x}{:02x}{:02x}".format(*rgba)


def calculate_optimal_size(width: int, height: int, bitmap_size: int) -> tuple:
    image_area = width * height
    bitmap_area = bitmap_size**2
    scale = math.sqrt(bitmap_area / image_area) if image_area > bitmap_area else 1
    new_width = round(width * scale)
    new_height = round(height * scale)
    if new_width == 0:
        new_width = 1
    if new_height == 0:
        new_height = 1
    return new_width, new_height

def blend_hex(hex1: str, hex2: str, ratio: float = 0.5) -> str:
    """Blend two hex colors. ratio=0.5 means equal blend."""
    h1 = hex1.lstrip('#')
    h2 = hex2.lstrip('#')
    r1, g1, b1 = int(h1[0:2], 16), int(h1[2:4], 16), int(h1[4:6], 16)
    r2, g2, b2 = int(h2[0:2], 16), int(h2[2:4], 16), int(h2[4:6], 16)
    r = int(r1 * ratio + r2 * (1 - ratio))
    g = int(g1 * ratio + g2 * (1 - ratio))
    b = int(b1 * ratio + b2 * (1 - ratio))
    return f"#{r:02x}{g:02x}{b:02x}"


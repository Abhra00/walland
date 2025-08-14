#  ┳┳┓┏┓┏┳┓┏┓┳┓┳┏┓┓   ┓┏┏┓┳┳  ┏┳┓┏┓┏┓┓ 
#  ┃┃┃┣┫ ┃ ┣ ┣┫┃┣┫┃ ━━┗┫┃┃┃┃━━ ┃ ┃┃┃┃┃ 
#  ┛ ┗┛┗ ┻ ┗┛┛┗┻┛┗┗┛  ┗┛┗┛┗┛   ┻ ┗┛┗┛┗┛
#                                      


import os
import sys
import json
import subprocess
from PIL import Image
from materialyoucolor.quantize import QuantizeCelebi
from materialyoucolor.hct import Hct
from materialyoucolor.scheme.scheme_tonal_spot import SchemeTonalSpot
from materialyoucolor.scheme.scheme_vibrant import SchemeVibrant
from materialyoucolor.scheme.scheme_expressive import SchemeExpressive
from materialyoucolor.dynamiccolor.material_dynamic_colors import MaterialDynamicColors
from materialyoucolor.score.score import Score

from util import rgba_to_hex, calculate_optimal_size, blend_hex  # from your util.py

# Ordered list of allowed variables (from your screenshot)
ALLOWED_KEYS = [
    "primary",
    "onPrimary",
    "primaryContainer",
    "onPrimaryContainer",
    "secondary",
    "onSecondary",
    "secondaryContainer",
    "onSecondaryContainer",
    "tertiary",
    "onTertiary",
    "tertiaryContainer",
    "onTertiaryContainer",
    "error",
    "onError",
    "errorContainer",
    "onErrorContainer",
    "background",
    "onBackground",
    "surface",
    "onSurface",
    "surfaceVariant",
    "onSurfaceVariant",
    "outline",
    "outlineVariant",
    "shadow",
    "scrim",
    "inverseSurface",
    "inverseOnSurface",
    "inversePrimary"
]

def get_colors_from_img(path: str, dark_mode: bool) -> dict[str, str]:
    """Extract only ALLOWED_KEYS colors from an image using Material You algorithm."""
    path = os.path.expanduser(path)
    image = Image.open(path)
    wsize, hsize = image.size
    wsize_new, hsize_new = calculate_optimal_size(wsize, hsize, 128)
    if wsize_new < wsize or hsize_new < hsize:
        image = image.resize((wsize_new, hsize_new), Image.Resampling.BICUBIC)

    pixel_array = list(image.getdata())
    colors = QuantizeCelebi(pixel_array, 128)
    argb = Score.score(colors)[0]

    hct = Hct.from_int(argb)
    scheme = SchemeTonalSpot(hct, dark_mode, 0.0)

    material_colors = {}
    for key in ALLOWED_KEYS:
        if hasattr(MaterialDynamicColors, key):
            color_def = getattr(MaterialDynamicColors, key)
            if hasattr(color_def, "get_hct"):
                rgba = color_def.get_hct(scheme).to_rgba()
                material_colors[key] = rgba_to_hex(rgba)

    return material_colors

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} /path/to/image")
        sys.exit(1)

    img_path = os.path.expanduser(sys.argv[1])
    if not os.path.isfile(img_path):
        print(f"Error: File not found: {img_path}")
        sys.exit(1)

    # Always dark mode
    colors = get_colors_from_img(img_path, dark_mode=True)

    # Map to terminal palette (your provided mapping)
    pywal_colors = {
        "special": {
            "background": colors.get("background", "#000000"),
            "foreground": colors.get("onBackground", "#ffffff"),
            "cursor": colors.get("primary", "#ffffff"),
        },
        "colors": {
            # Regular
            "color0": colors.get("surface", "#000000"),
            "color1": colors.get("error", "#ff0000"),
            "color2": colors.get("primary", "#00ff00"),
            "color3": colors.get("secondary", "#0000ff"),
            "color4": colors.get("tertiary", "#00ffff"),
            "color5": blend_hex(colors.get("primary", "#00ff00"), "#9c27b0"), # magenta from primary+material-purple
            "color6": blend_hex(colors.get("primary", "#00ff00"), "#00bcd4"), # cyan from primary+material-cyan
            "color7": colors.get("onSurfaceVariant", "#ffffff"),

            # Bright
            "color8": colors.get("surfaceVariant", "#222222"),
            "color9": colors.get("error", "#ff0000"),
            "color10": colors.get("primary", "#00ff00"),
            "color11": colors.get("secondary", "#0000ff"),
            "color12": colors.get("tertiary", "#00ffff"),
            "color13": blend_hex(colors.get("primary", "#00ff00"), "#9c27b0"), # magenta from primary+material purple
            "color14": blend_hex(colors.get("primary", "#00ff00"), "#00bcd4"), # cyan from primary+material-cyan
            "color15": colors.get("onSurface", "#ffffff"),
        }
    }

    # Save to Pywal cache
    output_path = os.path.expanduser("~/.config/wal/material-you-tool/generated-colors.json")
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    with open(output_path, "w") as f:
        json.dump(pywal_colors, f, indent=4)

    # Run wal to apply theme and postrun script
    postrun_script = os.path.expanduser("~/.config/wal/postrun.sh")
    subprocess.run([
        "wal", "-e", "--theme", "-f", output_path, "-o", postrun_script
    ])

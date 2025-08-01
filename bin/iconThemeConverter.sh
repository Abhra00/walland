#!/bin/bash
set -e

ROOT_DIR="${1:-.}"
OUTPUT_ROOT="$HOME/Downloads/tokyodark"
mkdir -p "$OUTPUT_ROOT"

TMPDIR="$(mktemp -d)"

find "$ROOT_DIR" -type f -name "*.svg" | while read -r svg_file; do
    echo "Processing: $svg_file"

    rel_path="${svg_file#$ROOT_DIR/}"
    base_name="$(basename "${rel_path%.svg}")"
    rel_dir="$(dirname "$rel_path")"
    output_dir="$OUTPUT_ROOT/$rel_dir"
    mkdir -p "$output_dir"
    output_svg="$output_dir/${base_name}.svg"

    # Temp file for converted PPM image
    temp_ppm="$TMPDIR/${base_name}.ppm"

    # Convert SVG → PNG → styled PNG → PPM → autotrace
    rsvg-convert -b none -f png "$svg_file" |
        gowall convert - - -t tokyo-dark |
        pngtopnm >"$temp_ppm"

    # Trace the temp PPM file
    autotrace "$temp_ppm" \
        -input-format ppm \
        -output-format svg \
        -output-file "$output_svg" \
        -color-count 16 \
        -background-color FFFFFF \
        -despeckle-level 2 \
        -centerline

    echo "→ Saved: $output_svg"
done

rm -rf "$TMPDIR"

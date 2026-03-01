#!/usr/bin/env python3
"""
Batch remove black backgrounds from all FuelLift generated pixel art PNGs.
Makes black pixels and white sparkle stars transparent.
Then copies processed images into Assets.xcassets imagesets.
"""

import os
import shutil
from pathlib import Path
from PIL import Image
import numpy as np

# Paths
SCRIPT_DIR = Path(__file__).parent
PROJECT_ROOT = SCRIPT_DIR.parent
GENERATED_DIR = PROJECT_ROOT / "Resources" / "generated"
ASSETS_DIR = PROJECT_ROOT / "FuelLift" / "Resources" / "Assets.xcassets"

# Thresholds
BLACK_THRESHOLD = 45      # max(R,G,B) below this → transparent (removes black bg)
WHITE_THRESHOLD = 200     # min(R,G,B) above this → transparent (removes white sparkles)
SPARKLE_SAT_MAX = 30      # max channel - min channel below this for sparkle detection


def remove_background(img_path: Path) -> Image.Image:
    """Remove black background and white sparkles from a pixel art PNG."""
    img = Image.open(img_path).convert("RGBA")
    data = np.array(img)

    r, g, b, a = data[:, :, 0], data[:, :, 1], data[:, :, 2], data[:, :, 3]

    max_rgb = np.maximum(np.maximum(r, g), b)
    min_rgb = np.minimum(np.minimum(r, g), b)
    saturation = max_rgb.astype(int) - min_rgb.astype(int)

    # Remove black/near-black pixels (the background)
    black_mask = max_rgb < BLACK_THRESHOLD

    # Remove white/gray sparkle pixels (low saturation + high brightness)
    sparkle_mask = (min_rgb > WHITE_THRESHOLD) & (saturation < SPARKLE_SAT_MAX)

    # Also remove slightly dimmer gray sparkles
    gray_sparkle_mask = (min_rgb > 150) & (saturation < 20) & (max_rgb > 170)

    # Combine masks
    remove_mask = black_mask | sparkle_mask | gray_sparkle_mask

    # Set alpha to 0 for removed pixels
    data[:, :, 3] = np.where(remove_mask, 0, a)

    return Image.fromarray(data)


def process_all_images():
    """Process all generated PNGs and update asset catalog copies."""
    # Find all PNGs in generated directory
    png_files = list(GENERATED_DIR.rglob("*.png"))
    print(f"Found {len(png_files)} PNGs to process")

    processed = 0
    errors = 0

    for png_path in sorted(png_files):
        rel_path = png_path.relative_to(GENERATED_DIR)
        try:
            # Process the image
            result = remove_background(png_path)

            # Save back to generated dir (overwrite original)
            result.save(png_path, "PNG")

            # Find and update corresponding asset catalog imageset
            stem = png_path.stem
            imageset_dir = ASSETS_DIR / f"{stem}.imageset"
            if imageset_dir.exists():
                asset_png = imageset_dir / f"{stem}.png"
                result.save(asset_png, "PNG")

            processed += 1
            if processed % 10 == 0:
                print(f"  Processed {processed}/{len(png_files)}...")

        except Exception as e:
            print(f"  ERROR processing {rel_path}: {e}")
            errors += 1

    print(f"\nDone! Processed: {processed}, Errors: {errors}")


if __name__ == "__main__":
    process_all_images()

"""
Crop all generated PNGs to their content bounds (trimming transparent pixels)
and copy the cropped versions into the corresponding Xcode asset catalog imagesets.

Skips AppIcon.appiconset entirely.
"""

import os
import shutil
from pathlib import Path

import numpy as np
from PIL import Image

# ── Paths ──────────────────────────────────────────────────────────────────────
GENERATED_DIR = Path(r"C:\Users\12147\Documents\FuelLift2\FuelLift\Resources\generated")
ASSETS_DIR = Path(r"C:\Users\12147\Documents\FuelLift2\FuelLift\FuelLift\Resources\Assets.xcassets")
PADDING = 4  # px on each side


def get_content_bbox(img: Image.Image):
    """Return the bounding box (left, upper, right, lower) of non-transparent content,
    or None if the image is fully transparent."""
    arr = np.array(img)

    if arr.ndim == 2:
        # Grayscale with no alpha – nothing to crop
        return None

    if arr.shape[2] == 4:
        alpha = arr[:, :, 3]
    elif arr.shape[2] == 3:
        # No alpha channel – nothing to crop
        return None
    else:
        return None

    # Rows / cols that contain at least one non-transparent pixel
    rows = np.any(alpha > 0, axis=1)
    cols = np.any(alpha > 0, axis=0)

    if not rows.any():
        return None

    top = int(np.argmax(rows))
    bottom = int(len(rows) - np.argmax(rows[::-1]))
    left = int(np.argmax(cols))
    right = int(len(cols) - np.argmax(cols[::-1]))

    return (left, top, right, bottom)


def crop_to_content(img: Image.Image, padding: int = PADDING) -> Image.Image | None:
    """Crop the image to its non-transparent bounding box + padding.
    Returns the cropped image or None if nothing to crop."""
    bbox = get_content_bbox(img)
    if bbox is None:
        return None

    left, top, right, bottom = bbox
    w, h = img.size

    # Add padding, clamped to image bounds
    left = max(0, left - padding)
    top = max(0, top - padding)
    right = min(w, right + padding)
    bottom = min(h, bottom + padding)

    cropped = img.crop((left, top, right, bottom))
    return cropped


def main():
    png_files = sorted(GENERATED_DIR.rglob("*.png"))
    print(f"Found {len(png_files)} PNG files in {GENERATED_DIR}\n")

    stats = []
    copied = 0
    skipped_no_content = []
    skipped_no_imageset = []

    for png_path in png_files:
        stem = png_path.stem  # e.g. "badge_beastMode"

        # Skip app_icon from being copied to AppIcon.appiconset (we skip that)
        # but still crop the generated file itself.

        original_size = png_path.stat().st_size

        img = Image.open(png_path).convert("RGBA")
        orig_dimensions = img.size

        cropped = crop_to_content(img)
        if cropped is None:
            skipped_no_content.append(str(png_path))
            continue

        new_dimensions = cropped.size

        # Save cropped back to generated dir (overwrite)
        cropped.save(png_path, "PNG")
        new_size = png_path.stat().st_size

        reduction_pct = (1 - new_size / original_size) * 100 if original_size > 0 else 0

        stats.append({
            "file": stem,
            "orig_dim": orig_dimensions,
            "new_dim": new_dimensions,
            "orig_bytes": original_size,
            "new_bytes": new_size,
            "reduction_pct": reduction_pct,
        })

        # Copy to asset catalog imageset (if it exists)
        imageset_dir = ASSETS_DIR / f"{stem}.imageset"
        if imageset_dir.is_dir():
            dest = imageset_dir / f"{stem}.png"
            shutil.copy2(png_path, dest)
            copied += 1
        else:
            skipped_no_imageset.append(stem)

    # ── Report ─────────────────────────────────────────────────────────────────
    print(f"{'File':<40} {'Original':>12} {'Cropped':>12} {'Orig KB':>9} {'New KB':>9} {'Saved':>7}")
    print("-" * 95)

    total_orig = 0
    total_new = 0
    for s in stats:
        orig_dim_str = f"{s['orig_dim'][0]}x{s['orig_dim'][1]}"
        new_dim_str = f"{s['new_dim'][0]}x{s['new_dim'][1]}"
        orig_kb = s["orig_bytes"] / 1024
        new_kb = s["new_bytes"] / 1024
        total_orig += s["orig_bytes"]
        total_new += s["new_bytes"]
        print(f"{s['file']:<40} {orig_dim_str:>12} {new_dim_str:>12} {orig_kb:>8.1f}K {new_kb:>8.1f}K {s['reduction_pct']:>6.1f}%")

    print("-" * 95)
    total_reduction = (1 - total_new / total_orig) * 100 if total_orig > 0 else 0
    print(f"{'TOTAL':<40} {'':>12} {'':>12} {total_orig/1024:>8.1f}K {total_new/1024:>8.1f}K {total_reduction:>6.1f}%")
    print(f"\nImages cropped: {len(stats)}")
    print(f"Copied to asset catalog: {copied}")

    if skipped_no_content:
        print(f"\nSkipped (fully transparent / no alpha): {len(skipped_no_content)}")
        for p in skipped_no_content:
            print(f"  - {p}")

    if skipped_no_imageset:
        print(f"\nNo matching imageset found for {len(skipped_no_imageset)} files:")
        for s in skipped_no_imageset:
            print(f"  - {s}")


if __name__ == "__main__":
    main()

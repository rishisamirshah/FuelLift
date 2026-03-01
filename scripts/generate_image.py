#!/usr/bin/env python3
"""
FuelLift Image Generator — Gemini AI (Nano Banana)
Generates pixel-art style assets for the FuelLift iOS app.

Usage:
    python generate_image.py "your prompt here"
    python generate_image.py "your prompt here" --output path/to/output.png
    python generate_image.py "your prompt here" --model pro
"""

import argparse
import os
import sys
from pathlib import Path

from google import genai
from google.genai import types

# API key: env var takes priority, fallback to hardcoded
API_KEY = os.environ.get("GEMINI_API_KEY", "")

# FuelLift style prefix — baked into every prompt for consistent aesthetic
# Matches reference: solid filled chunky pixel art, orange with darker orange shading,
# white sparkle stars, pure black background, dynamic action poses
STYLE_PREFIX = (
    "Chunky solid filled pixel art, retro 8-bit video game sprite style, "
    "orange and dark orange color palette with shading on pure black background, "
    "solid filled shapes not outlines, thick bold pixels, "
    "small white sparkle stars scattered in the background, "
    "dynamic energetic action pose, fitness themed, "
    "no text, no watermarks, no UI elements. "
)

# Nano Banana model family
MODELS = {
    "nano":  "gemini-2.5-flash-image",           # Nano Banana (fast)
    "pro":   "gemini-3-pro-image-preview",        # Nano Banana Pro (high quality)
    "nano2": "gemini-3.1-flash-image-preview",    # Nano Banana 2 (latest)
}


def generate_image(prompt: str, output_path: str = "output.png", model: str = "nano", raw: bool = False) -> str:
    """Generate an image using Nano Banana and save to disk."""
    client = genai.Client(api_key=API_KEY)
    model_id = MODELS[model]
    full_prompt = prompt if raw else STYLE_PREFIX + prompt

    print(f"Model:  {model_id} (Nano Banana {'Pro' if model == 'pro' else '2' if model == 'nano2' else ''})")
    print(f"Prompt: {full_prompt[:150]}...")
    print("Generating image...")

    response = client.models.generate_content(
        model=model_id,
        contents=full_prompt,
        config=types.GenerateContentConfig(
            response_modalities=["IMAGE"],
        ),
    )

    # Extract image bytes from response
    for part in response.candidates[0].content.parts:
        if part.inline_data is not None:
            image_bytes = part.inline_data.data
            out = Path(output_path)
            out.parent.mkdir(parents=True, exist_ok=True)
            out.write_bytes(image_bytes)
            print(f"Saved: {out.resolve()} ({len(image_bytes):,} bytes)")
            return str(out.resolve())

    print("ERROR: No image data in response. Prompt may have been blocked.")
    sys.exit(1)


def main():
    parser = argparse.ArgumentParser(description="FuelLift Gemini Image Generator (Nano Banana)")
    parser.add_argument("prompt", help="Image description (style prefix is auto-added)")
    parser.add_argument("-o", "--output", default="output.png", help="Output file path")
    parser.add_argument(
        "-m", "--model", choices=list(MODELS.keys()), default="nano",
        help="nano=fast, pro=high quality, nano2=latest (default: nano)"
    )
    parser.add_argument("--raw", action="store_true", help="Skip style prefix, use prompt as-is")
    args = parser.parse_args()
    generate_image(args.prompt, args.output, args.model, args.raw)


if __name__ == "__main__":
    main()

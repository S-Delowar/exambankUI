"""
Send each cropped figure to Gemini for description / OCR.

For every image under data/cropped_images/{paper}/page_<N>/image<M>.png,
this writes a sibling text file image<M>.txt containing Gemini's description.

Setup:
    1. Get a free API key at https://aistudio.google.com/apikey
    2. export GEMINI_API_KEY="your_key_here"
    3. Run:
         python -m backend.scripts.describe_with_gemini <paper_name>

Example:
    python -m backend.scripts.describe_with_gemini Physics_2023_Paper_1
"""

import os
import sys
import time
from pathlib import Path

from google import genai
from google.genai import types

# Default to backend/data/cropped_images
BACKEND_DIR = Path(__file__).parent.parent
CROPPED_ROOT = BACKEND_DIR / "data" / "cropped_images"
MODEL = "gemini-2.5-flash"

PROMPT = """You are looking at a figure cropped from a Bangladeshi university
admission test physics/chemistry/math question. Describe the figure in a way
that would let someone reconstruct it without seeing it.

Cover:
- What kind of figure it is (circuit, graph, geometric shape, free-body diagram, etc.)
- All labels, values, units, and symbols visible
- Spatial layout (what's connected to what, axes, directions, arrows)

Be concise and factual. Output plain text only."""


def describe_image(client: genai.Client, image_path: Path) -> str:
    image_bytes = image_path.read_bytes()
    response = client.models.generate_content(
        model=MODEL,
        contents=[
            types.Part.from_bytes(data=image_bytes, mime_type="image/png"),
            PROMPT,
        ],
    )
    return (response.text or "").strip()


def main() -> None:
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    paper_name = sys.argv[1]
    cropped_dir = CROPPED_ROOT / paper_name

    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        print("ERROR: set GEMINI_API_KEY environment variable", file=sys.stderr)
        sys.exit(1)

    if not cropped_dir.exists():
        print(f"ERROR: {cropped_dir} not found", file=sys.stderr)
        print(f"Available papers: {', '.join(p.name for p in CROPPED_ROOT.iterdir() if p.is_dir())}")
        sys.exit(1)

    client = genai.Client(api_key=api_key)
    images = sorted(cropped_dir.glob("page_*/image*.png"))
    if not images:
        print(f"No cropped images found in {cropped_dir}")
        return

    print(f"Processing {len(images)} image(s) from {paper_name} with {MODEL}\n")
    for img_path in images:
        out_path = img_path.with_suffix(".txt")
        rel = img_path.relative_to(ROOT)
        try:
            description = describe_image(client, img_path)
            out_path.write_text(description, encoding="utf-8")
            preview = description.replace("\n", " ")[:80]
            print(f"  {rel}  →  {preview}{'…' if len(description) > 80 else ''}")
        except Exception as e:  # noqa: BLE001 — surface every error to the user
            print(f"  {rel}  →  ERROR: {e}", file=sys.stderr)
        # Free tier: gemini-2.5-flash is rate-limited to ~10 req/min,
        # so wait a touch over 6s between calls.
        time.sleep(6.5)

    print(f"\nDone. Descriptions written next to each image under {CROPPED_DIR}")


if __name__ == "__main__":
    main()

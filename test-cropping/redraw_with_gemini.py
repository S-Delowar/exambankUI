"""
Redraw cropped figures as clean SVG via Gemini, then rasterize to PNG.

For every cropped/page_<N>/image<M>.png, this writes:
    cropped/page_<N>/image<M>.redrawn.svg   ← Gemini's vector reconstruction
    cropped/page_<N>/image<M>.redrawn.png   ← high-DPI raster of the SVG

Run:
    export GEMINI_API_KEY="your_key_here"
    backend/.venv/bin/python test-cropping/redraw_with_gemini.py

Workflow:
    1. Send each cropped image to gemini-2.5-flash with a strict
       SVG-output prompt.
    2. Extract the SVG block from the response (handles ```svg fences).
    3. Save SVG to disk for inspection / manual editing.
    4. Rasterize SVG → PNG with cairosvg at high resolution.

Notes:
    • Best for line drawings: circuits, graphs, geometry, free-body
      diagrams. Won't work well for photographs of apparatus.
    • Always inspect the .svg or .redrawn.png against the original
      before trusting numeric values — Gemini can misread a digit.
"""

import argparse
import os
import re
import sys
import time
from pathlib import Path

import cairosvg
from google import genai
from google.genai import types

ROOT = Path(__file__).parent
CROPPED_DIR = ROOT / "cropped"
BACKEND_ENV = ROOT.parent / "backend" / ".env"


def load_env_file(path: Path) -> None:
    """Minimal .env loader — sets vars not already in os.environ."""
    if not path.exists():
        return
    for raw in path.read_text().splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, _, value = line.partition("=")
        key, value = key.strip(), value.strip().strip('"').strip("'")
        if key and key not in os.environ:
            os.environ[key] = value
MODEL = "gemini-2.5-flash"
OUTPUT_PNG_WIDTH = 1200  # rendered width in pixels
RATE_LIMIT_SLEEP = 6.5  # seconds — keeps under free-tier 10 RPM

PROMPT = """You are a TRACING tool, not an illustrator. Your job is to produce
SVG that visually matches the input image as closely as possible — not to
"improve" or "redraw" it from understanding.

CORE RULE: If you are unsure about a value, label, or shape — copy what you
see, do not guess. Hallucinated values are far worse than ugly output.

WORKFLOW (think before writing SVG):
  Step 1 — List every distinct visible element with its rough pixel position
           (e.g. "battery symbol at left, '9V' label below it").
  Step 2 — List every text token visible. Read each one character by
           character. Do NOT abbreviate or normalize. If you see "20 Ω",
           write "20 Ω" — do not write "20Ω" or "20 ohm".
           If a character is illegible, write "?" — never invent.
  Step 3 — Now emit the SVG. Place each text token at the position where it
           visibly appears. Place each shape where it visibly appears.

OUTPUT FORMAT:
- Output ONLY the SVG markup, nothing else. No prose, no explanation, no
  markdown fences, no <think> tags.
- Start with <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 W H"> and
  end with </svg>. Match viewBox aspect ratio to the input image's aspect
  ratio.
- Black strokes (#000) on white. Stroke width 2. Use stroke-linecap="round".
- Use Unicode directly for Ω θ λ μ π α β γ δ etc. inside <text>. Use
  <tspan baseline-shift="sub" font-size="70%"> for subscripts (I₁, V₂, etc.).
- For schematic symbols, use the standard textbook convention:
    resistor = horizontal or vertical zigzag (6 peaks)
    battery  = long line || short line (long = +, short = −)
    capacitor = two short parallel lines with a gap
    arrow on wire = small filled triangle pointing along current direction
- Graphs: draw axes as arrows from the origin, label axes with the variable
  shown (don't substitute), draw the curve following the visible shape.

CIRCUIT-SPECIFIC RULES (read carefully — circuits are where hallucination
happens most):
- COUNT each component before drawing. State to yourself: "I see N
  resistors, M batteries, K capacitors". Your SVG must contain exactly
  that many.
- COUNT the loops/meshes in the visible circuit. A single-loop circuit must
  stay single-loop. A two-loop circuit must stay two-loop. Do not merge or
  split loops to make the schematic "tidier".
- Components in PARALLEL must remain parallel. Components in SERIES must
  remain in series. If two resistors are drawn side-by-side between the
  same two nodes, they ARE in parallel — keep them that way.
- Each component's LABEL stays attached to that component. If "20 Ω" sits
  next to the top resistor in the original, it must sit next to the top
  resistor in your SVG. Do not reshuffle labels.
- Wire ROUTING: keep wire paths approximately where they are. If a wire
  bends down then right, your SVG must bend down then right too. Do not
  re-route wires to look cleaner.
- ARROW DIRECTIONS on currents and EMFs are critical. Copy each arrow's
  direction exactly — flipping an arrow changes the physics.
- POLARITY of batteries (+/−, long/short line) must match the original.
- If a node has 3 wires meeting, draw a small filled dot. If wires cross
  without connecting, do NOT draw a dot (use a small jump arc or just
  cross them).
- If you are uncertain whether two visible elements are connected, prefer
  the simpler, more conservative reading and DO NOT add connections that
  aren't clearly there.

WHAT NOT TO DO:
- Do not invent values not visible in the image.
- Do not "tidy up" by adding labels, gridlines, or units that aren't there.
- Do not change a digit because the value "looks wrong" — copy what you see.
- Do not move elements to look more balanced — match positions.
- If the image is a photograph of real apparatus rather than a line drawing,
  output a single <svg> with just <text>PHOTOGRAPH — cannot trace</text>.

Output the SVG now."""


SVG_FENCE_RE = re.compile(r"```(?:svg|xml)?\s*(<svg.*?</svg>)\s*```", re.DOTALL | re.IGNORECASE)
SVG_RAW_RE = re.compile(r"(<svg.*?</svg>)", re.DOTALL | re.IGNORECASE)


def extract_svg(text: str) -> str | None:
    """Pull SVG markup out of Gemini's response, with or without code fences."""
    if not text:
        return None
    m = SVG_FENCE_RE.search(text)
    if m:
        return m.group(1)
    m = SVG_RAW_RE.search(text)
    if m:
        return m.group(1)
    return None


def redraw_image(client: genai.Client, image_path: Path) -> str | None:
    image_bytes = image_path.read_bytes()
    response = client.models.generate_content(
        model=MODEL,
        contents=[
            types.Part.from_bytes(data=image_bytes, mime_type="image/png"),
            PROMPT,
        ],
    )
    return extract_svg(response.text or "")


def rasterize(svg_text: str, png_path: Path, width: int) -> None:
    cairosvg.svg2png(
        bytestring=svg_text.encode("utf-8"),
        write_to=str(png_path),
        output_width=width,
    )


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--skip-existing",
        action="store_true",
        help="Skip images that already have a .redrawn.svg sibling.",
    )
    parser.add_argument(
        "--only",
        type=str,
        default=None,
        help="Glob filter relative to cropped/ (e.g. 'page_4/*.png').",
    )
    args = parser.parse_args()

    load_env_file(BACKEND_ENV)
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        print(
            f"ERROR: GEMINI_API_KEY not found in environment or {BACKEND_ENV}",
            file=sys.stderr,
        )
        sys.exit(1)

    if not CROPPED_DIR.exists():
        print(f"ERROR: {CROPPED_DIR} not found — run crop_figures.py first", file=sys.stderr)
        sys.exit(1)

    pattern = args.only if args.only else "page_*/image*.png"
    images = sorted(
        p for p in CROPPED_DIR.glob(pattern) if ".redrawn" not in p.name
    )
    if args.skip_existing:
        before = len(images)
        images = [
            p for p in images
            if not p.with_name(p.stem + ".redrawn.svg").exists()
        ]
        skipped = before - len(images)
        if skipped:
            print(f"Skipping {skipped} image(s) that already have a .redrawn.svg")

    if not images:
        print("Nothing to do.")
        return

    client = genai.Client(api_key=api_key)
    print(f"Redrawing {len(images)} image(s) with {MODEL}\n")

    ok = 0
    for img_path in images:
        rel = img_path.relative_to(ROOT)
        svg_path = img_path.with_name(img_path.stem + ".redrawn.svg")
        png_path = img_path.with_name(img_path.stem + ".redrawn.png")
        try:
            svg_text = redraw_image(client, img_path)
            if not svg_text:
                print(f"  {rel}  →  no SVG returned (skipped)", file=sys.stderr)
                continue
            svg_path.write_text(svg_text, encoding="utf-8")
            rasterize(svg_text, png_path, OUTPUT_PNG_WIDTH)
            print(f"  {rel}  →  {svg_path.name}, {png_path.name}")
            ok += 1
        except Exception as e:  # noqa: BLE001
            print(f"  {rel}  →  ERROR: {e}", file=sys.stderr)
        time.sleep(RATE_LIMIT_SLEEP)

    print(f"\nDone. {ok}/{len(images)} redrawn under {CROPPED_DIR}")


if __name__ == "__main__":
    main()

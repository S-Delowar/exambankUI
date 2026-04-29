"""Prototype: detect hand-drawn red rectangles in a PDF and crop them.

Usage:
    cd backend && python test/detect_red_boxes.py            # uses test/test_pdf_1.pdf
    cd backend && python test/detect_red_boxes.py <pdf_path>  # explicit PDF

The reviewer manually draws red rectangles in the source PDF around every
figure that should be extracted (and *only* those — solution figures left
unboxed are filtered out for free). This script renders each page, finds
every connected red region, crops it (with a small outward pad so the full
border lands inside the crop), whitens the red pixels and applies the same
levels stretch the production pipeline uses, then writes one PNG per box to
`backend/test/cropped/`.

Pure Pillow — no OpenCV / numpy. Reuses `render_pdf_to_images` from
`app.pdf_utils` and `_whiten_background` from `app.image_extractor` so the
output matches the existing extraction pipeline's visual treatment.

Tune the constants at the top of the file and re-run to iterate.
"""

from __future__ import annotations

import io
import sys
from collections import deque
from pathlib import Path

# Make `app.*` importable when this is run as a plain script from `backend/`.
_BACKEND_ROOT = Path(__file__).resolve().parent.parent
if str(_BACKEND_ROOT) not in sys.path:
    sys.path.insert(0, str(_BACKEND_ROOT))

from PIL import Image  # noqa: E402

from app.image_extractor import _whiten_background  # noqa: E402
from app.pdf_utils import render_pdf_to_images  # noqa: E402


# ---- Tunable constants ----------------------------------------------------

RENDER_DPI = 200            # match extraction pipeline default (app/config.py)
MAX_PAGES = 200             # safety cap, same spirit as extraction
# Looser red predicate so antialiased edge pixels stay connected. Diagnose
# output on a real marked PDF showed actual red ink ranging from
# (255,60,26) at the core down to ~(190,110,90) at the antialiased edge —
# the old strict R≥150,G≤100,B≤100 was dropping the edge, fragmenting each
# rectangle into hundreds of tiny disconnected pieces.
RED_R_MIN = 120             # pixel is "red" iff R ≥ RED_R_MIN ...
RED_GB_MAX = 140            # ... AND G ≤ RED_GB_MAX AND B ≤ RED_GB_MAX ...
RED_R_OVER_GB = 30          # ... AND R is at least this much greater than G and B.
# Filter on the **bounding-box area** of each connected component, not
# pixel count — a rectangle outline has small pixel-area but huge bbox-area.
MIN_BBOX_AREA_FRAC = 0.005  # drop bboxes < 0.5% of page area (noise)
MAX_BBOX_AREA_FRAC = 0.80   # drop bboxes > 80% of page area (false positives)
CROP_OUTER_PAD_PX = 4       # outward pad so border isn't on the crop boundary
WHITEN_PAD_PX = 2           # widen red→white replacement to catch antialias halo
OUT_DIR = _BACKEND_ROOT / "test" / "cropped"
DEFAULT_PDF = _BACKEND_ROOT / "test" / "test_pdf_1.pdf"


# ---- Red detection --------------------------------------------------------


def build_red_mask(img: Image.Image) -> Image.Image:
    """Return an L-mode mask: 255 where the pixel is red, 0 elsewhere.

    A pixel counts as red if R is high enough AND G/B are low enough AND R
    dominates G and B by RED_R_OVER_GB. The dominance check is what
    separates red ink from skin-tone / faint-print pixels that have similar
    R but also high G/B.
    """
    from PIL import ImageChops

    rgb = img.convert("RGB")
    r, g, b = rgb.split()
    r_hi = r.point(lambda v: 255 if v >= RED_R_MIN else 0, mode="L")
    g_lo = g.point(lambda v: 255 if v <= RED_GB_MAX else 0, mode="L")
    b_lo = b.point(lambda v: 255 if v <= RED_GB_MAX else 0, mode="L")
    # R - G ≥ RED_R_OVER_GB and R - B ≥ RED_R_OVER_GB.
    r_minus_g = ImageChops.subtract(r, g)
    r_minus_b = ImageChops.subtract(r, b)
    dom_g = r_minus_g.point(lambda v: 255 if v >= RED_R_OVER_GB else 0, mode="L")
    dom_b = r_minus_b.point(lambda v: 255 if v >= RED_R_OVER_GB else 0, mode="L")
    mask = ImageChops.multiply(r_hi, g_lo)
    mask = ImageChops.multiply(mask, b_lo)
    mask = ImageChops.multiply(mask, dom_g)
    mask = ImageChops.multiply(mask, dom_b)
    return mask


# ---- Connected-component bounding boxes -----------------------------------


def find_red_box_bounds(mask: Image.Image) -> list[tuple[int, int, int, int]]:
    """Walk the binary mask and return a bounding box per connected red region.

    Uses an iterative BFS over `mask.load()` — Pillow doesn't expose a
    contour-finder but the regions are sparse (a handful per page) so this
    is plenty fast at 200 DPI.

    Returns: list of (left, top, right, bottom) in pixel coords, exclusive
    right/bottom (matching `Image.crop` convention).
    """
    w, h = mask.size
    pixels = mask.load()
    visited = bytearray(w * h)
    page_area = w * h
    min_bbox_area = page_area * MIN_BBOX_AREA_FRAC
    max_bbox_area = page_area * MAX_BBOX_AREA_FRAC

    boxes: list[tuple[int, int, int, int]] = []

    for y0 in range(h):
        row_off = y0 * w
        for x0 in range(w):
            if visited[row_off + x0] or pixels[x0, y0] == 0:
                continue
            # BFS the connected component, tracking bounding box only —
            # we filter on bbox area, not pixel count, because a hollow
            # rectangle outline has small pixel-area but large bbox-area.
            min_x, min_y, max_x, max_y = x0, y0, x0, y0
            queue: deque[tuple[int, int]] = deque()
            queue.append((x0, y0))
            visited[row_off + x0] = 1
            while queue:
                x, y = queue.popleft()
                if x < min_x:
                    min_x = x
                if x > max_x:
                    max_x = x
                if y < min_y:
                    min_y = y
                if y > max_y:
                    max_y = y
                # 4-connectivity — sufficient for a drawn rectangle.
                for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
                    if 0 <= nx < w and 0 <= ny < h:
                        idx = ny * w + nx
                        if not visited[idx] and pixels[nx, ny]:
                            visited[idx] = 1
                            queue.append((nx, ny))
            bbox_area = (max_x - min_x + 1) * (max_y - min_y + 1)
            if min_bbox_area <= bbox_area <= max_bbox_area:
                boxes.append((min_x, min_y, max_x + 1, max_y + 1))

    # Reading order: top-to-bottom, then left-to-right.
    boxes.sort(key=lambda b: (b[1], b[0]))
    return boxes


# ---- Crop + whiten --------------------------------------------------------


def whiten_red(img: Image.Image) -> Image.Image:
    """Replace every red pixel in `img` with white. Run on the *cropped*
    image so the user's red rectangle disappears from the saved PNG."""
    rgb = img.convert("RGB")
    # Slightly looser thresholds than detection to also catch antialias halo.
    r_min = max(0, RED_R_MIN - 30)
    gb_max = min(255, RED_GB_MAX + 30)
    r, g, b = rgb.split()
    r_hi = r.point(lambda v: 255 if v >= r_min else 0, mode="L")
    g_lo = g.point(lambda v: 255 if v <= gb_max else 0, mode="L")
    b_lo = b.point(lambda v: 255 if v <= gb_max else 0, mode="L")
    from PIL import ImageChops

    red_mask = ImageChops.multiply(ImageChops.multiply(r_hi, g_lo), b_lo)
    white = Image.new("RGB", rgb.size, (255, 255, 255))
    return Image.composite(white, rgb, red_mask)


def crop_with_pad(
    page: Image.Image, box: tuple[int, int, int, int], pad: int
) -> Image.Image:
    left, top, right, bottom = box
    w, h = page.size
    return page.crop(
        (
            max(0, left - pad),
            max(0, top - pad),
            min(w, right + pad),
            min(h, bottom + pad),
        )
    )


# ---- Main pipeline --------------------------------------------------------


def diagnose_pdf(pdf_path: Path) -> None:
    """Sample every page and report the reddest pixels found, plus dump the
    current red-mask for page 1 to OUT_DIR/_diag_page01_mask.png. Lets you
    see why detection is finding nothing without guessing thresholds."""
    if not pdf_path.exists():
        raise SystemExit(f"PDF not found: {pdf_path}")
    pdf_bytes = pdf_path.read_bytes()
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    page_pngs = render_pdf_to_images(pdf_bytes, dpi=RENDER_DPI, max_pages=MAX_PAGES)
    print(f"Rendered {len(page_pngs)} pages at {RENDER_DPI} DPI\n")

    print(f"Current thresholds: R≥{RED_R_MIN}, G≤{RED_GB_MAX}, B≤{RED_GB_MAX}\n")

    for page_idx, page_png in enumerate(page_pngs, start=1):
        with Image.open(io.BytesIO(page_png)) as page:
            page.load()
            rgb = page.convert("RGB")
            # Count pixels matching the *current* strict mask.
            strict = build_red_mask(rgb)
            strict_count = sum(strict.getdata()) // 255

            # Find every "reddish" pixel — much looser definition: red
            # channel meaningfully higher than the other two and not near-white.
            # Sample on a 4× downscale so this is fast on big pages.
            small = rgb.resize((rgb.width // 4, rgb.height // 4))
            samples = []
            for r, g, b in small.getdata():
                if r >= 120 and r > g + 40 and r > b + 40 and (r + g + b) < 600:
                    samples.append((r, g, b))

            print(f"Page {page_idx:02d}:")
            print(f"  strict-mask pixels (current threshold): {strict_count}")
            print(f"  reddish-ish pixels (loose, downsampled): {len(samples)}")
            if samples:
                # Show 5 representative reddish colors so you can tune.
                step = max(1, len(samples) // 5)
                preview = samples[::step][:5]
                print(f"  sample reddish colors (R,G,B): {preview}")
                # Suggest thresholds that would catch this red.
                rs = [s[0] for s in samples]
                gs = [s[1] for s in samples]
                bs = [s[2] for s in samples]
                print(
                    f"  → would-match if RED_R_MIN={min(rs)}, "
                    f"RED_GB_MAX={max(max(gs), max(bs))}"
                )

            if page_idx == 1:
                diag_path = OUT_DIR / "_diag_page01_mask.png"
                strict.save(diag_path, format="PNG")
                print(f"  wrote current mask to {diag_path}")
            print()

    print(
        "If 'reddish-ish' is also 0, the PDF either has no red ink or it's\n"
        "being rendered as something other than RGB red (e.g. CMYK, or a\n"
        "vector annotation that PyMuPDF rasterised differently). Open the\n"
        "PDF in a viewer and zoom in on the rectangle to confirm it's\n"
        "actually red on the rasterised page."
    )


def process_pdf(pdf_path: Path) -> None:
    if not pdf_path.exists():
        raise SystemExit(f"PDF not found: {pdf_path}")
    pdf_bytes = pdf_path.read_bytes()
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    page_pngs = render_pdf_to_images(pdf_bytes, dpi=RENDER_DPI, max_pages=MAX_PAGES)
    print(f"Rendered {len(page_pngs)} pages at {RENDER_DPI} DPI")

    stem = pdf_path.stem
    total_saved = 0

    for page_idx, page_png in enumerate(page_pngs, start=1):
        with Image.open(io.BytesIO(page_png)) as page:
            page.load()
            mask = build_red_mask(page)
            boxes = find_red_box_bounds(mask)
            print(f"Page {page_idx:02d}: detected {len(boxes)} red box(es)")

            for idx, box in enumerate(boxes, start=1):
                crop = crop_with_pad(page, box, CROP_OUTER_PAD_PX)
                crop = whiten_red(crop)
                crop = _whiten_background(crop)
                out_path = OUT_DIR / f"{stem}_p{page_idx:02d}_{idx:02d}.png"
                crop.save(out_path, format="PNG")
                total_saved += 1

    print(f"\nSaved {total_saved} crop(s) to {OUT_DIR}")


def main() -> None:
    args = sys.argv[1:]
    diagnose = False
    if "--diagnose" in args:
        diagnose = True
        args = [a for a in args if a != "--diagnose"]

    if len(args) == 0:
        pdf_path = DEFAULT_PDF
    elif len(args) == 1:
        pdf_path = Path(args[0]).expanduser().resolve()
    else:
        print(
            "Usage: python test/detect_red_boxes.py [--diagnose] [<pdf_path>]\n"
            f"  (no path → defaults to {DEFAULT_PDF})\n"
            "  --diagnose: report what red looks like in the PDF instead of cropping",
            file=sys.stderr,
        )
        raise SystemExit(2)

    if diagnose:
        diagnose_pdf(pdf_path)
    else:
        process_pdf(pdf_path)


if __name__ == "__main__":
    main()

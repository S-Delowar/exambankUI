"""
Crop figures from a PDF that have been marked with colored rectangles.

Usage:
    python crop_figures.py

Detection strategy:
    1. First tries PDF annotation objects (most reliable — used by Preview,
       Adobe Acrobat "Rectangle" tool, etc.).
    2. Falls back to pixel-based color detection (for flattened annotations
       or rectangles drawn with a pen/markup tool).

Output:
    test-cropping/cropped/page_<N>/image<M>.png
"""

from pathlib import Path

import cv2
import fitz
import numpy as np

ROOT = Path(__file__).parent
PDF_PATH = ROOT / "test_for_crop.pdf"
OUT_DIR = ROOT / "cropped"
DPI = 600  # higher DPI = more pixels per figure, big quality win for cleanup
BORDER_INSET_PX = 8  # at 600 DPI the colored border is wider in pixels
MIN_BOX_AREA_PX = 8000  # ignore tiny stray marks (scaled for higher DPI)
DEDUP_IOU = 0.5  # merge boxes whose IoU exceeds this (handles duplicate annotations)
CLEAN_PADDING_PX = 16  # white padding added around the cleaned figure
TARGET_MIN_WIDTH = 1200  # upscale final crops to at least this width for crispness


def render_page(page: fitz.Page, dpi: int) -> np.ndarray:
    """Render a PDF page to a BGR numpy array."""
    matrix = fitz.Matrix(dpi / 72, dpi / 72)
    pix = page.get_pixmap(matrix=matrix, alpha=False)
    img = np.frombuffer(pix.samples, dtype=np.uint8).reshape(pix.height, pix.width, 3)
    return cv2.cvtColor(img, cv2.COLOR_RGB2BGR)


def boxes_from_annotations(page: fitz.Page, dpi: int) -> list[tuple[int, int, int, int]]:
    """Extract rectangle annotations and convert to pixel-space bboxes."""
    scale = dpi / 72
    boxes = []
    for annot in page.annots() or []:
        # Square = rectangle annotation in PDF spec
        if annot.type[0] not in (fitz.PDF_ANNOT_SQUARE, fitz.PDF_ANNOT_INK, fitz.PDF_ANNOT_POLYGON):
            continue
        r = annot.rect
        x0, y0 = int(r.x0 * scale), int(r.y0 * scale)
        x1, y1 = int(r.x1 * scale), int(r.y1 * scale)
        boxes.append((x0, y0, x1, y1))
    return boxes


def boxes_from_color(img_bgr: np.ndarray) -> list[tuple[int, int, int, int]]:
    """Detect bright red/green/magenta rectangles by color masking."""
    hsv = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2HSV)

    # Bright red (wraps around hue 0)
    red1 = cv2.inRange(hsv, (0, 120, 100), (10, 255, 255))
    red2 = cv2.inRange(hsv, (170, 120, 100), (180, 255, 255))
    # Bright green
    green = cv2.inRange(hsv, (40, 120, 100), (85, 255, 255))
    # Bright magenta/pink
    magenta = cv2.inRange(hsv, (140, 120, 100), (170, 255, 255))

    mask = red1 | red2 | green | magenta

    # Close gaps in the rectangle border so contour detection finds the full shape
    kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (5, 5))
    mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel, iterations=2)

    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    boxes = []
    for c in contours:
        x, y, w, h = cv2.boundingRect(c)
        if w * h < MIN_BOX_AREA_PX:
            continue
        boxes.append((x, y, x + w, y + h))
    return boxes


def deduplicate_boxes(boxes: list, iou_threshold: float) -> list:
    """Merge boxes whose IoU exceeds the threshold (keeps the union bbox)."""
    if not boxes:
        return []

    def iou(a, b):
        ax0, ay0, ax1, ay1 = a
        bx0, by0, bx1, by1 = b
        ix0, iy0 = max(ax0, bx0), max(ay0, by0)
        ix1, iy1 = min(ax1, bx1), min(ay1, by1)
        iw, ih = max(0, ix1 - ix0), max(0, iy1 - iy0)
        inter = iw * ih
        if inter == 0:
            return 0.0
        area_a = (ax1 - ax0) * (ay1 - ay0)
        area_b = (bx1 - bx0) * (by1 - by0)
        return inter / (area_a + area_b - inter)

    merged = []
    for box in boxes:
        for i, kept in enumerate(merged):
            if iou(box, kept) >= iou_threshold:
                merged[i] = (
                    min(box[0], kept[0]),
                    min(box[1], kept[1]),
                    max(box[2], kept[2]),
                    max(box[3], kept[3]),
                )
                break
        else:
            merged.append(box)
    return merged


def clean_figure(crop_bgr: np.ndarray) -> np.ndarray:
    """Strip the colored border and tight-crop to the figure content.

    No tonal cleanup — preserves the original scan colors/contrast for
    downstream consumers (e.g. Gemini OCR) which handle scan noise well.
    """
    h, w = crop_bgr.shape[:2]
    if h < 10 or w < 10:
        return crop_bgr

    hsv = cv2.cvtColor(crop_bgr, cv2.COLOR_BGR2HSV)
    color_mask = (
        cv2.inRange(hsv, (0, 70, 70), (14, 255, 255))
        | cv2.inRange(hsv, (166, 70, 70), (180, 255, 255))
        | cv2.inRange(hsv, (36, 70, 70), (90, 255, 255))
        | cv2.inRange(hsv, (136, 70, 70), (166, 255, 255))
    )
    if color_mask.any():
        dilated = cv2.dilate(color_mask, np.ones((7, 7), np.uint8), iterations=1)
        crop_bgr = cv2.inpaint(crop_bgr, dilated, 7, cv2.INPAINT_TELEA)
        non_color = cv2.bitwise_not(color_mask)
        ys, xs = np.where(non_color > 0)
        if ys.size and xs.size:
            y0, y1 = ys.min(), ys.max() + 1
            x0, x1 = xs.min(), xs.max() + 1
            crop_bgr = crop_bgr[y0:y1, x0:x1]

    pad = CLEAN_PADDING_PX
    return cv2.copyMakeBorder(
        crop_bgr, pad, pad, pad, pad, cv2.BORDER_CONSTANT, value=(255, 255, 255)
    )


def crop_and_save(img: np.ndarray, boxes: list, page_num: int) -> int:
    """Save each box as image<M>.png under cropped/page_<N>/. Returns count."""
    if not boxes:
        return 0

    # Sort top-to-bottom, then left-to-right for stable numbering
    boxes = sorted(boxes, key=lambda b: (b[1], b[0]))

    page_dir = OUT_DIR / f"page_{page_num}"
    page_dir.mkdir(parents=True, exist_ok=True)

    h, w = img.shape[:2]
    for i, (x0, y0, x1, y1) in enumerate(boxes, start=1):
        x0 = max(0, x0 + BORDER_INSET_PX)
        y0 = max(0, y0 + BORDER_INSET_PX)
        x1 = min(w, x1 - BORDER_INSET_PX)
        y1 = min(h, y1 - BORDER_INSET_PX)
        if x1 <= x0 or y1 <= y0:
            continue
        crop = img[y0:y1, x0:x1]
        cleaned = clean_figure(crop)
        cv2.imwrite(str(page_dir / f"image{i}.png"), cleaned)
    return len(boxes)


def main() -> None:
    if not PDF_PATH.exists():
        raise FileNotFoundError(f"PDF not found at {PDF_PATH}")

    doc = fitz.open(PDF_PATH)
    total = 0
    for idx, page in enumerate(doc, start=1):
        img = render_page(page, DPI)

        boxes = boxes_from_annotations(page, DPI)
        source = "annotations"
        if not boxes:
            boxes = boxes_from_color(img)
            source = "color-detection"

        boxes = deduplicate_boxes(boxes, DEDUP_IOU)
        count = crop_and_save(img, boxes, idx)
        total += count
        if count:
            print(f"page {idx}: {count} figure(s) saved [{source}]")
        else:
            print(f"page {idx}: no marked figures")

    print(f"\nDone. {total} figure(s) saved under {OUT_DIR}")


if __name__ == "__main__":
    main()

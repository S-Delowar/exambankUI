"""
Batch-crop figures from every PDF in test-cropping/pdf_files/.

For each <pdf>, for each page, for each red-rectangle annotation, save the
crop (including the red border) with the red recolored to white:

    cropped_images/<pdf_stem>/page_<N>/image<M>.png

Run:
    backend/.venv/bin/python test-cropping/crop_figures_batch.py
"""

from pathlib import Path

import cv2
import fitz
import numpy as np

ROOT = Path(__file__).parent
PDF_DIR = ROOT / "pdf_files"
OUT_ROOT = ROOT / "cropped_images"
DPI = 600
MIN_BOX_AREA_PX = 8000
DEDUP_IOU = 0.5
BORDER_INSET_PX = 10  # shrink crop inward just past the red stroke + anti-aliasing


def render_page(page: fitz.Page, dpi: int) -> np.ndarray:
    matrix = fitz.Matrix(dpi / 72, dpi / 72)
    pix = page.get_pixmap(matrix=matrix, alpha=False)
    img = np.frombuffer(pix.samples, dtype=np.uint8).reshape(pix.height, pix.width, 3)
    return cv2.cvtColor(img, cv2.COLOR_RGB2BGR)


def boxes_from_annotations(page: fitz.Page, dpi: int) -> list[tuple[int, int, int, int]]:
    scale = dpi / 72
    boxes = []
    for annot in page.annots() or []:
        if annot.type[0] not in (
            fitz.PDF_ANNOT_SQUARE,
            fitz.PDF_ANNOT_INK,
            fitz.PDF_ANNOT_POLYGON,
        ):
            continue
        r = annot.rect
        boxes.append(
            (int(r.x0 * scale), int(r.y0 * scale), int(r.x1 * scale), int(r.y1 * scale))
        )
    return boxes


def boxes_from_color(img_bgr: np.ndarray) -> list[tuple[int, int, int, int]]:
    hsv = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2HSV)
    red1 = cv2.inRange(hsv, (0, 120, 100), (10, 255, 255))
    red2 = cv2.inRange(hsv, (170, 120, 100), (180, 255, 255))
    green = cv2.inRange(hsv, (40, 120, 100), (85, 255, 255))
    magenta = cv2.inRange(hsv, (140, 120, 100), (170, 255, 255))
    mask = red1 | red2 | green | magenta
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
    if not boxes:
        return []

    def iou(a, b):
        ix0, iy0 = max(a[0], b[0]), max(a[1], b[1])
        ix1, iy1 = min(a[2], b[2]), min(a[3], b[3])
        iw, ih = max(0, ix1 - ix0), max(0, iy1 - iy0)
        inter = iw * ih
        if inter == 0:
            return 0.0
        area_a = (a[2] - a[0]) * (a[3] - a[1])
        area_b = (b[2] - b[0]) * (b[3] - b[1])
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


def recolor_marker_to_white(crop_bgr: np.ndarray) -> np.ndarray:
    """Replace red/green/magenta annotation pixels with white in-place."""
    hsv = cv2.cvtColor(crop_bgr, cv2.COLOR_BGR2HSV)
    mask = (
        cv2.inRange(hsv, (0, 70, 70), (14, 255, 255))
        | cv2.inRange(hsv, (166, 70, 70), (180, 255, 255))
        | cv2.inRange(hsv, (36, 70, 70), (90, 255, 255))
        | cv2.inRange(hsv, (136, 70, 70), (166, 255, 255))
    )
    if mask.any():
        # Slight dilation so anti-aliased edge pixels around the stroke also flip
        mask = cv2.dilate(mask, np.ones((3, 3), np.uint8), iterations=1)
        crop_bgr = crop_bgr.copy()
        crop_bgr[mask > 0] = (255, 255, 255)
    return crop_bgr


def sort_reading_order(boxes: list, page_w: int) -> list:
    """Order boxes the way a human reads a Bangladeshi 2-column exam page:
    left column top→bottom, then right column top→bottom; within a column,
    boxes that share a horizontal row are read left→right.

    Handles 2x2 option grids inside a single column (e.g. options A/B on
    one row and C/D on the next): row grouping uses a tolerance scaled to
    the median box height, not page height, so siblings with the same
    visual height land in the same row even when their y-centers drift by
    tens of pixels from scan skew.

    Steps:
      1. Column split by box center-X vs page midpoint. Single-column pages
         all land in column 0 → behaviour collapses to plain row-major.
      2. Within each column, group boxes into rows: two boxes are in the
         same row if their vertical spans overlap by at least half the
         smaller box's height. This correctly clusters side-by-side option
         boxes even with mild scan skew.
      3. Rows are sorted top→bottom; boxes within a row sorted left→right.
    """
    if not boxes:
        return []

    midpoint = page_w / 2

    def column_of(b):
        return 0 if (b[0] + b[2]) / 2 < midpoint else 1

    def y_center(b):
        return (b[1] + b[3]) / 2

    def height(b):
        return b[3] - b[1]

    def same_row(a, b):
        # Two boxes share a row if their vertical spans overlap by at least
        # half the height of the shorter box. This is robust to scan skew
        # and to a slight size difference between sibling option crops.
        overlap = min(a[3], b[3]) - max(a[1], b[1])
        if overlap <= 0:
            return False
        return overlap >= 0.5 * min(height(a), height(b))

    ordered: list = []
    for col in (0, 1):
        col_boxes = [b for b in boxes if column_of(b) == col]
        if not col_boxes:
            continue
        col_boxes.sort(key=y_center)
        rows: list[list] = []
        for b in col_boxes:
            placed = False
            for row in rows:
                if any(same_row(b, r) for r in row):
                    row.append(b)
                    placed = True
                    break
            if not placed:
                rows.append([b])
        rows.sort(key=lambda r: min(x[1] for x in r))
        for row in rows:
            row.sort(key=lambda b: b[0])
            ordered.extend(row)
    return ordered


def crop_and_save(img: np.ndarray, boxes: list, out_dir: Path) -> int:
    if not boxes:
        return 0
    boxes = sort_reading_order(boxes, page_w=img.shape[1])
    out_dir.mkdir(parents=True, exist_ok=True)
    h, w = img.shape[:2]
    saved = 0
    for i, (x0, y0, x1, y1) in enumerate(boxes, start=1):
        # Crop INSIDE the red rectangle: inset by the border stroke width
        x0 = max(0, x0 + BORDER_INSET_PX)
        y0 = max(0, y0 + BORDER_INSET_PX)
        x1 = min(w, x1 - BORDER_INSET_PX)
        y1 = min(h, y1 - BORDER_INSET_PX)
        if x1 <= x0 or y1 <= y0:
            continue
        crop = img[y0:y1, x0:x1]
        crop = recolor_marker_to_white(crop)
        cv2.imwrite(str(out_dir / f"image{i}.png"), crop)
        saved += 1
    return saved


def process_pdf(pdf_path: Path) -> tuple[int, int]:
    """Returns (pages_with_figures, total_figures).

    Only trusts real PDF rectangle annotations — no color-detection fallback,
    which produced false positives from red ink/text in the scans themselves.
    """
    pdf_out_dir = OUT_ROOT / pdf_path.stem
    doc = fitz.open(pdf_path)
    pages_hit, total = 0, 0
    for idx, page in enumerate(doc, start=1):
        boxes = boxes_from_annotations(page, DPI)
        boxes = deduplicate_boxes(boxes, DEDUP_IOU)
        if not boxes:
            continue
        img = render_page(page, DPI)
        page_dir = pdf_out_dir / f"page_{idx}"
        count = crop_and_save(img, boxes, page_dir)
        if count:
            pages_hit += 1
            total += count
    doc.close()
    return pages_hit, total


def main() -> None:
    if not PDF_DIR.exists():
        raise FileNotFoundError(f"{PDF_DIR} not found")

    pdfs = sorted(PDF_DIR.glob("*.pdf"))
    if not pdfs:
        print(f"No PDFs found in {PDF_DIR}")
        return

    OUT_ROOT.mkdir(exist_ok=True)
    grand_total = 0
    for pdf_path in pdfs:
        pages_hit, total = process_pdf(pdf_path)
        grand_total += total
        if total:
            print(f"{pdf_path.name}: {total} figure(s) across {pages_hit} page(s)")
        else:
            print(f"{pdf_path.name}: no marked figures")

    print(f"\nDone. {grand_total} figure(s) saved under {OUT_ROOT}")


if __name__ == "__main__":
    main()

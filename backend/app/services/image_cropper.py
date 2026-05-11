"""Image cropping service for extracting figures from PDFs.

Detects red rectangle annotations and crops figures to:
    <manual_crops_root>/<paper_name>/page_<N>/imageM.png

Based on test-cropping/crop_figures_batch.py but adapted for API use.
"""

import logging
from pathlib import Path
from typing import Optional

import cv2
import fitz
import numpy as np

logger = logging.getLogger(__name__)

DPI = 600
MIN_BOX_AREA_PX = 8000
DEDUP_IOU = 0.5
BORDER_INSET_PX = 10


def render_page(page: fitz.Page, dpi: int) -> np.ndarray:
    """Render PDF page to numpy array."""
    matrix = fitz.Matrix(dpi / 72, dpi / 72)
    pix = page.get_pixmap(matrix=matrix, alpha=False)
    img = np.frombuffer(pix.samples, dtype=np.uint8).reshape(pix.height, pix.width, 3)
    return cv2.cvtColor(img, cv2.COLOR_RGB2BGR)


def boxes_from_annotations(page: fitz.Page, dpi: int) -> list[tuple[int, int, int, int]]:
    """Extract bounding boxes from PDF rectangle annotations."""
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


def deduplicate_boxes(boxes: list, iou_threshold: float) -> list:
    """Merge overlapping boxes."""
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


def clean_crop(crop_bgr: np.ndarray) -> np.ndarray:
    """Denoise a cropped image using the same pipeline as pdf_cleaner.

    Steps: grayscale → bilateral filter → adaptive threshold → back to BGR.
    This runs after recolor_marker_to_white so annotation pixels are already
    gone and don't interfere with the binarisation.
    """
    gray = cv2.cvtColor(crop_bgr, cv2.COLOR_BGR2GRAY)
    denoised = cv2.bilateralFilter(gray, 9, 75, 75)
    clean = cv2.adaptiveThreshold(
        denoised, 255,
        cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
        cv2.THRESH_BINARY,
        21, 15,
    )
    return cv2.cvtColor(clean, cv2.COLOR_GRAY2BGR)


def recolor_marker_to_white(crop_bgr: np.ndarray) -> np.ndarray:
    """Replace red/green/magenta annotation pixels with white."""
    hsv = cv2.cvtColor(crop_bgr, cv2.COLOR_BGR2HSV)
    mask = (
        cv2.inRange(hsv, (0, 70, 70), (14, 255, 255))
        | cv2.inRange(hsv, (166, 70, 70), (180, 255, 255))
        | cv2.inRange(hsv, (36, 70, 70), (90, 255, 255))
        | cv2.inRange(hsv, (136, 70, 70), (166, 255, 255))
    )
    if mask.any():
        mask = cv2.dilate(mask, np.ones((3, 3), np.uint8), iterations=1)
        crop_bgr = crop_bgr.copy()
        crop_bgr[mask > 0] = (255, 255, 255)
    return crop_bgr


def sort_reading_order(boxes: list, page_w: int) -> list:
    """Order boxes in reading order: left column top→bottom, then right column."""
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
    """Crop boxes from image and save to out_dir."""
    if not boxes:
        return 0
    boxes = sort_reading_order(boxes, page_w=img.shape[1])
    out_dir.mkdir(parents=True, exist_ok=True)
    h, w = img.shape[:2]
    saved = 0
    for i, (x0, y0, x1, y1) in enumerate(boxes, start=1):
        x0 = max(0, x0 + BORDER_INSET_PX)
        y0 = max(0, y0 + BORDER_INSET_PX)
        x1 = min(w, x1 - BORDER_INSET_PX)
        y1 = min(h, y1 - BORDER_INSET_PX)
        if x1 <= x0 or y1 <= y0:
            continue
        crop = img[y0:y1, x0:x1]
        crop = recolor_marker_to_white(crop)
        crop = clean_crop(crop)
        cv2.imwrite(str(out_dir / f"image{i}.png"), crop)
        saved += 1
    return saved


def crop_pdf_images(
    pdf_bytes: bytes,
    paper_name: str,
    output_root: Path,
) -> dict:
    """
    Crop images from PDF based on rectangle annotations.
    
    Args:
        pdf_bytes: PDF file content
        paper_name: Name for the output folder (e.g., "Physics_2023_Dhaka_Board_Paper_1")
        output_root: Root directory for cropped images (e.g., manual_crops_path)
    
    Returns:
        {
            "paper_name": str,
            "crop_folder": Path,
            "pages_with_figures": int,
            "total_figures": int,
            "pages_processed": int
        }
    """
    try:
        doc = fitz.open(stream=pdf_bytes, filetype="pdf")
    except Exception as e:
        raise ValueError(f"Could not open PDF: {e}")
    
    crop_folder = output_root / paper_name
    pages_with_figures = 0
    total_figures = 0
    pages_processed = len(doc)
    
    for page_idx, page in enumerate(doc, start=1):
        boxes = boxes_from_annotations(page, DPI)
        boxes = deduplicate_boxes(boxes, DEDUP_IOU)

        if not boxes:
            continue

        img = render_page(page, DPI)
        page_dir = crop_folder / f"page_{page_idx}"
        count = crop_and_save(img, boxes, page_dir)
        
        if count:
            pages_with_figures += 1
            total_figures += count
            logger.info(
                f"Cropped {count} figure(s) from page {page_idx} of {paper_name}"
            )
    
    doc.close()
    
    return {
        "paper_name": paper_name,
        "crop_folder": str(crop_folder),
        "pages_with_figures": pages_with_figures,
        "total_figures": total_figures,
        "pages_processed": pages_processed,
    }

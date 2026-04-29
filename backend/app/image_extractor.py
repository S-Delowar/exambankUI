"""Crop diagram images out of the rendered page PNGs.

Two-pass pipeline contract:
  - Pass 1 (extractors/*.py) emits text + question_region(s) + image stubs.
  - Pass 2 (diagram_pass.py) fills `box_2d` (PAGE-PIXEL coords) on each
    QuestionImage with kind="diagram", and `markdown` on each kind="table".
  - This module (cropper) walks `images[]` and:
      * for kind="diagram" with a valid pixel box → crop, whiten, save PNG,
        set `filename` and (if not already) `extraction_status="ok"`.
      * for kind="table" → no-op (the markdown is already on the object).
      * for any other case → mark needs_review / failed if not already.

Best-effort: per-image failures are logged + flagged on the image, never
raised. The job still completes.
"""

from __future__ import annotations

import io
import logging
import re
from pathlib import Path
from typing import Any

from PIL import Image

logger = logging.getLogger(__name__)

_SAFE_FILENAME_RE = re.compile(r"[^A-Za-z0-9._-]+")
_PAD_FRAC = 0.03  # extra pad on the already-padded pass-2 box, just for safety
# Levels stretch for newsprint scans: pixels ≤ BLACK_POINT → 0 (darken ink),
# pixels ≥ WHITE_POINT → 255 (whiten paper), linear between.
_BLACK_POINT = 60
_WHITE_POINT = 200


def _safe_qnum(question_number: str) -> str:
    """'১২' / '12(a)' / etc. → a filename-safe slug. Empty string stays 'q'."""
    slug = _SAFE_FILENAME_RE.sub("_", question_number).strip("._-")
    return slug or "q"


def _pad_pixel_box(
    box_px: list[int],
    img_width: int,
    img_height: int,
    pad_frac: float = _PAD_FRAC,
) -> tuple[int, int, int, int]:
    """[left, top, right, bottom] in page pixels → padded + clipped to image."""
    left, top, right, bottom = box_px
    pad_w = (right - left) * pad_frac
    pad_h = (bottom - top) * pad_frac
    left = max(0, int(left - pad_w))
    top = max(0, int(top - pad_h))
    right = min(img_width, int(right + pad_w))
    bottom = min(img_height, int(bottom + pad_h))
    return left, top, right, bottom


def _whiten_background(
    img: Image.Image,
    black_point: int = _BLACK_POINT,
    white_point: int = _WHITE_POINT,
) -> Image.Image:
    """Levels stretch: ≤black_point → 0, ≥white_point → 255, linear between.
    Preserves alpha if present."""
    if black_point <= 0 and white_point >= 255:
        return img
    alpha = img.getchannel("A") if img.mode == "RGBA" else None
    rgb = img.convert("RGB")
    span = max(1, white_point - black_point)
    lut = [
        0 if i <= black_point
        else 255 if i >= white_point
        else int(round((i - black_point) * 255 / span))
        for i in range(256)
    ]
    stretched = rgb.point(lut * 3)
    if alpha is not None:
        stretched.putalpha(alpha)
    return stretched


def _crop_one(
    *,
    page_png: bytes,
    box_px: list[int],
    out_path: Path,
) -> tuple[bool, str | None]:
    """Returns (ok, error_reason)."""
    try:
        with Image.open(io.BytesIO(page_png)) as pil:
            pil.load()
            left, top, right, bottom = _pad_pixel_box(box_px, pil.width, pil.height)
            if right <= left or bottom <= top:
                logger.warning(
                    "Skipping degenerate pixel bbox %s for %s", box_px, out_path.name
                )
                return False, f"degenerate pixel bbox {box_px}"
            crop = pil.crop((left, top, right, bottom))
            crop = _whiten_background(crop)
            crop.save(out_path, format="PNG")
        return True, None
    except Exception as e:
        logger.exception("Failed to crop image %s", out_path)
        return False, f"PIL crop failed: {e}"


def crop_question_images(
    *,
    page_pngs: list[bytes],
    questions: list[Any],
    paper_stem: str,
    images_root: Path,
) -> None:
    """Walk questions[*].images[*], crop diagrams from the matching page PNG,
    write the file, and set `.filename` + `.extraction_status` on each
    QuestionImage. Tables are left alone (their markdown is already set by
    pass 2).

    Mutates the passed-in questions in place.

    Filename format: `p{page+1:02d}_q{question_number}_{idx:02d}.png`. When
    `question_number` collides within the same page (multi-subject papers),
    a trailing counter keeps files unique.
    """
    if not questions:
        return

    out_dir = images_root / paper_stem
    try:
        out_dir.mkdir(parents=True, exist_ok=True)
    except Exception:
        logger.exception("Failed to create images dir %s", out_dir)
        return

    total_pages = len(page_pngs)
    used_names: set[str] = set()

    for q in questions:
        images = getattr(q, "images", None) or []
        if not images:
            continue
        qnum = _safe_qnum(getattr(q, "question_number", "") or "")

        for idx, image in enumerate(images, start=1):
            kind = getattr(image, "kind", "diagram")

            if kind == "table":
                # Tables are transcribed by pass 2 — nothing to crop. If pass 2
                # produced markdown the status is already set; if not it's
                # already marked needs_review. Just verify.
                if getattr(image, "markdown", None):
                    if getattr(image, "extraction_status", "pending") == "pending":
                        image.extraction_status = "ok"
                else:
                    if getattr(image, "extraction_status", "pending") in ("pending", "ok"):
                        image.extraction_status = "needs_review"
                        image.review_notes = (
                            getattr(image, "review_notes", None)
                            or "table has no markdown after pass 2"
                        )
                continue

            # kind == "diagram"
            page_index = getattr(image, "page_index", None)
            if page_index is None or not (0 <= int(page_index) < total_pages):
                logger.warning(
                    "diagram missing/invalid page_index %s (total=%d) for q=%s",
                    page_index,
                    total_pages,
                    qnum,
                )
                if image.extraction_status not in ("failed", "needs_review"):
                    image.extraction_status = "needs_review"
                    image.review_notes = (
                        image.review_notes or f"missing/out-of-range page_index={page_index}"
                    )
                continue
            page_index = int(page_index)

            box = getattr(image, "box_2d", None)
            if not box or len(box) != 4:
                logger.warning("diagram missing/invalid box_2d for q=%s idx=%d", qnum, idx)
                if image.extraction_status not in ("failed", "needs_review"):
                    image.extraction_status = "needs_review"
                    image.review_notes = (
                        image.review_notes or "no box_2d after pass 2"
                    )
                continue

            base_name = f"p{page_index + 1:02d}_q{qnum}_{idx:02d}.png"
            filename = base_name
            bump = 0
            while filename in used_names or (out_dir / filename).exists():
                bump += 1
                filename = f"p{page_index + 1:02d}_q{qnum}_{idx:02d}_{bump}.png"
            used_names.add(filename)

            out_path = out_dir / filename
            ok, err = _crop_one(
                page_png=page_pngs[page_index],
                box_px=list(box),
                out_path=out_path,
            )
            if ok:
                image.filename = filename
                # Only promote pending→ok; preserve a pass-2 needs_review/low-confidence flag.
                if image.extraction_status == "pending":
                    image.extraction_status = "ok"
            else:
                image.extraction_status = "failed"
                image.review_notes = err

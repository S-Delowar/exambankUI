"""Pass 2 of the two-pass extraction pipeline.

Pass 1 (in `extractors/*.py`) gives us, per question:
  - text + tokens [IMAGE_1], [IMAGE_2], ...
  - `images[]` stubs (id + kind + caption_hint, no spatial data)
  - `question_region` / `question_regions` (bounding box of the WHOLE question
    on each page it appears on)

Pass 2 (this module) does, for each question that has at least one image:
  1. Crop the question_region(s) out of the page PNG(s).
  2. If the question spans multiple pages, vertically concatenate crops.
  3. Send the crop + the list of token stubs to Gemini with a focused
     diagram-localisation prompt.
  4. Re-project Gemini's crop-local boxes back into PAGE-PIXEL coords.
  5. Fill `box_2d` (diagrams) or `markdown` (tables) on each QuestionImage.
  6. Set `extraction_status` and `review_notes` based on the result.

Failure handling:
  - Gemini call fails → mark every image on the question as `failed` with the
    error reason. Job continues.
  - Gemini returns fewer items than tokens → match what we can, mark missing
    ones `needs_review`.
  - Gemini returns box outside the crop / degenerate → mark `needs_review`,
    leave box null (the cropper will then see no box and skip — frontend
    falls back to placeholder).
  - Confidence < threshold → mark `needs_review` but keep the box.

The whole pass is best-effort. A failure here does NOT fail the job.
"""

from __future__ import annotations

import asyncio
import io
import logging
from typing import Any, Iterable, Literal, Optional

from PIL import Image
from pydantic import BaseModel, Field

from .config import Settings
from .gemini_client import GeminiExtractor
from .schemas import QuestionImage

logger = logging.getLogger(__name__)


# ---- Pass-2 response schema ----
# Imported here as a sibling of QuestionImage so the diagram-pass call has its
# own dedicated structured-output shape (separate from the page-extraction one).


class DiagramPassItem(BaseModel):
    id: str = Field(..., description="Token id, e.g. 'IMAGE_1'.")
    kind: Literal["diagram", "table"]
    box_2d: Optional[list[int]] = Field(
        None,
        description="[ymin, xmin, ymax, xmax] in 0-1000 normalised CROP coords. Null for tables.",
        min_length=4,
        max_length=4,
    )
    markdown: Optional[str] = Field(
        None,
        description="GFM table transcription. Null for diagrams.",
    )
    confidence: float = Field(
        0.0, ge=0.0, le=1.0, description="Model self-rated confidence."
    )
    notes: Optional[str] = Field(
        None, description="Short human-readable note when something was off."
    )


class DiagramPassResult(BaseModel):
    items: list[DiagramPassItem] = Field(default_factory=list)


# ---- Tunables ----

_QUESTION_REGION_PAD_FRAC = 0.03   # pad each question_region by 3% on every side
_DIAGRAM_PAD_FRAC = 0.04           # pad diagram bbox by 4% before cropping (image_extractor will pad too)
_MIN_CONFIDENCE = 0.7              # below this → needs_review
_BLACK_POINT = 60                  # whitening levels stretch (matches image_extractor)
_WHITE_POINT = 200


# ---- Pass-2 prompt builder ----

def _build_pass2_user_prompt(stubs: list[QuestionImage]) -> str:
    """Render the per-question pass-2 prompt with the token list inlined."""
    from .prompts.shared import IMAGE_PASS2_PROMPT

    tokens = []
    for s in stubs:
        tokens.append(
            {
                "id": s.id,
                "kind": s.kind,
                "caption_hint": s.caption_hint,
            }
        )
    # Render as JSON-ish list for the model.
    import json
    tokens_json = json.dumps(tokens, ensure_ascii=False, indent=2)
    return f"{IMAGE_PASS2_PROMPT}\n\nTOKENS TO LOCATE:\n{tokens_json}\n"


# ---- Geometry helpers ----

def _norm_to_pixels(
    box_norm: list[int],
    img_width: int,
    img_height: int,
    pad_frac: float = 0.0,
) -> tuple[int, int, int, int]:
    """[ymin,xmin,ymax,xmax] in 0-1000 → (left,top,right,bottom) px, optional padding."""
    ymin, xmin, ymax, xmax = box_norm
    left = (xmin / 1000.0) * img_width
    right = (xmax / 1000.0) * img_width
    top = (ymin / 1000.0) * img_height
    bottom = (ymax / 1000.0) * img_height
    if pad_frac > 0:
        pad_w = (right - left) * pad_frac
        pad_h = (bottom - top) * pad_frac
        left -= pad_w
        right += pad_w
        top -= pad_h
        bottom += pad_h
    left = max(0, int(left))
    top = max(0, int(top))
    right = min(img_width, int(right))
    bottom = min(img_height, int(bottom))
    return left, top, right, bottom


def _is_degenerate(left: int, top: int, right: int, bottom: int) -> bool:
    return right <= left or bottom <= top or (right - left) < 4 or (bottom - top) < 4


def _crop_question(
    page_pngs: list[bytes],
    regions: list[dict[str, Any]],
) -> tuple[Optional[bytes], list[dict[str, Any]]]:
    """Crop one or more question_regions from page PNGs and stack vertically.

    Returns (combined_crop_bytes, region_meta) where region_meta is a list of
    {page_index, left, top, right, bottom, crop_y_offset, crop_height} so the
    re-projection step can map crop-local Y back to page-local pixels.

    Returns (None, []) if no region produces a valid crop.
    """
    crops: list[Image.Image] = []
    meta: list[dict[str, Any]] = []
    cursor_y = 0
    for region in regions:
        page_idx = region["page_index"]
        if not (0 <= page_idx < len(page_pngs)):
            logger.warning("question_region page_index %s out of range", page_idx)
            continue
        try:
            with Image.open(io.BytesIO(page_pngs[page_idx])) as page:
                page.load()
                w, h = page.size
                left, top, right, bottom = _norm_to_pixels(
                    region["box_2d"], w, h, pad_frac=_QUESTION_REGION_PAD_FRAC
                )
                if _is_degenerate(left, top, right, bottom):
                    logger.warning(
                        "question_region degenerate after pad: %s", region["box_2d"]
                    )
                    continue
                crop = page.crop((left, top, right, bottom)).convert("RGB")
        except Exception:
            logger.exception("Failed to crop question_region on page %d", page_idx)
            continue

        crops.append(crop)
        meta.append(
            {
                "page_index": page_idx,
                "left": left,
                "top": top,
                "right": right,
                "bottom": bottom,
                "crop_y_offset": cursor_y,
                "crop_height": crop.height,
                "crop_width": crop.width,
            }
        )
        cursor_y += crop.height

    if not crops:
        return None, []

    if len(crops) == 1:
        combined = crops[0]
    else:
        # Vertical concat: width = max width, height = sum.
        total_w = max(c.width for c in crops)
        total_h = sum(c.height for c in crops)
        combined = Image.new("RGB", (total_w, total_h), color=(255, 255, 255))
        y = 0
        for c in crops:
            combined.paste(c, (0, y))
            # Update meta for this crop's actual width if narrower than total_w
            # (we still report crop_width so reprojection can clip cleanly).
            y += c.height

    buf = io.BytesIO()
    combined.save(buf, format="PNG")
    return buf.getvalue(), meta


def _reproject_box_to_page(
    box_norm: list[int],
    crop_w: int,
    crop_h: int,
    region_meta: list[dict[str, Any]],
) -> Optional[tuple[int, list[int]]]:
    """Map a 0-1000 box in CROP coords back to PAGE-PIXEL coords.

    Returns (page_index, [left, top, right, bottom] in page pixels) or None if
    the box doesn't fall inside any source region.
    """
    if not region_meta:
        return None

    # Box in crop pixels.
    ymin_n, xmin_n, ymax_n, xmax_n = box_norm
    crop_left = int((xmin_n / 1000.0) * crop_w)
    crop_right = int((xmax_n / 1000.0) * crop_w)
    crop_top = int((ymin_n / 1000.0) * crop_h)
    crop_bottom = int((ymax_n / 1000.0) * crop_h)
    crop_top = max(0, crop_top)
    crop_bottom = min(crop_h, crop_bottom)

    if _is_degenerate(crop_left, crop_top, crop_right, crop_bottom):
        return None

    # Find which region this crop_y range belongs to. We attribute to the
    # region containing the box's vertical CENTER.
    cy = (crop_top + crop_bottom) // 2
    chosen = None
    for meta in region_meta:
        y0 = meta["crop_y_offset"]
        y1 = y0 + meta["crop_height"]
        if y0 <= cy < y1:
            chosen = meta
            break
    if chosen is None:
        # Box straddles the seam between two regions — fall back to first region.
        chosen = region_meta[0]

    region_w = chosen["crop_width"]
    region_h = chosen["crop_height"]

    # Clip crop coords to the chosen region's vertical band.
    rel_top = max(0, crop_top - chosen["crop_y_offset"])
    rel_bottom = min(region_h, crop_bottom - chosen["crop_y_offset"])
    rel_left = max(0, min(region_w, crop_left))
    rel_right = max(0, min(region_w, crop_right))

    if _is_degenerate(rel_left, rel_top, rel_right, rel_bottom):
        return None

    # Map to page pixels.
    page_left = chosen["left"] + rel_left
    page_top = chosen["top"] + rel_top
    page_right = chosen["left"] + rel_right
    page_bottom = chosen["top"] + rel_bottom

    return chosen["page_index"], [page_left, page_top, page_right, page_bottom]


# ---- Per-question orchestration ----

def _get_regions(question: Any) -> list[dict[str, Any]]:
    """Extract question_region(s) from a question, handling both the single-
    region (MCQ + admission written) and multi-region (HSC written) shapes."""
    regions: list[dict[str, Any]] = []
    single = getattr(question, "question_region", None)
    if single is not None:
        regions.append({"page_index": single.page_index, "box_2d": list(single.box_2d)})
    multi = getattr(question, "question_regions", None) or []
    for r in multi:
        regions.append({"page_index": r.page_index, "box_2d": list(r.box_2d)})
    return regions


def _mark_all_failed(images: list[QuestionImage], reason: str) -> None:
    for img in images:
        img.extraction_status = "failed"
        img.review_notes = reason


async def _process_one_question(
    *,
    question: Any,
    qno: str,
    page_pngs: list[bytes],
    extractor: GeminiExtractor,
) -> None:
    images: list[QuestionImage] = list(getattr(question, "images", None) or [])
    if not images:
        return

    regions = _get_regions(question)
    if not regions:
        _mark_all_failed(
            images,
            "pass-1 emitted [IMAGE_N] tokens but no question_region — cannot crop",
        )
        return

    crop_bytes, region_meta = _crop_question(page_pngs, regions)
    if crop_bytes is None:
        _mark_all_failed(images, "all question_region crops failed (out-of-range or degenerate)")
        return

    user_prompt = _build_pass2_user_prompt(images)
    try:
        result: DiagramPassResult = await extractor.extract_from_crop(
            crop_png=crop_bytes,
            user_prompt=user_prompt,
            response_schema=DiagramPassResult,
            label=f"q={qno} pass2 ({len(images)} tokens)",
        )
    except Exception as e:
        logger.exception("Pass-2 Gemini call failed for q=%s", qno)
        _mark_all_failed(images, f"pass-2 Gemini call failed: {e}")
        return

    # Build crop dimensions for reprojection (use the actual combined crop).
    try:
        with Image.open(io.BytesIO(crop_bytes)) as combined:
            crop_w, crop_h = combined.size
    except Exception:
        crop_w = sum(m["crop_width"] for m in region_meta) // max(1, len(region_meta))
        crop_h = sum(m["crop_height"] for m in region_meta)

    items_by_id = {it.id: it for it in result.items}
    for img in images:
        item = items_by_id.get(img.id)
        if item is None:
            img.extraction_status = "needs_review"
            img.review_notes = "pass-2 returned no item for this token"
            continue

        if item.kind != img.kind:
            # Defer to pass-2's classification (it just looked at the crop).
            img.kind = item.kind

        if item.kind == "table":
            if not item.markdown:
                img.extraction_status = "needs_review"
                img.review_notes = item.notes or "pass-2 returned no markdown for table"
                continue
            img.markdown = item.markdown
            img.extraction_status = (
                "ok" if item.confidence >= _MIN_CONFIDENCE else "needs_review"
            )
            if item.confidence < _MIN_CONFIDENCE:
                img.review_notes = (
                    f"low confidence {item.confidence:.2f}: {item.notes or '(no note)'}"
                )
            continue

        # kind == "diagram"
        if not item.box_2d or len(item.box_2d) != 4:
            img.extraction_status = "needs_review"
            img.review_notes = item.notes or "pass-2 returned no box for diagram"
            continue

        reproj = _reproject_box_to_page(
            item.box_2d, crop_w, crop_h, region_meta
        )
        if reproj is None:
            img.extraction_status = "needs_review"
            img.review_notes = "pass-2 box reprojected to a degenerate page region"
            continue

        page_idx, page_box_px = reproj
        img.page_index = page_idx
        img.box_2d = page_box_px  # PAGE-PIXEL coords (not 0-1000)
        img.extraction_status = (
            "ok" if item.confidence >= _MIN_CONFIDENCE else "needs_review"
        )
        if item.confidence < _MIN_CONFIDENCE:
            img.review_notes = (
                f"low confidence {item.confidence:.2f}: {item.notes or '(no note)'}"
            )


def _qno(q: Any) -> str:
    return str(getattr(q, "question_number", "") or "?")


async def run_diagram_pass(
    *,
    questions: Iterable[Any],
    page_pngs: list[bytes],
    settings: Settings,
) -> None:
    """Mutate every question with non-empty `images` to fill spatial data.

    Runs questions sequentially with the same `request_pause_seconds` as pass 1
    to keep us under Gemini's per-minute quota. Best-effort: any failure leaves
    extraction_status set so downstream code/UI can surface it."""
    extractor = GeminiExtractor(settings)
    qs_with_images = [q for q in questions if getattr(q, "images", None)]
    total = len(qs_with_images)
    if total == 0:
        return

    for i, q in enumerate(qs_with_images):
        await _process_one_question(
            question=q,
            qno=_qno(q),
            page_pngs=page_pngs,
            extractor=extractor,
        )
        if i < total - 1:
            await asyncio.sleep(settings.request_pause_seconds)

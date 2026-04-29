"""Link Pass-1 image stubs to pre-cropped PNGs from the manual-cropping pipeline.

The manual cropper (`test-cropping/crop_figures_batch.py`) produces, per PDF:

    <manual_crops_root>/<crop_folder>/page_<N>/imageM.png

`page_<N>` is 1-indexed; `imageM.png` is numbered in natural reading order
(left column top-to-bottom, then right column top-to-bottom; within a row,
left-to-right; 2x2 option grids → A, B, C, D).

Pass 1 emits one `QuestionImage` stub per `[IMAGE_K]` token in the page's
questions, in the same reading order (the prompt's "PAGE-WIDE READING ORDER"
contract). This module pairs the Nth stub on a page with the Nth file on
that page, copies the file into the canonical served-images folder under a
deterministic name, and stamps `image.filename` (and `option.image_filename`
when the token sits inside option text).

Best-effort: per-page mismatches flag every image on that page as
`needs_review`; missing crop folder is a no-op (caller decides whether to
fall back to Pass 2).
"""

from __future__ import annotations

import logging
import re
import shutil
from pathlib import Path
from typing import Any

logger = logging.getLogger(__name__)

# Match `image1.png`, `image12.png`, ... — the cropper's naming convention.
_CROP_FILENAME_RE = re.compile(r"^image(\d+)\.png$", re.IGNORECASE)
# Match `[IMAGE_3]` etc. inside option/question text.
_TOKEN_RE = re.compile(r"\[IMAGE_(\d+)\]")
# Bare-token option text (only an [IMAGE_N], possibly with whitespace) →
# the option IS the figure, so we set option.image_filename.
_BARE_TOKEN_RE = re.compile(r"^\s*\[IMAGE_\d+\]\s*$")


def _safe_qnum(question_number: str) -> str:
    """Mirror image_extractor._safe_qnum so the canonical filename matches the
    Pass-2 cropper's convention exactly. Frontend doesn't care which path
    produced the file."""
    slug = re.sub(r"[^A-Za-z0-9._-]+", "_", question_number).strip("._-")
    return slug or "q"


def _list_crops_for_page(page_dir: Path) -> list[Path]:
    """Sorted list of `imageN.png` files in `page_dir`, by numeric suffix."""
    if not page_dir.is_dir():
        return []
    pairs: list[tuple[int, Path]] = []
    for p in page_dir.iterdir():
        m = _CROP_FILENAME_RE.match(p.name)
        if m:
            pairs.append((int(m.group(1)), p))
    pairs.sort(key=lambda pp: pp[0])
    return [p for _, p in pairs]


def _stubs_in_reading_order(questions: list[Any]) -> list[tuple[int, Any, Any]]:
    """Return [(page_index, question, image_stub), ...] in the same order Pass 1
    walked the page (which the prompt pins to reading order).

    `images` on each question is the contract-specified order. Across questions
    we trust `questions[]` order — Pass 1 emits questions in reading order too.
    """
    out: list[tuple[int, Any, Any]] = []
    for q in questions:
        for img in getattr(q, "images", None) or []:
            page_index = getattr(img, "page_index", None)
            if page_index is None:
                logger.warning(
                    "image stub %s on q=%s has no page_index — Pass-1 stamp missing?",
                    getattr(img, "id", "?"),
                    getattr(q, "question_number", "?"),
                )
                continue
            out.append((int(page_index), q, img))
    return out


def _mark_page_needs_review(
    bucket: list[tuple[Any, Any]], reason: str
) -> None:
    for _q, img in bucket:
        img.extraction_status = "needs_review"
        img.review_notes = reason


def _bind_option_image(
    question: Any, token_id: str, filename: str
) -> None:
    """If the matching token sits inside an option's text and that option's
    text is JUST the token (no other content), set option.image_filename."""
    options = getattr(question, "options", None) or []
    token = f"[{token_id}]" if token_id.startswith("IMAGE_") else f"[IMAGE_{token_id}]"
    for opt in options:
        text = getattr(opt, "text", "") or ""
        if token in text and _BARE_TOKEN_RE.match(text):
            opt.image_filename = filename
            return
    # Token might appear in stem; nothing to bind on options. That's normal
    # (e.g. a circuit diagram in the question stem).


def link_questions_to_cropped_images(
    *,
    questions: list[Any],
    paper_stem: str,
    crops_root: Path,
    images_root: Path,
) -> int:
    """Pair Pass-1 image stubs with on-disk crops, copy each crop into
    `images_root/paper_stem/`, and stamp filename onto image + option.

    Returns the number of (image, file) pairs successfully bound.

    `crops_root` is the folder containing the manually-cropped PDF subdirs
    (e.g. `test-cropping/cropped_images/<crop_folder>/page_<N>/imageM.png`).
    The caller is responsible for resolving the PDF-specific subfolder name
    and passing the path to it as `crops_root` — i.e. this function expects
    `crops_root / page_<N> / imageM.png`, NOT a path to a parent that
    contains many PDF folders.
    """
    if not crops_root.is_dir():
        logger.info("image linker: no crops folder at %s — nothing to link", crops_root)
        return 0

    out_dir = images_root / paper_stem
    try:
        out_dir.mkdir(parents=True, exist_ok=True)
    except Exception:
        logger.exception("image linker: failed to create output dir %s", out_dir)
        return 0

    # Bucket stubs by page in the order they appeared (which is the contract's
    # reading order). Carry the question alongside so we can bind option images.
    page_buckets: dict[int, list[tuple[Any, Any]]] = {}
    for page_index, q, img in _stubs_in_reading_order(questions):
        page_buckets.setdefault(page_index, []).append((q, img))

    # Counters for filename suffixes per (page, question_number) so re-runs
    # and questions sharing a number on the same page never collide.
    used_names: set[str] = set()
    bound = 0

    for page_index, bucket in sorted(page_buckets.items()):
        page_dir = crops_root / f"page_{page_index + 1}"
        crops = _list_crops_for_page(page_dir)

        if not crops:
            logger.warning(
                "image linker: page_%d has %d token(s) but no crop files at %s",
                page_index + 1,
                len(bucket),
                page_dir,
            )
            _mark_page_needs_review(
                bucket, f"no manual crops in {page_dir}"
            )
            continue

        if len(crops) != len(bucket):
            logger.warning(
                "image linker: page_%d has %d token(s) vs %d crop file(s) — skipping pairing",
                page_index + 1,
                len(bucket),
                len(crops),
            )
            _mark_page_needs_review(
                bucket,
                f"token/file count mismatch on page {page_index + 1}: "
                f"{len(bucket)} tokens vs {len(crops)} files",
            )
            continue

        # Per-(question,idx) suffix counter so multiple images on the same
        # question still each get a unique name.
        per_question_idx: dict[str, int] = {}

        for (q, img), crop_path in zip(bucket, crops):
            qnum = _safe_qnum(getattr(q, "question_number", "") or "")
            per_question_idx[qnum] = per_question_idx.get(qnum, 0) + 1
            idx = per_question_idx[qnum]

            base_name = f"p{page_index + 1:02d}_q{qnum}_{idx:02d}.png"
            filename = base_name
            bump = 0
            while filename in used_names:
                bump += 1
                filename = f"p{page_index + 1:02d}_q{qnum}_{idx:02d}_{bump}.png"
            used_names.add(filename)

            out_path = out_dir / filename
            try:
                shutil.copyfile(crop_path, out_path)
            except Exception as e:
                logger.exception(
                    "image linker: failed to copy %s → %s", crop_path, out_path
                )
                img.extraction_status = "failed"
                img.review_notes = f"copy failed: {e}"
                continue

            img.filename = filename
            img.extraction_status = "ok"
            img.review_notes = None

            _bind_option_image(q, getattr(img, "id", ""), filename)
            bound += 1

    logger.info(
        "image linker: bound %d image(s) for paper_stem=%s from %s",
        bound,
        paper_stem,
        crops_root,
    )
    return bound


_COLLISION_SUFFIX_RE = re.compile(r"_\d+$")


def resolve_crop_folder(
    *,
    paper_stem: str,
    crops_root: Path,
    alias_map: dict[str, str] | None = None,
) -> Path | None:
    """Resolve the per-PDF subfolder under `crops_root`.

    `paper_stem` may carry a collision suffix from `resolve_output_path`
    (e.g. `Foo_1`, `Foo_2`) when re-extracting the same PDF. We strip those
    progressively when looking up the alias / direct match.

    Lookup order, for each of [paper_stem, paper_stem with one suffix stripped, ...]:
      1. `alias_map[stem]` if present.
      2. `crops_root / stem` if that directory exists.
    Returns None if nothing matches — caller falls back to Pass 2.
    """
    candidates: list[str] = [paper_stem]
    stripped = paper_stem
    while True:
        m = _COLLISION_SUFFIX_RE.search(stripped)
        if not m:
            break
        stripped = stripped[: m.start()]
        candidates.append(stripped)

    for stem in candidates:
        if alias_map and stem in alias_map:
            candidate = crops_root / alias_map[stem]
            if candidate.is_dir():
                return candidate
        candidate = crops_root / stem
        if candidate.is_dir():
            return candidate
    return None

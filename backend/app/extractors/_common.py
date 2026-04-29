"""Shared helpers for all per-(exam_type, question_type) extraction runners."""

import logging
from typing import Any

from ..prompts import UserPromptBuilder
from ..schemas import ExamType, QuestionType

logger = logging.getLogger(__name__)


def latch_metadata(
    known: dict[str, Any],
    questions: list[Any],
    keys: tuple[str, ...],
) -> None:
    """First-write-wins: latch each missing key in `known` from the first
    question that has it populated.

    After every page's questions are parsed, this is called with the full
    questions list + the fields we want to propagate. Once a field is set,
    subsequent pages don't overwrite it.
    """
    for q in questions:
        for key in keys:
            if known.get(key) is None:
                val = getattr(q, key, None)
                if val:
                    known[key] = val


def backfill_metadata(
    questions: list[Any], known: dict[str, Any], keys: tuple[str, ...]
) -> None:
    """Fill any still-null metadata field on every question from the latched
    `known` dict. Guards against the model forgetting to propagate a header
    value across pages."""
    for q in questions:
        for key in keys:
            val = known.get(key)
            if val and getattr(q, key, None) is None:
                setattr(q, key, val)


def stamp_fixed(
    questions: list[Any], fields: dict[str, Any]
) -> None:
    """Unconditionally set `fields` on every question (used when the client
    declared a fixed subject/paper that the pipeline trusts over anything the
    model returned)."""
    for q in questions:
        for key, val in fields.items():
            if val is not None:
                setattr(q, key, val)


def stamp_image_page_index(questions: list[Any], page_index: int) -> None:
    """Set `page_index` on every QuestionImage emitted on this page that
    doesn't already have one. The Pass-1 model isn't asked for a page_index
    per image (that was a Pass-2 job), but we know it: it's the page we just
    sent to Gemini. The image linker uses this to bucket images by page.

    Idempotent: if Pass-2 ran later and filled `page_index` itself, we leave
    that value alone.
    """
    for q in questions:
        for img in getattr(q, "images", None) or []:
            if getattr(img, "page_index", None) is None:
                img.page_index = page_index

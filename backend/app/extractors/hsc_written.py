"""HSC board creative-question runner.

Key differences vs MCQ runners:
  - Larger tail context (prompt instruction already accounts for multi-page
    creative questions; we also bump the effective tail char budget).
  - Post-parse validation: every question must have exactly 4 sub-parts with
    labels [a,b,c,d] and marks [1,2,3,4]. Malformed rows are dropped with a
    logged warning — they don't poison the DB.
  - `uddipak_has_image` is reconciled from the actual `[IMAGE]` marker in the
    text so downstream code can rely on the flag even when the model forgets.
"""

import asyncio
import logging
import re

from .. import checkpoints
from ..config import Settings
from ..gemini_client import GeminiExtractor
from ..jobs import job_store
from ..prompts import get_prompt
from ..schemas import HscWrittenPageExtraction, HscWrittenPdfExtraction, HscWrittenQuestion
from ._common import backfill_metadata, latch_metadata, stamp_fixed, stamp_image_page_index

logger = logging.getLogger(__name__)

_LATCH_KEYS = ("board_name", "exam_year")

# Creative questions span pages frequently (uddipak on one page, sub-parts on
# the next). 2x the MCQ tail budget gives the stitching prompt enough context.
_TAIL_MULTIPLIER = 2

_EXPECTED_LABELS = ("a", "b", "c", "d")
_EXPECTED_MARKS = (1, 2, 3, 4)


def _validate_question(q: HscWrittenQuestion, question_index: int) -> bool:
    labels = tuple(sp.label for sp in q.sub_questions)
    marks = tuple(sp.marks for sp in q.sub_questions)
    if labels != _EXPECTED_LABELS or marks != _EXPECTED_MARKS:
        logger.warning(
            "HSC written: dropping malformed question (qno=%s, labels=%s, marks=%s)",
            q.question_number,
            labels,
            marks,
        )
        return False
    return True


_IMAGE_TOKEN_RE = re.compile(r"\[IMAGE(?:_\d+)?\]")


def _reconcile_uddipak_image_flag(q: HscWrittenQuestion) -> None:
    """True if the uddipak contains any `[IMAGE]` or `[IMAGE_N]` token."""
    q.uddipak_has_image = bool(_IMAGE_TOKEN_RE.search(q.uddipak_text))


async def run(
    *,
    job_id: str,
    images: list[bytes],
    filename: str,
    settings: Settings,
    subjects: tuple[str, ...],
    subject_paper: str | None,
) -> HscWrittenPdfExtraction:
    system_prompt, build_user_prompt = get_prompt(
        "hsc_board", "written", subjects, subject_paper
    )
    extractor = GeminiExtractor(settings)
    total = len(images)
    tail_budget = settings.tail_context_chars * _TAIL_MULTIPLIER

    all_questions: list[HscWrittenQuestion] = []
    prev_tail = ""
    prev_incomplete = False
    known: dict[str, object | None] = {k: None for k in _LATCH_KEYS}
    fixed_single_subject = len(subjects) == 1

    for i, image_png in enumerate(images):
        user_prompt = build_user_prompt(
            prev_tail=prev_tail[-tail_budget:] if prev_tail else "",
            prev_incomplete=prev_incomplete,
            page_index=i,
            total_pages=total,
            known_metadata=known if any(known.values()) else None,
        )
        page: HscWrittenPageExtraction = await extractor.extract_page(
            image_png=image_png,
            system_prompt=system_prompt,
            user_prompt=user_prompt,
            response_schema=HscWrittenPageExtraction,
            page_index=i,
        )

        if fixed_single_subject:
            stamp_fixed(
                page.questions,
                {"subject": subjects[0], "subject_paper": subject_paper},
            )

        for q in page.questions:
            _reconcile_uddipak_image_flag(q)

        valid = [q for idx, q in enumerate(page.questions) if _validate_question(q, idx)]
        stamp_image_page_index(valid, page_index=i)
        all_questions.extend(valid)
        latch_metadata(known, valid, _LATCH_KEYS)
        prev_tail = page.tail_text or ""
        prev_incomplete = page.last_question_incomplete
        checkpoints.append_page(
            output_dir=settings.output_path,
            job_id=job_id,
            filename=filename,
            exam_type="hsc_board",
            question_type="written",
            total_pages=total,
            page_count_seen=i + 1,
            questions=all_questions,
        )
        await job_store.update_progress(job_id, page=i + 1, total=total)
        if i < total - 1:
            await asyncio.sleep(settings.request_pause_seconds)

    backfill_metadata(all_questions, known, _LATCH_KEYS)

    return HscWrittenPdfExtraction(
        source_filename=filename,
        page_count=total,
        questions=all_questions,
    )

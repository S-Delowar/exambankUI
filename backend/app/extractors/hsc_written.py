"""HSC board creative-question runner.

Key differences vs MCQ runners:
  - Larger tail context (prompt instruction already accounts for multi-page
    creative questions; we also bump the effective tail char budget).
  - Post-parse validation: sub-part shape must match one of two valid patterns:
      Most subjects: 4 parts (a=1, b=2, c=3, d=4)
      Mathematics:   3 parts (a=2, b=4, c=4)
    Malformed rows are dropped with a logged warning.
  - Uddipoks are accumulated across pages and deduplicated by temp ID.
"""

import asyncio
import logging

from .. import checkpoints
from ..config import Settings
from ..gemini_client import GeminiExtractor
from ..jobs import job_store
from ..prompts import get_prompt
from ..schemas import HscWrittenPageExtraction, HscWrittenPdfExtraction, HscWrittenQuestion
from ..schemas.uddipok import Uddipok
from ._common import backfill_metadata, latch_metadata, stamp_fixed, stamp_image_page_index

logger = logging.getLogger(__name__)

_LATCH_KEYS = ("board_name", "exam_year")

# Creative questions span pages frequently (uddipak on one page, sub-parts on
# the next). 2x the MCQ tail budget gives the stitching prompt enough context.
_TAIL_MULTIPLIER = 2

# Valid subpart patterns: (labels_tuple, marks_tuple)
_VALID_SHAPES = {
    # Most subjects: 4 subparts
    (("a", "b", "c", "d"), (1, 2, 3, 4)),
    # Mathematics: 3 subparts
    (("a", "b", "c"), (2, 4, 4)),
}


def _validate_question(q: HscWrittenQuestion, question_index: int) -> bool:
    labels = tuple(sp.label for sp in q.sub_questions)
    marks = tuple(sp.marks for sp in q.sub_questions)
    if (labels, marks) not in _VALID_SHAPES:
        logger.warning(
            "HSC written: dropping malformed question (qno=%s, labels=%s, marks=%s)",
            q.question_number,
            labels,
            marks,
        )
        return False
    return True




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
    all_uddipoks: dict[str, Uddipok] = {}  # temp_id → Uddipok, deduped
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

        # Accumulate uddipoks from each page, deduplicating by temp ID.
        for u in page.uddipoks:
            if u.uddipok_id not in all_uddipoks:
                all_uddipoks[u.uddipok_id] = u
        # Stamp page_index on uddipok images so the image linker can bucket them.
        stamp_image_page_index(page.uddipoks, page_index=i)

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
        uddipoks=list(all_uddipoks.values()),
        questions=all_questions,
    )

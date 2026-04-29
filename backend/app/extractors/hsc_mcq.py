"""HSC board MCQ runner.

Single-subject uploads (len(subjects)==1): the declared subject + subject_paper
are stamped on every question, overriding whatever the model returns. This
prevents any drift mid-PDF and lets the prompt be tighter.

Multi-subject uploads: model infers subject per question; we still latch
board/year across pages.
"""

import asyncio
import logging

from .. import checkpoints
from ..config import Settings
from ..gemini_client import GeminiExtractor
from ..jobs import job_store
from ..prompts import get_prompt
from ..schemas import HscMcqPageExtraction, HscMcqPdfExtraction
from ._common import backfill_metadata, latch_metadata, stamp_fixed, stamp_image_page_index

logger = logging.getLogger(__name__)

_LATCH_KEYS = ("board_name", "exam_year")


async def run(
    *,
    job_id: str,
    images: list[bytes],
    filename: str,
    settings: Settings,
    subjects: tuple[str, ...],
    subject_paper: str | None,
) -> HscMcqPdfExtraction:
    system_prompt, build_user_prompt = get_prompt(
        "hsc_board", "mcq", subjects, subject_paper
    )
    extractor = GeminiExtractor(settings)
    total = len(images)

    all_questions = []
    prev_tail = ""
    prev_incomplete = False
    known: dict[str, object | None] = {k: None for k in _LATCH_KEYS}

    fixed_single_subject = len(subjects) == 1

    for i, image_png in enumerate(images):
        user_prompt = build_user_prompt(
            prev_tail=prev_tail[-settings.tail_context_chars:] if prev_tail else "",
            prev_incomplete=prev_incomplete,
            page_index=i,
            total_pages=total,
            known_metadata=known if any(known.values()) else None,
        )
        page: HscMcqPageExtraction = await extractor.extract_page(
            image_png=image_png,
            system_prompt=system_prompt,
            user_prompt=user_prompt,
            response_schema=HscMcqPageExtraction,
            page_index=i,
        )

        if fixed_single_subject:
            stamp_fixed(
                page.questions,
                {"subject": subjects[0], "subject_paper": subject_paper},
            )

        stamp_image_page_index(page.questions, page_index=i)
        all_questions.extend(page.questions)
        latch_metadata(known, page.questions, _LATCH_KEYS)
        prev_tail = page.tail_text or ""
        prev_incomplete = page.last_question_incomplete
        checkpoints.append_page(
            output_dir=settings.output_path,
            job_id=job_id,
            filename=filename,
            exam_type="hsc_board",
            question_type="mcq",
            total_pages=total,
            page_count_seen=i + 1,
            questions=all_questions,
        )
        await job_store.update_progress(job_id, page=i + 1, total=total)
        if i < total - 1:
            await asyncio.sleep(settings.request_pause_seconds)

    backfill_metadata(all_questions, known, _LATCH_KEYS)

    return HscMcqPdfExtraction(
        source_filename=filename,
        page_count=total,
        questions=all_questions,
    )

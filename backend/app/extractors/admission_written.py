"""Admission-test written-question runner.

Structurally identical to admission_mcq but uses the written schema + prompt
and persists no options.
"""

import asyncio
import logging

from .. import checkpoints
from ..config import Settings
from ..gemini_client import GeminiExtractor
from ..jobs import job_store
from ..prompts import get_prompt
from ..schemas import AdmissionWrittenPageExtraction, AdmissionWrittenPdfExtraction
from ._common import backfill_metadata, latch_metadata, stamp_image_page_index

logger = logging.getLogger(__name__)

_LATCH_KEYS = ("university_name", "exam_session", "exam_unit")


async def run(
    *,
    job_id: str,
    images: list[bytes],
    filename: str,
    settings: Settings,
    subjects: tuple[str, ...],
) -> AdmissionWrittenPdfExtraction:
    system_prompt, build_user_prompt = get_prompt(
        "admission_test", "written", subjects, subject_paper=None
    )
    extractor = GeminiExtractor(settings)
    total = len(images)

    all_questions = []
    prev_tail = ""
    prev_incomplete = False
    known: dict[str, object | None] = {k: None for k in _LATCH_KEYS}

    for i, image_png in enumerate(images):
        user_prompt = build_user_prompt(
            prev_tail=prev_tail[-settings.tail_context_chars:] if prev_tail else "",
            prev_incomplete=prev_incomplete,
            page_index=i,
            total_pages=total,
            known_metadata=known if any(known.values()) else None,
        )
        page: AdmissionWrittenPageExtraction = await extractor.extract_page(
            image_png=image_png,
            system_prompt=system_prompt,
            user_prompt=user_prompt,
            response_schema=AdmissionWrittenPageExtraction,
            page_index=i,
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
            exam_type="admission_test",
            question_type="written",
            total_pages=total,
            page_count_seen=i + 1,
            questions=all_questions,
        )
        await job_store.update_progress(job_id, page=i + 1, total=total)
        if i < total - 1:
            await asyncio.sleep(settings.request_pause_seconds)

    backfill_metadata(all_questions, known, _LATCH_KEYS)

    return AdmissionWrittenPdfExtraction(
        source_filename=filename,
        page_count=total,
        questions=all_questions,
    )

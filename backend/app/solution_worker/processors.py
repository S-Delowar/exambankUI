"""Per-table solution generators.

Each `process_*` function claims up to `limit` pending rows, generates the
solution via Gemini, and writes it back. Returns the count processed.
"""

import asyncio
import logging

from sqlalchemy import select
from sqlalchemy.orm import selectinload

from ..config import Settings
from ..database import SessionLocal
from ..models import (
    AdmissionMcqOption,
    AdmissionMcqQuestion,
    AdmissionWrittenQuestion,
    HscMcqOption,
    HscMcqQuestion,
    HscWrittenQuestion,
    HscWrittenSubpart,
)
from .generator import SolutionGenerator
from .prompts import (
    MCQ_SYSTEM_PROMPT,
    WRITTEN_SYSTEM_PROMPT,
    admission_written_user_prompt,
    hsc_written_subpart_user_prompt,
    mcq_user_prompt,
)

logger = logging.getLogger(__name__)


async def _save_field(model, *, pk, text: str, status: str = "generated") -> None:
    async with SessionLocal() as session:
        async with session.begin():
            obj = await session.get(model, pk)
            if obj is None:
                return
            obj.solution = text
            obj.solution_status = status


async def process_admission_mcq(generator: SolutionGenerator, limit: int) -> int:
    async with SessionLocal() as session:
        stmt = (
            select(AdmissionMcqQuestion)
            .options(selectinload(AdmissionMcqQuestion.options))
            .where(AdmissionMcqQuestion.solution_status == "pending")
            .where(AdmissionMcqQuestion.correct_answer.is_not(None))
            .order_by(AdmissionMcqQuestion.created_at)
            .limit(limit)
        )
        rows = list((await session.execute(stmt)).scalars().all())

    for q in rows:
        try:
            user = mcq_user_prompt(
                question_number=q.question_number,
                question_text=q.question_text,
                options=[(o.label, o.text) for o in q.options],
                correct_answer=q.correct_answer or "",
            )
            text = await generator.generate(MCQ_SYSTEM_PROMPT, user)
            await _save_field(AdmissionMcqQuestion, pk=q.id, text=text)
            logger.info("admission_mcq: generated solution for %s (%s)", q.id, q.question_number)
        except Exception:
            logger.exception("admission_mcq: failed for %s", q.id)
            await _save_field(AdmissionMcqQuestion, pk=q.id, text="", status="failed")
    return len(rows)


async def process_hsc_mcq(generator: SolutionGenerator, limit: int) -> int:
    async with SessionLocal() as session:
        stmt = (
            select(HscMcqQuestion)
            .options(selectinload(HscMcqQuestion.options))
            .where(HscMcqQuestion.solution_status == "pending")
            .where(HscMcqQuestion.correct_answer.is_not(None))
            .order_by(HscMcqQuestion.created_at)
            .limit(limit)
        )
        rows = list((await session.execute(stmt)).scalars().all())

    for q in rows:
        try:
            user = mcq_user_prompt(
                question_number=q.question_number,
                question_text=q.question_text,
                options=[(o.label, o.text) for o in q.options],
                correct_answer=q.correct_answer or "",
            )
            text = await generator.generate(MCQ_SYSTEM_PROMPT, user)
            await _save_field(HscMcqQuestion, pk=q.id, text=text)
            logger.info("hsc_mcq: generated solution for %s (%s)", q.id, q.question_number)
        except Exception:
            logger.exception("hsc_mcq: failed for %s", q.id)
            await _save_field(HscMcqQuestion, pk=q.id, text="", status="failed")
    return len(rows)


async def process_admission_written(generator: SolutionGenerator, limit: int) -> int:
    async with SessionLocal() as session:
        stmt = (
            select(AdmissionWrittenQuestion)
            .where(AdmissionWrittenQuestion.solution_status == "pending")
            .order_by(AdmissionWrittenQuestion.created_at)
            .limit(limit)
        )
        rows = list((await session.execute(stmt)).scalars().all())

    for q in rows:
        try:
            user = admission_written_user_prompt(
                question_number=q.question_number,
                question_text=q.question_text,
            )
            text = await generator.generate(WRITTEN_SYSTEM_PROMPT, user)
            await _save_field(AdmissionWrittenQuestion, pk=q.id, text=text)
            logger.info("admission_written: generated for %s (%s)", q.id, q.question_number)
        except Exception:
            logger.exception("admission_written: failed for %s", q.id)
            await _save_field(AdmissionWrittenQuestion, pk=q.id, text="", status="failed")
    return len(rows)


async def process_hsc_written_subparts(generator: SolutionGenerator, limit: int) -> int:
    """One row per sub-part — each of a/b/c/d gets its own solution."""
    async with SessionLocal() as session:
        stmt = (
            select(HscWrittenSubpart, HscWrittenQuestion)
            .join(HscWrittenQuestion, HscWrittenQuestion.id == HscWrittenSubpart.question_id)
            .where(HscWrittenSubpart.solution_status == "pending")
            .order_by(HscWrittenSubpart.id)
            .limit(limit)
        )
        rows = list((await session.execute(stmt)).all())

    for subpart, question in rows:
        try:
            user = hsc_written_subpart_user_prompt(
                question_number=question.question_number,
                uddipak_text=question.uddipak_text,
                label=subpart.label,
                marks=subpart.marks,
                text=subpart.text,
            )
            text = await generator.generate(WRITTEN_SYSTEM_PROMPT, user)
            await _save_field(HscWrittenSubpart, pk=subpart.id, text=text)
            logger.info(
                "hsc_written_subpart: generated for q=%s sub=%s",
                question.question_number,
                subpart.label,
            )
        except Exception:
            logger.exception(
                "hsc_written_subpart: failed for q=%s sub=%s",
                question.question_number,
                subpart.label,
            )
            await _save_field(
                HscWrittenSubpart, pk=subpart.id, text="", status="failed"
            )
    return len(rows)


async def process_all_once(settings: Settings, limit: int) -> int:
    """Run one batch across every table. Returns total processed."""
    generator = SolutionGenerator(settings)
    total = 0
    for fn in (
        process_admission_mcq,
        process_hsc_mcq,
        process_admission_written,
        process_hsc_written_subparts,
    ):
        n = await fn(generator, limit)
        total += n
        if n:
            await asyncio.sleep(settings.request_pause_seconds)
    return total

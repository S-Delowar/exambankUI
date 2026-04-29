"""Topic drill: random-sample MCQ questions by (exam_type, subject, chapter).

Drill is MCQ-only — written questions aren't scorable as quick practice. When
`exam_type=hsc_board` and a `subject_paper` is passed, the drill also scopes
chapters to the paper_{1,2} slice of the taxonomy so the user never sees a
chapter that doesn't belong to the paper they picked.

v1 uses ``ORDER BY random() LIMIT :count``. At scale (100k+ rows per
partition), switch to ``TABLESAMPLE SYSTEM(p)`` + post-filter.
"""

import uuid
from typing import Any

from fastapi import HTTPException
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from ..config import get_settings
from ..models import AdmissionMcqQuestion, HscMcqQuestion
from . import questions_service


_PAPER_SPLIT_SUBJECTS = frozenset({"physics", "chemistry", "mathematics", "biology"})


def _mcq_model_for(exam_type: str) -> Any:
    if exam_type == "admission_test":
        return AdmissionMcqQuestion
    if exam_type == "hsc_board":
        return HscMcqQuestion
    raise HTTPException(422, f"Unsupported exam_type for drill: {exam_type!r}")


def _validate_taxonomy(
    subject: str,
    chapter: str,
    subject_paper: str | None,
) -> None:
    settings = get_settings()
    flat = settings.chapter_taxonomy
    nested = settings.chapter_taxonomy_nested

    if subject not in flat:
        raise HTTPException(422, f"Unknown subject: {subject}")

    # If subject_paper is given AND the subject has paper_1/paper_2 in the
    # nested taxonomy, restrict the valid chapter list to that paper.
    if subject_paper is not None and subject in _PAPER_SPLIT_SUBJECTS:
        entry = nested.get(subject)
        paper_key = f"paper_{subject_paper}"
        paper_chapters: list[str]
        if isinstance(entry, dict) and paper_key in entry:
            paper_chapters = [str(c) for c in entry[paper_key]]
        else:
            paper_chapters = list(flat[subject])
        if chapter not in paper_chapters:
            raise HTTPException(
                422,
                f"Chapter '{chapter}' not in subject '{subject}' paper {subject_paper}",
            )
        return

    if chapter not in flat[subject]:
        raise HTTPException(422, f"Unknown chapter '{chapter}' for subject '{subject}'")


async def sample_question_ids(
    session: AsyncSession,
    *,
    exam_type: str,
    subject: str,
    chapter: str,
    count: int,
    subject_paper: str | None = None,
) -> list[uuid.UUID]:
    _validate_taxonomy(subject, chapter, subject_paper)
    model = _mcq_model_for(exam_type)

    stmt = (
        select(model.id)
        .where(model.subject == subject)
        .where(model.chapter == chapter)
        .where(model.correct_answer.is_not(None))
    )
    if exam_type == "hsc_board" and subject_paper is not None:
        stmt = stmt.where(model.subject_paper == subject_paper)
    stmt = stmt.order_by(func.random()).limit(count)

    rows = (await session.execute(stmt)).scalars().all()
    return list(rows)


async def sample_questions(
    session: AsyncSession,
    *,
    exam_type: str,
    subject: str,
    chapter: str,
    count: int,
    subject_paper: str | None = None,
) -> list[Any]:
    _validate_taxonomy(subject, chapter, subject_paper)
    model = _mcq_model_for(exam_type)

    stmt = (
        select(model)
        .options(selectinload(model.options))
        .where(model.subject == subject)
        .where(model.chapter == chapter)
        .where(model.correct_answer.is_not(None))
    )
    if exam_type == "hsc_board" and subject_paper is not None:
        stmt = stmt.where(model.subject_paper == subject_paper)
    stmt = stmt.order_by(func.random()).limit(count)

    rows = (await session.execute(stmt)).scalars().all()

    if exam_type == "admission_test":
        return [questions_service.admission_mcq_to_out(q) for q in rows]
    return [questions_service.hsc_mcq_to_out(q) for q in rows]

"""Bookmarks: idempotent add/remove, paginated list with embedded question.

Bookmarks use a polymorphic question reference: (question_id, exam_type,
question_type). The question is looked up from the appropriate table based
on the discriminator columns.
"""

import uuid

from fastapi import HTTPException
from sqlalchemy import func, select
from sqlalchemy.dialects.postgresql import insert as pg_insert
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from ..models import AdmissionMcqQuestion, HscMcqQuestion, Bookmark
from ..schemas.user_data import BookmarkOut
from . import questions_service


# Map (exam_type, question_type) to the question model + options relationship.
_MCQ_MODELS = {
    "admission_test": (AdmissionMcqQuestion, AdmissionMcqQuestion.options),
    "hsc_board": (HscMcqQuestion, HscMcqQuestion.options),
}


async def _load_mcq_question(
    session: AsyncSession, *, question_id: uuid.UUID, exam_type: str
):
    """Look up an MCQ question from the correct table."""
    entry = _MCQ_MODELS.get(exam_type)
    if entry is None:
        raise HTTPException(400, f"Bookmarks not supported for exam_type={exam_type!r}")
    model, options_rel = entry
    q = await session.execute(
        select(model).options(selectinload(options_rel)).where(model.id == question_id)
    )
    return q.scalar_one_or_none()


async def add(
    session: AsyncSession,
    *,
    user_id: uuid.UUID,
    question_id: uuid.UUID,
    exam_type: str = "admission_test",
    question_type: str = "mcq",
) -> BookmarkOut:
    if question_type != "mcq":
        raise HTTPException(400, "Only MCQ questions can be bookmarked in this version")

    question = await _load_mcq_question(
        session, question_id=question_id, exam_type=exam_type
    )
    if question is None:
        raise HTTPException(404, "Question not found")

    stmt = (
        pg_insert(Bookmark)
        .values(
            user_id=user_id,
            question_id=question_id,
            exam_type=exam_type,
            question_type=question_type,
        )
        .on_conflict_do_nothing(
            constraint="uq_bookmarks_user_question",
        )
    )
    await session.execute(stmt)
    await session.commit()

    result = await session.execute(
        select(Bookmark).where(
            Bookmark.user_id == user_id,
            Bookmark.question_id == question_id,
            Bookmark.exam_type == exam_type,
            Bookmark.question_type == question_type,
        )
    )
    bm = result.scalar_one()
    return BookmarkOut(
        question_id=bm.question_id,
        created_at=bm.created_at,
        question=questions_service.admission_mcq_to_out(question),
    )


async def remove(
    session: AsyncSession,
    *,
    user_id: uuid.UUID,
    question_id: uuid.UUID,
    exam_type: str = "admission_test",
    question_type: str = "mcq",
) -> None:
    await session.execute(
        Bookmark.__table__.delete().where(
            Bookmark.user_id == user_id,
            Bookmark.question_id == question_id,
            Bookmark.exam_type == exam_type,
            Bookmark.question_type == question_type,
        )
    )
    await session.commit()


async def list_for_user(
    session: AsyncSession, *, user_id: uuid.UUID, limit: int, offset: int
) -> tuple[int, list[BookmarkOut]]:
    total = (
        await session.execute(
            select(func.count(Bookmark.id)).where(Bookmark.user_id == user_id)
        )
    ).scalar_one()

    rows = (
        await session.execute(
            select(Bookmark)
            .where(Bookmark.user_id == user_id)
            .order_by(Bookmark.created_at.desc())
            .limit(limit)
            .offset(offset)
        )
    ).scalars().all()

    # Load questions for each bookmark from the correct table.
    items: list[BookmarkOut] = []
    for bm in rows:
        question = await _load_mcq_question(
            session, question_id=bm.question_id, exam_type=bm.exam_type
        )
        if question is None:
            continue  # orphaned bookmark — question was deleted
        items.append(
            BookmarkOut(
                question_id=bm.question_id,
                created_at=bm.created_at,
                question=questions_service.admission_mcq_to_out(question),
            )
        )
    return total, items

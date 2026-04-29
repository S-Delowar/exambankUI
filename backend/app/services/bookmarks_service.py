"""Bookmarks: idempotent add/remove, paginated list with embedded question.

Bookmarks currently reference `admission_mcq_questions` only. See plan
Follow-ups: to bookmark HSC or written questions we need a polymorphic FK
layer on `bookmarks.question_id` (or a per-type bookmark table).
"""

import uuid

from fastapi import HTTPException
from sqlalchemy import func, select
from sqlalchemy.dialects.postgresql import insert as pg_insert
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from ..models import AdmissionMcqQuestion, Bookmark
from ..schemas_user_data import BookmarkOut
from . import questions_service


async def add(
    session: AsyncSession, *, user_id: uuid.UUID, question_id: uuid.UUID
) -> BookmarkOut:
    q = await session.execute(
        select(AdmissionMcqQuestion)
        .options(selectinload(AdmissionMcqQuestion.options))
        .where(AdmissionMcqQuestion.id == question_id)
    )
    question = q.scalar_one_or_none()
    if question is None:
        raise HTTPException(404, "Question not found")

    stmt = (
        pg_insert(Bookmark)
        .values(user_id=user_id, question_id=question_id)
        .on_conflict_do_nothing(
            index_elements=[Bookmark.user_id, Bookmark.question_id]
        )
    )
    await session.execute(stmt)
    await session.commit()

    result = await session.execute(
        select(Bookmark).where(
            Bookmark.user_id == user_id, Bookmark.question_id == question_id
        )
    )
    bm = result.scalar_one()
    return BookmarkOut(
        question_id=bm.question_id,
        created_at=bm.created_at,
        question=questions_service.admission_mcq_to_out(question),
    )


async def remove(
    session: AsyncSession, *, user_id: uuid.UUID, question_id: uuid.UUID
) -> None:
    await session.execute(
        Bookmark.__table__.delete().where(
            Bookmark.user_id == user_id, Bookmark.question_id == question_id
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
            .options(
                selectinload(Bookmark.question).selectinload(AdmissionMcqQuestion.options)
            )
            .where(Bookmark.user_id == user_id)
            .order_by(Bookmark.created_at.desc())
            .limit(limit)
            .offset(offset)
        )
    ).scalars().all()

    items = [
        BookmarkOut(
            question_id=bm.question_id,
            created_at=bm.created_at,
            question=questions_service.admission_mcq_to_out(bm.question),
        )
        for bm in rows
    ]
    return total, items

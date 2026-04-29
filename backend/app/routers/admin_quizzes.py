"""Admin endpoints for managing (subject, exam_type) quizzes.

A quiz is the implicit pair `(subject, exam_type)` — see plan
`quizzes-per-subject-and-exam-type.md`. There is no `quizzes` table; status
lives in `quiz_status` and absence of a row means draft. Roster queries pull
from `attempts` filtered by `(drill_subject, exam_type, kind='subject_quiz')`.

All routes require admin.
"""

from collections import defaultdict
from datetime import datetime, timezone
from typing import Any, Literal

from fastapi import APIRouter, Body, Depends, HTTPException, Query
from pydantic import BaseModel, ConfigDict
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from ..database import get_session
from ..deps import require_admin
from ..models import (
    AdmissionMcqQuestion,
    AdmissionWrittenQuestion,
    Attempt,
    HscMcqQuestion,
    HscWrittenQuestion,
    QuizStatus,
    User,
)
from ..schemas_user_data import AttemptSummary

router = APIRouter(
    prefix="/admin/quizzes",
    tags=["admin-quizzes"],
    dependencies=[Depends(require_admin)],
)


# (model, exam_type) — same partitioning the public stats endpoint uses.
_QUESTION_SOURCES: tuple[tuple[Any, str], ...] = (
    (AdmissionMcqQuestion, "admission_test"),
    (AdmissionWrittenQuestion, "admission_test"),
    (HscMcqQuestion, "hsc_board"),
    (HscWrittenQuestion, "hsc_board"),
)


class QuizListEntry(BaseModel):
    subject: str
    exam_type: str
    total_questions: int
    status: str
    attempts_in_progress: int
    attempts_submitted: int
    attempts_total: int


class QuizListOut(BaseModel):
    quizzes: list[QuizListEntry]


class QuizStatusIn(BaseModel):
    status: Literal["draft", "published", "archived"]


class QuizStatusOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    subject: str
    exam_type: str
    status: str
    updated_at: datetime
    updated_by_id: Any | None = None


class RosterEntry(AttemptSummary):
    """Roster row: attempt summary plus enough user info to identify who."""

    user_email: str
    user_display_name: str | None


class RosterOut(BaseModel):
    total: int
    items: list[RosterEntry]


# ---------------------------------------------------------------------------
# GET /admin/quizzes — full grid in one round-trip
# ---------------------------------------------------------------------------


@router.get("", response_model=QuizListOut)
async def list_quizzes(
    session: AsyncSession = Depends(get_session),
) -> QuizListOut:
    """Every `(subject, exam_type)` pair that has at least one question, with
    its current status and aggregate roster counts. Powers the admin grid.
    """
    # 1. Question counts per (subject, exam_type).
    counts: dict[tuple[str, str], int] = defaultdict(int)
    for model, exam_type in _QUESTION_SOURCES:
        stmt = (
            select(model.subject, func.count())
            .where(model.subject.is_not(None))
            .group_by(model.subject)
        )
        for subject, n in (await session.execute(stmt)).all():
            counts[(subject, exam_type)] += n

    # 2. Status rows.
    status_rows = (await session.execute(select(QuizStatus))).scalars().all()
    status_map: dict[tuple[str, str], str] = {
        (r.subject, r.exam_type): r.status for r in status_rows
    }

    # 3. Roster aggregate — one query, grouped by (drill_subject, exam_type, status).
    # Filter to subject_quiz attempts so drill / exam don't leak in.
    stmt = (
        select(
            Attempt.drill_subject,
            Attempt.exam_type,
            Attempt.status,
            func.count(),
        )
        .where(Attempt.kind == "subject_quiz")
        .where(Attempt.drill_subject.is_not(None))
        .where(Attempt.exam_type.is_not(None))
        .group_by(Attempt.drill_subject, Attempt.exam_type, Attempt.status)
    )
    in_progress: dict[tuple[str, str], int] = defaultdict(int)
    submitted: dict[tuple[str, str], int] = defaultdict(int)
    for subj, ex, st, n in (await session.execute(stmt)).all():
        if st == "in_progress":
            in_progress[(subj, ex)] = n
        elif st == "submitted":
            submitted[(subj, ex)] = n

    quizzes: list[QuizListEntry] = []
    for (subject, exam_type), total in counts.items():
        ip = in_progress.get((subject, exam_type), 0)
        sb = submitted.get((subject, exam_type), 0)
        quizzes.append(
            QuizListEntry(
                subject=subject,
                exam_type=exam_type,
                total_questions=total,
                status=status_map.get((subject, exam_type), "draft"),
                attempts_in_progress=ip,
                attempts_submitted=sb,
                attempts_total=ip + sb,
            )
        )
    quizzes.sort(key=lambda q: (q.subject, q.exam_type))
    return QuizListOut(quizzes=quizzes)


# ---------------------------------------------------------------------------
# PUT /admin/quizzes/{subject}/{exam_type}/status — set publish state
# ---------------------------------------------------------------------------


@router.put(
    "/{subject}/{exam_type}/status",
    response_model=QuizStatusOut,
)
async def set_quiz_status(
    subject: str,
    exam_type: Literal["admission_test", "hsc_board"],
    body: QuizStatusIn,
    session: AsyncSession = Depends(get_session),
    admin: User = Depends(require_admin),
) -> QuizStatusOut:
    """Upsert quiz_status. Publishing a quiz with zero questions is rejected
    so students never see an empty card."""
    if body.status == "published":
        # Verify there's at least one question for this (subject, exam_type).
        # Cheap — same partitioning the grid uses.
        total = 0
        for model, et in _QUESTION_SOURCES:
            if et != exam_type:
                continue
            n = (
                await session.execute(
                    select(func.count())
                    .select_from(model)
                    .where(model.subject == subject)
                )
            ).scalar() or 0
            total += int(n)
        if total == 0:
            raise HTTPException(
                400,
                f"Cannot publish '{subject} ({exam_type})': no questions in the bank yet",
            )

    row = await session.get(QuizStatus, (subject, exam_type))
    if row is None:
        row = QuizStatus(subject=subject, exam_type=exam_type, status=body.status)
        session.add(row)
    else:
        row.status = body.status
    row.updated_by_id = admin.id
    # onupdate=func.now() in the model handles updated_at on UPDATE; for
    # INSERT, server_default=now() handles it. Force a flush so the response
    # carries the populated timestamp.
    await session.flush()
    await session.refresh(row)
    await session.commit()
    return QuizStatusOut.model_validate(row)


# ---------------------------------------------------------------------------
# GET /admin/quizzes/{subject}/{exam_type}/attempts — roster
# ---------------------------------------------------------------------------


@router.get(
    "/{subject}/{exam_type}/attempts",
    response_model=RosterOut,
)
async def list_quiz_attempts(
    subject: str,
    exam_type: Literal["admission_test", "hsc_board"],
    status: Literal["in_progress", "submitted", "abandoned", "all"] = Query("all"),
    limit: int = Query(50, ge=1, le=500),
    offset: int = Query(0, ge=0),
    session: AsyncSession = Depends(get_session),
) -> RosterOut:
    """Attempts against this quiz — every user, both in-progress and submitted
    by default. Joined to `users` so the admin sees who's who without a
    separate lookup."""
    stmt = (
        select(Attempt, User)
        .join(User, User.id == Attempt.user_id)
        .where(Attempt.kind == "subject_quiz")
        .where(Attempt.drill_subject == subject)
        .where(Attempt.exam_type == exam_type)
        .order_by(Attempt.started_at.desc())
    )
    if status != "all":
        stmt = stmt.where(Attempt.status == status)

    total_stmt = (
        select(func.count())
        .select_from(Attempt)
        .where(Attempt.kind == "subject_quiz")
        .where(Attempt.drill_subject == subject)
        .where(Attempt.exam_type == exam_type)
    )
    if status != "all":
        total_stmt = total_stmt.where(Attempt.status == status)
    total = (await session.execute(total_stmt)).scalar() or 0

    rows = (
        await session.execute(stmt.limit(limit).offset(offset))
    ).all()
    items: list[RosterEntry] = []
    for attempt, user in rows:
        summary = AttemptSummary.model_validate(attempt)
        items.append(
            RosterEntry(
                **summary.model_dump(),
                user_email=user.email,
                user_display_name=user.display_name,
            )
        )
    return RosterOut(total=int(total), items=items)

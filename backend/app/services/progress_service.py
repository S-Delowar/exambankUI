"""Progress summary: computed live with indexed queries (v1).

Streak is in UTC calendar days. Document this in the endpoint; a future
``?tz=`` parameter can make this user-local.
"""

import uuid
from datetime import date, timedelta

from sqlalchemy import Integer, distinct, func, select, text
from sqlalchemy.ext.asyncio import AsyncSession

from ..models import AdmissionMcqQuestion, Attempt, AttemptAnswer
from ..schemas_user_data import ChapterStat, ProgressSummaryOut, SubjectStat

# attempt_answers.question_id points at admission_mcq_questions.id — progress
# stats are currently computed over admission-MCQ attempts only. Extending
# this to HSC-MCQ or written requires the polymorphic FK follow-up.
Question = AdmissionMcqQuestion


async def compute_summary(
    session: AsyncSession, *, user_id: uuid.UUID
) -> ProgressSummaryOut:
    # Totals across all submitted attempts
    totals_stmt = (
        select(
            func.count(distinct(Attempt.id)),
            func.count(AttemptAnswer.id),
            func.coalesce(
                func.sum(func.cast(AttemptAnswer.is_correct, Integer)), 0
            ),
        )
        .select_from(Attempt)
        .join(AttemptAnswer, AttemptAnswer.attempt_id == Attempt.id, isouter=True)
        .where(Attempt.user_id == user_id, Attempt.status == "submitted")
    )
    total_attempts, total_questions, total_correct = (
        await session.execute(totals_stmt)
    ).one()
    total_attempts = int(total_attempts or 0)
    total_questions = int(total_questions or 0)
    total_correct = int(total_correct or 0)

    # Weekly accuracy (last 7 UTC days)
    week_cutoff = date.today() - timedelta(days=6)
    week_stmt = (
        select(
            func.count(AttemptAnswer.id),
            func.coalesce(
                func.sum(func.cast(AttemptAnswer.is_correct, Integer)), 0
            ),
        )
        .select_from(AttemptAnswer)
        .join(Attempt, Attempt.id == AttemptAnswer.attempt_id)
        .where(
            Attempt.user_id == user_id,
            Attempt.status == "submitted",
            Attempt.submitted_at >= week_cutoff,
        )
    )
    week_attempted, week_correct = (await session.execute(week_stmt)).one()
    week_attempted = int(week_attempted or 0)
    week_correct = int(week_correct or 0)
    weekly_accuracy = (week_correct / week_attempted) if week_attempted else 0.0

    # By-subject and by-chapter aggregates
    agg_stmt = (
        select(
            Question.subject,
            Question.chapter,
            func.count(AttemptAnswer.id),
            func.coalesce(
                func.sum(func.cast(AttemptAnswer.is_correct, Integer)), 0
            ),
        )
        .select_from(AttemptAnswer)
        .join(Attempt, Attempt.id == AttemptAnswer.attempt_id)
        .join(Question, Question.id == AttemptAnswer.question_id)
        .where(Attempt.user_id == user_id, Attempt.status == "submitted")
        .group_by(Question.subject, Question.chapter)
    )
    rows = (await session.execute(agg_stmt)).all()

    by_subject_map: dict[str, dict[str, int]] = {}
    by_chapter: list[ChapterStat] = []
    for subject, chapter, attempted, correct in rows:
        attempted = int(attempted or 0)
        correct = int(correct or 0)
        subj = subject or "unknown"
        chap = chapter or "unknown"
        bs = by_subject_map.setdefault(subj, {"attempted": 0, "correct": 0})
        bs["attempted"] += attempted
        bs["correct"] += correct
        by_chapter.append(
            ChapterStat(
                subject=subj,
                chapter=chap,
                attempted=attempted,
                correct=correct,
                accuracy=(correct / attempted) if attempted else 0.0,
            )
        )

    by_subject = [
        SubjectStat(
            subject=subj,
            attempted=v["attempted"],
            correct=v["correct"],
            accuracy=(v["correct"] / v["attempted"]) if v["attempted"] else 0.0,
        )
        for subj, v in by_subject_map.items()
    ]

    # Streak: consecutive UTC days ending today or yesterday with >=1 submitted attempt.
    streak = await _compute_streak(session, user_id=user_id)

    return ProgressSummaryOut(
        streak_days=streak,
        total_attempts=total_attempts,
        total_questions=total_questions,
        total_correct=total_correct,
        weekly_accuracy=weekly_accuracy,
        by_subject=by_subject,
        by_chapter=by_chapter,
    )


async def _compute_streak(session: AsyncSession, *, user_id: uuid.UUID) -> int:
    """Count consecutive UTC days ending today or yesterday with at least one
    submitted attempt."""
    rows = await session.execute(
        select(
            func.distinct(
                func.date_trunc(
                    "day", func.timezone("UTC", Attempt.submitted_at)
                )
            )
        )
        .where(
            Attempt.user_id == user_id,
            Attempt.status == "submitted",
            Attempt.submitted_at.is_not(None),
        )
    )
    days = sorted({r[0].date() for r in rows.all() if r[0] is not None}, reverse=True)
    if not days:
        return 0
    today = date.today()
    latest = days[0]
    if latest < today - timedelta(days=1):
        return 0
    streak = 1
    for i in range(1, len(days)):
        if days[i] == days[i - 1] - timedelta(days=1):
            streak += 1
        else:
            break
    return streak

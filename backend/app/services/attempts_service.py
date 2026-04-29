"""Attempts: start, record answer, submit, get, list.

Exam-kind attempts: only MCQ papers are scorable, so we reject papers whose
`question_type != 'mcq'`. For now both admission-MCQ and HSC-MCQ papers use
the admission-MCQ table path (the FK on `attempt_answers.question_id` points
at `admission_mcq_questions` — see plan Follow-ups to make this polymorphic).

Drill-kind attempts: `DrillSpec.exam_type` picks the pool.
"""

import uuid
from datetime import datetime, timezone

from fastapi import HTTPException
from sqlalchemy import Integer, func, select
from sqlalchemy.dialects.postgresql import insert as pg_insert
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from ..config import get_settings
from ..api_schemas import (
    OptionOut,
    PublicMcqQuestionOut,
    QuizQuestionsOut,
    QuizReviewOut,
    ReviewMcqQuestionOut,
)
from ..models import (
    AdmissionMcqQuestion,
    Attempt,
    AttemptAnswer,
    ExamPaper,
    QuizStatus,
    User,
)
from .questions_service import _images_to_out
from ..schemas_user_data import (
    AdminAttemptDetail,
    AttemptAnswerRecord,
    AttemptBreakdown,
    AttemptDetail,
    AttemptResult,
    AttemptStartIn,
    AttemptStartOut,
    AttemptSummary,
    ChapterStat,
    SubjectStat,
)
from . import drill_service


async def _admission_mcq_question_ids_for_paper(
    session: AsyncSession, paper_id: uuid.UUID
) -> list[uuid.UUID]:
    rows = await session.execute(
        select(AdmissionMcqQuestion.id)
        .where(AdmissionMcqQuestion.paper_id == paper_id)
        .where(AdmissionMcqQuestion.correct_answer.is_not(None))
        .order_by(AdmissionMcqQuestion.created_at, AdmissionMcqQuestion.question_number)
    )
    return list(rows.scalars().all())


async def _admission_mcq_question_ids_for_subject(
    session: AsyncSession, *, subject: str
) -> list[uuid.UUID]:
    """Return question ids in syllabus order.

    Chapters cluster contiguously and follow the order defined in
    `chapters.yaml` (i.e. NCTB syllabus order), not alphabetical. Within a
    chapter, questions sort by created_at then question_number so the
    sequence is deterministic across attempts. Questions whose chapter
    isn't in the taxonomy (legacy / typo) sort to the very end so they
    don't disrupt the syllabus flow.
    """
    # Pull both id and chapter so we can sort in Python — SQL `CASE WHEN`
    # would also work but the question_ids array is small (≤ a few hundred
    # rows per subject) so the in-Python sort is fine and trivially clear.
    rows = await session.execute(
        select(AdmissionMcqQuestion.id, AdmissionMcqQuestion.chapter)
        .where(AdmissionMcqQuestion.subject == subject)
        .where(AdmissionMcqQuestion.correct_answer.is_not(None))
        .order_by(AdmissionMcqQuestion.created_at, AdmissionMcqQuestion.question_number)
    )
    pairs = list(rows.all())

    syllabus = get_settings().chapter_taxonomy.get(subject, [])
    # Position lookup. Anything not in the syllabus falls past the end so
    # it sorts after every known chapter; NULL chapter behaves the same.
    position: dict[str, int] = {ch: i for i, ch in enumerate(syllabus)}
    sentinel = len(syllabus)

    def sort_key(pair: tuple[uuid.UUID, str | None]) -> int:
        _id, chapter = pair
        if chapter is None:
            return sentinel
        return position.get(chapter, sentinel)

    pairs.sort(key=sort_key)
    return [p[0] for p in pairs]


async def _resolve_quiz_status(
    session: AsyncSession, *, subject: str, exam_type: str
) -> str:
    """Look up the publish status for a (subject, exam_type) quiz.

    Missing rows are treated as `draft` so admins create rows by publishing —
    they don't need to first seed every (subject, exam_type) combination.
    """
    row = await session.get(QuizStatus, (subject, exam_type))
    return row.status if row else "draft"


async def start_attempt(
    session: AsyncSession,
    *,
    user_id: uuid.UUID,
    body: AttemptStartIn,
    is_admin: bool = False,
) -> AttemptStartOut:
    if body.kind == "exam":
        paper = await session.get(ExamPaper, body.paper_id)
        if paper is None:
            raise HTTPException(404, "Exam paper not found")
        if paper.question_type != "mcq":
            raise HTTPException(
                400, "Exam attempts are only supported for MCQ papers in this version"
            )
        if paper.exam_type != "admission_test":
            # TODO(follow-up): extend attempt_answers.question_id to a
            # polymorphic reference so HSC MCQ exam attempts can land here too.
            raise HTTPException(
                400,
                "Exam attempts are currently limited to admission-test MCQ papers; "
                "HSC-MCQ exam attempts are not yet supported.",
            )
        question_ids = await _admission_mcq_question_ids_for_paper(session, paper.id)
        if not question_ids:
            raise HTTPException(404, "No scorable questions for this exam paper")
        paper_id = body.paper_id
        drill_subject = None
        drill_chapter = None
    elif body.kind == "drill":
        assert body.drill is not None
        if body.drill.exam_type != "admission_test":
            # Same Follow-up: HSC MCQ drill attempts need polymorphic FK.
            raise HTTPException(
                400,
                "HSC-board drill attempts are not yet supported; drill read-only via /drill still works.",
            )
        question_ids = await drill_service.sample_question_ids(
            session,
            exam_type=body.drill.exam_type,
            subject=body.drill.subject,
            chapter=body.drill.chapter,
            count=body.drill.count,
            subject_paper=body.drill.subject_paper,
        )
        if not question_ids:
            raise HTTPException(
                404,
                f"No questions found for subject={body.drill.subject} chapter={body.drill.chapter}",
            )
        paper_id = None
        drill_subject = body.drill.subject
        drill_chapter = body.drill.chapter
    else:
        # subject_quiz: every MCQ for the given (subject, exam_type) with a
        # known correct answer, in deterministic order. HSC MCQs are blocked
        # at the exam_type check below (the attempt_answers FK still targets
        # admission_mcq_questions only — see the Follow-up at top of file).
        assert body.subject is not None
        if body.exam_type != "admission_test":
            raise HTTPException(
                400,
                "HSC-board subject quizzes are not yet supported; "
                "the attempt_answers FK still targets admission_mcq_questions only.",
            )
        # Status gate: students can only start a quiz that's `published`.
        # Admins bypass the gate so they can preview drafts.
        if not is_admin:
            quiz_status = await _resolve_quiz_status(
                session, subject=body.subject, exam_type=body.exam_type
            )
            if quiz_status != "published":
                raise HTTPException(
                    403,
                    f"Quiz '{body.subject} ({body.exam_type})' is not published",
                )
        question_ids = await _admission_mcq_question_ids_for_subject(
            session, subject=body.subject
        )
        if not question_ids:
            raise HTTPException(
                404, f"No scorable questions found for subject={body.subject}"
            )
        paper_id = None
        drill_subject = body.subject
        drill_chapter = None

    attempt = Attempt(
        user_id=user_id,
        kind=body.kind,
        mode=body.mode,
        paper_id=paper_id,
        drill_subject=drill_subject,
        drill_chapter=drill_chapter,
        exam_type=body.exam_type,
        duration_sec=body.duration_sec,
        question_ids=question_ids,
        status="in_progress",
    )
    session.add(attempt)
    await session.flush()
    return AttemptStartOut(
        id=attempt.id,
        question_ids=attempt.question_ids,
        started_at=attempt.started_at,
    )


async def _load_attempt_for_user(
    session: AsyncSession, *, attempt_id: uuid.UUID, user_id: uuid.UUID
) -> Attempt:
    result = await session.execute(
        select(Attempt).where(Attempt.id == attempt_id, Attempt.user_id == user_id)
    )
    attempt = result.scalar_one_or_none()
    if attempt is None:
        raise HTTPException(404, "Attempt not found")
    return attempt


async def record_answer(
    session: AsyncSession,
    *,
    user_id: uuid.UUID,
    attempt_id: uuid.UUID,
    question_id: uuid.UUID,
    selected_label: str,
) -> tuple[bool, str | None]:
    attempt = await _load_attempt_for_user(
        session, attempt_id=attempt_id, user_id=user_id
    )
    if attempt.status != "in_progress":
        raise HTTPException(409, "Attempt is no longer in progress")
    if question_id not in attempt.question_ids:
        raise HTTPException(400, "Question not in attempt")

    question = await session.get(AdmissionMcqQuestion, question_id)
    if question is None:
        raise HTTPException(404, "Question not found")
    correct = question.correct_answer
    is_correct = (
        correct is not None
        and selected_label.strip().lower() == correct.strip().lower()
    )

    stmt = (
        pg_insert(AttemptAnswer)
        .values(
            attempt_id=attempt_id,
            question_id=question_id,
            selected_label=selected_label,
            is_correct=is_correct,
        )
        .on_conflict_do_update(
            constraint="uq_attempt_answers_attempt_question",
            set_={
                "selected_label": selected_label,
                "is_correct": is_correct,
                "answered_at": func.now(),
            },
        )
    )
    await session.execute(stmt)
    await session.commit()
    return is_correct, correct


async def submit_attempt(
    session: AsyncSession, *, user_id: uuid.UUID, attempt_id: uuid.UUID
) -> AttemptResult:
    # Lock the row to prevent double-submit races.
    result = await session.execute(
        select(Attempt)
        .where(Attempt.id == attempt_id, Attempt.user_id == user_id)
        .with_for_update()
    )
    attempt = result.scalar_one_or_none()
    if attempt is None:
        raise HTTPException(404, "Attempt not found")
    if attempt.status != "in_progress":
        raise HTTPException(409, "Attempt already submitted")

    now = datetime.now(timezone.utc)

    # Aggregate per-subject and per-chapter.
    agg_rows = await session.execute(
        select(
            AdmissionMcqQuestion.subject,
            AdmissionMcqQuestion.chapter,
            func.count(AttemptAnswer.id),
            func.sum(func.cast(AttemptAnswer.is_correct, Integer)),
        )
        .select_from(AttemptAnswer)
        .join(AdmissionMcqQuestion, AdmissionMcqQuestion.id == AttemptAnswer.question_id)
        .where(AttemptAnswer.attempt_id == attempt_id)
        .group_by(AdmissionMcqQuestion.subject, AdmissionMcqQuestion.chapter)
    )

    by_subject_map: dict[str, dict[str, int]] = {}
    by_chapter: list[ChapterStat] = []
    total_correct = 0
    total_answered = 0
    for subject, chapter, attempted, correct in agg_rows.all():
        attempted = int(attempted or 0)
        correct = int(correct or 0)
        total_answered += attempted
        total_correct += correct
        subj = subject or "unknown"
        chap = chapter or "unknown"
        bs = by_subject_map.setdefault(subj, {"attempted": 0, "correct": 0})
        bs["attempted"] += attempted
        bs["correct"] += correct
        accuracy = (correct / attempted) if attempted else 0.0
        by_chapter.append(
            ChapterStat(
                subject=subj,
                chapter=chap,
                attempted=attempted,
                correct=correct,
                accuracy=accuracy,
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

    total_questions = len(attempt.question_ids)
    elapsed_sec = int((now - attempt.started_at).total_seconds())

    attempt.status = "submitted"
    attempt.submitted_at = now
    attempt.score_correct = total_correct
    attempt.score_total = total_questions
    attempt.elapsed_sec = elapsed_sec

    await session.commit()

    return AttemptResult(
        id=attempt.id,
        score_correct=total_correct,
        score_total=total_questions,
        elapsed_sec=elapsed_sec,
        breakdown=AttemptBreakdown(by_subject=by_subject, by_chapter=by_chapter),
    )


async def list_attempts(
    session: AsyncSession,
    *,
    user_id: uuid.UUID,
    limit: int,
    offset: int,
) -> tuple[int, list[AttemptSummary]]:
    total = (
        await session.execute(
            select(func.count(Attempt.id)).where(Attempt.user_id == user_id)
        )
    ).scalar_one()
    rows = (
        await session.execute(
            select(Attempt)
            .where(Attempt.user_id == user_id)
            .order_by(Attempt.started_at.desc())
            .limit(limit)
            .offset(offset)
        )
    ).scalars().all()
    return total, [AttemptSummary.model_validate(r) for r in rows]


def _question_to_public(q: AdmissionMcqQuestion) -> PublicMcqQuestionOut:
    return PublicMcqQuestionOut(
        id=q.id,
        paper_id=q.paper_id,
        question_number=q.question_number,
        question_text=q.question_text,
        subject=q.subject,
        chapter=q.chapter,
        has_image=q.has_image,
        images=_images_to_out(q.images),
        options=[
            OptionOut(
                id=o.id,
                label=o.label,
                text=o.text,
                image_filename=o.image_filename,
            )
            for o in sorted(q.options, key=lambda x: x.display_order)
        ],
        university_name=q.university_name,
        exam_session=q.exam_session,
        exam_unit=q.exam_unit,
    )


def _question_to_review(
    q: AdmissionMcqQuestion,
    *,
    selected_label: str | None,
    is_correct: bool | None,
) -> ReviewMcqQuestionOut:
    return ReviewMcqQuestionOut(
        id=q.id,
        paper_id=q.paper_id,
        question_number=q.question_number,
        question_text=q.question_text,
        subject=q.subject,
        chapter=q.chapter,
        has_image=q.has_image,
        images=_images_to_out(q.images),
        options=[
            OptionOut(
                id=o.id,
                label=o.label,
                text=o.text,
                image_filename=o.image_filename,
            )
            for o in sorted(q.options, key=lambda x: x.display_order)
        ],
        correct_answer=q.correct_answer,
        solution=q.solution,
        gemini_solution=q.gemini_solution,
        selected_label=selected_label,
        is_correct=is_correct,
        university_name=q.university_name,
        exam_session=q.exam_session,
        exam_unit=q.exam_unit,
    )


async def get_attempt_questions(
    session: AsyncSession,
    *,
    user_id: uuid.UUID,
    attempt_id: uuid.UUID,
    page: int,
    page_size: int,
) -> QuizQuestionsOut:
    attempt = await _load_attempt_for_user(
        session, attempt_id=attempt_id, user_id=user_id
    )
    total = len(attempt.question_ids)
    start = (page - 1) * page_size
    end = start + page_size
    page_ids = attempt.question_ids[start:end]
    if not page_ids:
        return QuizQuestionsOut(total=total, page=page, page_size=page_size, items=[])

    rows = await session.execute(
        select(AdmissionMcqQuestion)
        .options(selectinload(AdmissionMcqQuestion.options))
        .where(AdmissionMcqQuestion.id.in_(page_ids))
    )
    by_id = {q.id: q for q in rows.scalars().all()}
    items = [
        _question_to_public(by_id[qid]) for qid in page_ids if qid in by_id
    ]
    return QuizQuestionsOut(
        total=total, page=page, page_size=page_size, items=items
    )


async def get_attempt_review(
    session: AsyncSession,
    *,
    user_id: uuid.UUID,
    attempt_id: uuid.UUID,
    page: int,
    page_size: int,
) -> QuizReviewOut:
    result = await session.execute(
        select(Attempt)
        .options(selectinload(Attempt.answers))
        .where(Attempt.id == attempt_id, Attempt.user_id == user_id)
    )
    attempt = result.scalar_one_or_none()
    if attempt is None:
        raise HTTPException(404, "Attempt not found")
    if attempt.status != "submitted":
        raise HTTPException(409, "Attempt has not been submitted yet")

    total = len(attempt.question_ids)
    start = (page - 1) * page_size
    end = start + page_size
    page_ids = attempt.question_ids[start:end]
    if not page_ids:
        return QuizReviewOut(total=total, page=page, page_size=page_size, items=[])

    answer_by_qid: dict[uuid.UUID, AttemptAnswer] = {
        a.question_id: a for a in attempt.answers
    }

    rows = await session.execute(
        select(AdmissionMcqQuestion)
        .options(selectinload(AdmissionMcqQuestion.options))
        .where(AdmissionMcqQuestion.id.in_(page_ids))
    )
    by_id = {q.id: q for q in rows.scalars().all()}

    items: list[ReviewMcqQuestionOut] = []
    for qid in page_ids:
        q = by_id.get(qid)
        if q is None:
            continue
        ans = answer_by_qid.get(qid)
        items.append(
            _question_to_review(
                q,
                selected_label=ans.selected_label if ans else None,
                is_correct=ans.is_correct if ans else None,
            )
        )
    return QuizReviewOut(
        total=total, page=page, page_size=page_size, items=items
    )


async def get_attempt(
    session: AsyncSession, *, user_id: uuid.UUID, attempt_id: uuid.UUID
) -> AttemptDetail:
    result = await session.execute(
        select(Attempt)
        .options(selectinload(Attempt.answers))
        .where(Attempt.id == attempt_id, Attempt.user_id == user_id)
    )
    attempt = result.scalar_one_or_none()
    if attempt is None:
        raise HTTPException(404, "Attempt not found")

    summary = AttemptSummary.model_validate(attempt).model_dump()
    return AttemptDetail(
        **summary,
        question_ids=attempt.question_ids,
        answers=[AttemptAnswerRecord.model_validate(a) for a in attempt.answers],
    )


# ---------------------------------------------------------------------------
# Admin overrides — same shape as the user-scoped reads above, no user_id
# filter. Call sites are expected to be wrapped by `require_admin` in the
# router; the service does not re-check.
# ---------------------------------------------------------------------------


async def get_attempt_admin(
    session: AsyncSession, *, attempt_id: uuid.UUID
) -> AdminAttemptDetail:
    # Joined-load the user so the drill-down header can show name + email
    # in one round-trip. Same pattern as the roster query.
    result = await session.execute(
        select(Attempt, User)
        .join(User, User.id == Attempt.user_id)
        .options(selectinload(Attempt.answers))
        .where(Attempt.id == attempt_id)
    )
    row = result.one_or_none()
    if row is None:
        raise HTTPException(404, "Attempt not found")
    attempt, user = row

    summary = AttemptSummary.model_validate(attempt).model_dump()
    return AdminAttemptDetail(
        **summary,
        question_ids=attempt.question_ids,
        answers=[AttemptAnswerRecord.model_validate(a) for a in attempt.answers],
        user_id=user.id,
        user_email=user.email,
        user_display_name=user.display_name,
    )


async def get_attempt_review_admin(
    session: AsyncSession,
    *,
    attempt_id: uuid.UUID,
    page: int,
    page_size: int,
) -> QuizReviewOut:
    """Admin variant of get_attempt_review — same body, no user scope.

    Unlike the student endpoint, this does NOT require `status='submitted'`.
    Admins should be able to inspect in-progress attempts (see partial
    answers); the answer set is whatever has been recorded so far.
    """
    result = await session.execute(
        select(Attempt)
        .options(selectinload(Attempt.answers))
        .where(Attempt.id == attempt_id)
    )
    attempt = result.scalar_one_or_none()
    if attempt is None:
        raise HTTPException(404, "Attempt not found")

    total = len(attempt.question_ids)
    start = (page - 1) * page_size
    end = start + page_size
    page_ids = attempt.question_ids[start:end]
    if not page_ids:
        return QuizReviewOut(total=total, page=page, page_size=page_size, items=[])

    answer_by_qid: dict[uuid.UUID, AttemptAnswer] = {
        a.question_id: a for a in attempt.answers
    }

    rows = await session.execute(
        select(AdmissionMcqQuestion)
        .options(selectinload(AdmissionMcqQuestion.options))
        .where(AdmissionMcqQuestion.id.in_(page_ids))
    )
    by_id = {q.id: q for q in rows.scalars().all()}

    items: list[ReviewMcqQuestionOut] = []
    for qid in page_ids:
        q = by_id.get(qid)
        if q is None:
            continue
        ans = answer_by_qid.get(qid)
        items.append(
            _question_to_review(
                q,
                selected_label=ans.selected_label if ans else None,
                is_correct=ans.is_correct if ans else None,
            )
        )
    return QuizReviewOut(total=total, page=page, page_size=page_size, items=items)

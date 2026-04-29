"""Exam paper listing and detail across all (exam_type, question_type) variants.

Listing is a union over the 4 question tables: the discriminators on
`exam_papers` say which child table holds the questions, and we dispatch the
COUNT / chapter-aggregation queries accordingly.
"""

import uuid
from typing import Any

from sqlalchemy import func, select, union_all
from sqlalchemy.ext.asyncio import AsyncSession

from ..api_schemas import ExamPaperDetail, ExamPaperSummary
from ..models import (
    AdmissionMcqQuestion,
    AdmissionWrittenQuestion,
    ExamPaper,
    HscMcqQuestion,
    HscWrittenQuestion,
)


# Map discriminator pair -> question model. Used to pick the right table for
# per-paper COUNT(*) + GROUP BY chapter queries.
_QUESTION_MODEL_FOR: dict[tuple[str, str], Any] = {
    ("admission_test", "mcq"): AdmissionMcqQuestion,
    ("admission_test", "written"): AdmissionWrittenQuestion,
    ("hsc_board", "mcq"): HscMcqQuestion,
    ("hsc_board", "written"): HscWrittenQuestion,
}


def _paper_to_summary(paper: ExamPaper, question_count: int, mismatch_count: int = 0) -> ExamPaperSummary:
    return ExamPaperSummary(
        id=paper.id,
        source_filename=paper.source_filename,
        exam_type=paper.exam_type,
        question_type=paper.question_type,
        university_name=paper.university_name,
        exam_session=paper.exam_session,
        exam_unit=paper.exam_unit,
        board_name=paper.board_name,
        exam_year=paper.exam_year,
        subject=paper.subject,
        subject_paper=paper.subject_paper,
        page_count=paper.page_count,
        question_count=question_count,
        has_source_pdf=bool(paper.source_pdf_path),
        created_at=paper.created_at.isoformat() if paper.created_at else None,
        answer_mismatch_count=mismatch_count,
    )


def _question_counts_subquery():
    """UNION ALL across all 4 question tables: (paper_id, count). Papers with
    zero questions don't appear — the outer LEFT JOIN handles those as 0."""
    parts = []
    for model in _QUESTION_MODEL_FOR.values():
        parts.append(
            select(
                model.paper_id.label("paper_id"),
                func.count(model.id).label("qc"),
            ).group_by(model.paper_id)
        )
    return union_all(*parts).subquery()


def _mismatch_counts_subquery():
    """UNION ALL across MCQ tables: count questions where correct_answer != gemini_correct_answer.
    Only includes MCQ tables since written questions don't have answer labels.
    Safely checks if columns exist before querying."""
    parts = []
    for (exam_type, question_type), model in _QUESTION_MODEL_FOR.items():
        if question_type == "mcq":
            # Check if model has both required attributes
            if not (hasattr(model, "correct_answer") and hasattr(model, "gemini_correct_answer")):
                continue
            try:
                parts.append(
                    select(
                        model.paper_id.label("paper_id"),
                        func.count(model.id).label("mc"),
                    ).where(
                        model.correct_answer.isnot(None),
                        model.gemini_correct_answer.isnot(None),
                        model.correct_answer != model.gemini_correct_answer,
                    ).group_by(model.paper_id)
                )
            except AttributeError:
                # Column doesn't exist in database yet, skip this table
                continue
    if not parts:
        return None
    return union_all(*parts).subquery()


async def list_papers(
    session: AsyncSession,
    *,
    exam_type: str | None,
    question_type: str | None,
    # Admission filters
    university: str | None,
    session_filter: str | None,
    unit: str | None,
    # HSC filters
    board: str | None,
    year: str | None,
    subject: str | None,
    subject_paper: str | None,
    # Free-text
    q: str | None,
    limit: int,
    offset: int,
) -> tuple[int, list[ExamPaperSummary]]:
    filters = []
    if exam_type:
        filters.append(ExamPaper.exam_type == exam_type)
    if question_type:
        filters.append(ExamPaper.question_type == question_type)
    if university:
        filters.append(ExamPaper.university_name.ilike(f"%{university}%"))
    if session_filter:
        filters.append(ExamPaper.exam_session == session_filter)
    if unit:
        filters.append(ExamPaper.exam_unit == unit)
    if board:
        filters.append(ExamPaper.board_name.ilike(f"%{board}%"))
    if year:
        filters.append(ExamPaper.exam_year == year)
    if subject:
        filters.append(ExamPaper.subject == subject)
    if subject_paper:
        filters.append(ExamPaper.subject_paper == subject_paper)
    if q:
        filters.append(
            (ExamPaper.source_filename.ilike(f"%{q}%"))
            | (ExamPaper.university_name.ilike(f"%{q}%"))
            | (ExamPaper.board_name.ilike(f"%{q}%"))
        )

    count_stmt = select(func.count()).select_from(ExamPaper)
    if filters:
        count_stmt = count_stmt.where(*filters)
    total = (await session.execute(count_stmt)).scalar_one()

    q_count = _question_counts_subquery()
    m_count = _mismatch_counts_subquery()
    
    stmt = (
        select(ExamPaper, func.coalesce(q_count.c.qc, 0), func.coalesce(m_count.c.mc, 0) if m_count is not None else 0)
        .join(q_count, q_count.c.paper_id == ExamPaper.id, isouter=True)
    )
    if m_count is not None:
        stmt = stmt.join(m_count, m_count.c.paper_id == ExamPaper.id, isouter=True)
    
    stmt = stmt.order_by(ExamPaper.created_at.desc()).limit(limit).offset(offset)
    if filters:
        stmt = stmt.where(*filters)

    rows = (await session.execute(stmt)).all()
    items = [_paper_to_summary(paper, int(qc), int(mc)) for paper, qc, mc in rows]
    return total, items


async def get_paper_detail(
    session: AsyncSession, *, paper_id: uuid.UUID
) -> ExamPaperDetail | None:
    paper = await session.get(ExamPaper, paper_id)
    if paper is None:
        return None

    model = _QUESTION_MODEL_FOR.get((paper.exam_type, paper.question_type))
    chapter_counts: dict[str, int] = {}
    total = 0
    mismatch_count = 0
    
    if model is not None and hasattr(model, "chapter"):
        chapter_rows = await session.execute(
            select(model.chapter, func.count(model.id))
            .where(model.paper_id == paper_id)
            .group_by(model.chapter)
        )
        for chapter, count in chapter_rows.all():
            key = chapter or "unknown"
            chapter_counts[key] = int(count)
            total += int(count)
    elif model is not None:
        # HSC written: no chapter column — just count rows.
        count = (
            await session.execute(
                select(func.count(model.id)).where(model.paper_id == paper_id)
            )
        ).scalar_one()
        total = int(count)
    
    # Calculate mismatch count for MCQ papers
    if model is not None and paper.question_type == "mcq" and hasattr(model, "correct_answer") and hasattr(model, "gemini_correct_answer"):
        mismatch = (
            await session.execute(
                select(func.count(model.id))
                .where(
                    model.paper_id == paper_id,
                    model.correct_answer.isnot(None),
                    model.gemini_correct_answer.isnot(None),
                    model.correct_answer != model.gemini_correct_answer,
                )
            )
        ).scalar_one()
        mismatch_count = int(mismatch)

    summary = _paper_to_summary(paper, total, mismatch_count)
    return ExamPaperDetail(**summary.model_dump(), chapter_counts=chapter_counts)

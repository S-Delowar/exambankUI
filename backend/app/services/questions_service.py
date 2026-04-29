"""Unified question listing across the 4 child tables.

Callers pass `(exam_type, question_type)` to pick the right table. The service
returns the matching Pydantic response model (AdmissionMcqQuestionOut,
AdmissionWrittenQuestionOut, HscMcqQuestionOut, HscWrittenQuestionOut) so the
router doesn't have to know about model shapes.
"""

import uuid
from typing import Any

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from ..api_schemas import (
    AdmissionMcqQuestionOut,
    AdmissionWrittenQuestionOut,
    HscMcqQuestionOut,
    HscWrittenQuestionOut,
    HscWrittenSubpartOut,
    OptionOut,
    QuestionImageOut,
)
from ..models import (
    AdmissionMcqQuestion,
    AdmissionWrittenQuestion,
    ExamPaper,
    HscMcqQuestion,
    HscWrittenQuestion,
    HscWrittenSubpart,
)


_QUESTION_MODEL_FOR: dict[tuple[str, str], Any] = {
    ("admission_test", "mcq"): AdmissionMcqQuestion,
    ("admission_test", "written"): AdmissionWrittenQuestion,
    ("hsc_board", "mcq"): HscMcqQuestion,
    ("hsc_board", "written"): HscWrittenQuestion,
}


# ---------------------------------------------------------------------------
# Converters: model row -> response schema
# ---------------------------------------------------------------------------


def _images_to_out(raw: Any) -> list[QuestionImageOut]:
    """Convert the JSONB `images` column (list-of-dicts or None) to the
    response model list. Tolerates missing keys so legacy rows (where the
    column is NULL) and any partially-populated entries still render."""
    if not raw:
        return []
    out: list[QuestionImageOut] = []
    for item in raw:
        if not isinstance(item, dict):
            continue
        box = item.get("box_2d") or []
        if not isinstance(box, list):
            box = list(box) if box else []
        out.append(
            QuestionImageOut(
                id=str(item.get("id") or ""),
                page_index=int(item.get("page_index") or 0),
                box_2d=[int(v) for v in box] if len(box) == 4 else [0, 0, 0, 0],
                label=item.get("label"),
                kind=str(item.get("kind") or "diagram"),
                filename=item.get("filename"),
            )
        )
    return out


def admission_mcq_to_out(q: AdmissionMcqQuestion) -> AdmissionMcqQuestionOut:
    return AdmissionMcqQuestionOut(
        id=q.id,
        paper_id=q.paper_id,
        question_number=q.question_number,
        question_text=q.question_text,
        university_name=q.university_name,
        exam_session=q.exam_session,
        exam_unit=q.exam_unit,
        subject=q.subject,
        chapter=q.chapter,
        correct_answer=q.correct_answer,
        solution=q.solution,
        solution_status=q.solution_status,
        has_image=q.has_image,
        images=_images_to_out(q.images),
        options=[
            OptionOut(id=o.id, label=o.label, text=o.text, image_filename=o.image_filename)
            for o in q.options
        ],
        gemini_solution=q.gemini_solution,
        gemini_correct_answer=q.gemini_correct_answer,
    )


def admission_written_to_out(q: AdmissionWrittenQuestion) -> AdmissionWrittenQuestionOut:
    return AdmissionWrittenQuestionOut(
        id=q.id,
        paper_id=q.paper_id,
        question_number=q.question_number,
        question_text=q.question_text,
        university_name=q.university_name,
        exam_session=q.exam_session,
        exam_unit=q.exam_unit,
        subject=q.subject,
        chapter=q.chapter,
        solution=q.solution,
        solution_status=q.solution_status,
        has_image=q.has_image,
        images=_images_to_out(q.images),
        gemini_solution=q.gemini_solution,
        gemini_correct_answer=q.gemini_correct_answer,
    )


def hsc_mcq_to_out(q: HscMcqQuestion) -> HscMcqQuestionOut:
    return HscMcqQuestionOut(
        id=q.id,
        paper_id=q.paper_id,
        question_number=q.question_number,
        question_text=q.question_text,
        board_name=q.board_name,
        exam_year=q.exam_year,
        subject=q.subject,
        subject_paper=q.subject_paper,
        chapter=q.chapter,
        correct_answer=q.correct_answer,
        solution=q.solution,
        solution_status=q.solution_status,
        has_image=q.has_image,
        images=_images_to_out(q.images),
        options=[
            OptionOut(id=o.id, label=o.label, text=o.text, image_filename=o.image_filename)
            for o in q.options
        ],
        gemini_solution=q.gemini_solution,
        gemini_correct_answer=q.gemini_correct_answer,
    )


def hsc_written_subpart_to_out(sp: HscWrittenSubpart) -> HscWrittenSubpartOut:
    return HscWrittenSubpartOut(
        id=sp.id,
        label=sp.label,
        marks=sp.marks,
        text=sp.text,
        solution=sp.solution,
        solution_status=sp.solution_status,
        has_image=sp.has_image,
        gemini_solution=sp.gemini_solution,
        gemini_correct_answer=sp.gemini_correct_answer,
    )


def hsc_written_to_out(q: HscWrittenQuestion) -> HscWrittenQuestionOut:
    return HscWrittenQuestionOut(
        id=q.id,
        paper_id=q.paper_id,
        question_number=q.question_number,
        board_name=q.board_name,
        exam_year=q.exam_year,
        subject=q.subject,
        subject_paper=q.subject_paper,
        uddipak_text=q.uddipak_text,
        uddipak_has_image=q.uddipak_has_image,
        images=_images_to_out(q.images),
        sub_parts=[hsc_written_subpart_to_out(sp) for sp in q.sub_parts],
    )


def _to_out(model: Any, row: Any) -> Any:
    if model is AdmissionMcqQuestion:
        return admission_mcq_to_out(row)
    if model is AdmissionWrittenQuestion:
        return admission_written_to_out(row)
    if model is HscMcqQuestion:
        return hsc_mcq_to_out(row)
    if model is HscWrittenQuestion:
        return hsc_written_to_out(row)
    raise ValueError(f"Unknown model {model!r}")


# ---------------------------------------------------------------------------
# Resolve which model to query
# ---------------------------------------------------------------------------


async def _resolve_model(
    session: AsyncSession,
    *,
    exam_type: str | None,
    question_type: str | None,
    paper_id: uuid.UUID | None,
) -> Any:
    """If exam_type+question_type are given explicitly, use those. Otherwise
    look them up from the paper row (callers that only know the paper_id
    don't have to repeat the discriminators).
    """
    if exam_type and question_type:
        key = (exam_type, question_type)
        if key not in _QUESTION_MODEL_FOR:
            raise ValueError(f"Unknown (exam_type, question_type): {key}")
        return _QUESTION_MODEL_FOR[key]

    if paper_id is None:
        raise ValueError(
            "Either (exam_type, question_type) must be passed, or paper_id must be given so we can look them up."
        )

    paper = await session.get(ExamPaper, paper_id)
    if paper is None:
        return None
    return _QUESTION_MODEL_FOR.get((paper.exam_type, paper.question_type))


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------


async def list_questions(
    session: AsyncSession,
    *,
    paper_id: uuid.UUID | None,
    exam_type: str | None,
    question_type: str | None,
    subject: str | None,
    chapter: str | None,
    has_image: bool | None,
    solution_status: str | None,
    limit: int,
    offset: int,
) -> tuple[int, list[Any]]:
    model = await _resolve_model(
        session, exam_type=exam_type, question_type=question_type, paper_id=paper_id
    )
    if model is None:
        return 0, []

    filters = []
    if paper_id is not None:
        filters.append(model.paper_id == paper_id)
    if subject is not None and hasattr(model, "subject"):
        filters.append(model.subject == subject)
    if chapter is not None and hasattr(model, "chapter"):
        filters.append(model.chapter == chapter)
    if has_image is not None and hasattr(model, "has_image"):
        filters.append(model.has_image == has_image)
    if solution_status is not None and hasattr(model, "solution_status"):
        filters.append(model.solution_status == solution_status)

    count_stmt = select(func.count()).select_from(model)
    if filters:
        count_stmt = count_stmt.where(*filters)
    total = (await session.execute(count_stmt)).scalar_one()

    stmt = select(model).order_by(model.created_at, model.question_number)
    if hasattr(model, "options"):
        stmt = stmt.options(selectinload(model.options))
    if hasattr(model, "sub_parts"):
        stmt = stmt.options(selectinload(model.sub_parts))
    if filters:
        stmt = stmt.where(*filters)
    stmt = stmt.limit(limit).offset(offset)

    rows = (await session.execute(stmt)).scalars().all()
    return int(total), [_to_out(model, r) for r in rows]


async def get_question(
    session: AsyncSession,
    *,
    question_id: uuid.UUID,
    exam_type: str,
    question_type: str,
) -> Any | None:
    model = _QUESTION_MODEL_FOR.get((exam_type, question_type))
    if model is None:
        return None
    stmt = select(model).where(model.id == question_id)
    if hasattr(model, "options"):
        stmt = stmt.options(selectinload(model.options))
    if hasattr(model, "sub_parts"):
        stmt = stmt.options(selectinload(model.sub_parts))
    row = (await session.execute(stmt)).scalar_one_or_none()
    if row is None:
        return None
    return _to_out(model, row)

"""Reviewer edit/delete operations across all 4 question tables.

Each function takes the (exam_type, question_type) discriminator pair so one
set of endpoints can serve every variant. Updates are field-by-field — any
field omitted from the patch body is left untouched.

Deleting a question cascades to its child rows (options / subparts) via the
FK `ondelete=CASCADE` declared on the models.
"""

import os
import re
import uuid
from pathlib import Path
from typing import Any

from fastapi import HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from ..config import get_settings
from ..models import (
    AdmissionMcqOption,
    AdmissionMcqQuestion,
    AdmissionWrittenQuestion,
    ExamPaper,
    HscMcqOption,
    HscMcqQuestion,
    HscWrittenQuestion,
    HscWrittenSubpart,
)
from . import questions_service


_QUESTION_MODEL_FOR: dict[tuple[str, str], Any] = {
    ("admission_test", "mcq"): AdmissionMcqQuestion,
    ("admission_test", "written"): AdmissionWrittenQuestion,
    ("hsc_board", "mcq"): HscMcqQuestion,
    ("hsc_board", "written"): HscWrittenQuestion,
}


# Fields a reviewer can edit per question model. Everything else (id,
# paper_id, created_at, has_image, solution_status) is system-managed.
_EDITABLE_QUESTION_FIELDS: dict[Any, frozenset[str]] = {
    AdmissionMcqQuestion: frozenset(
        {
            "question_number",
            "question_text",
            "university_name",
            "exam_session",
            "exam_unit",
            "subject",
            "chapter",
            "correct_answer",
            "solution",
        }
    ),
    AdmissionWrittenQuestion: frozenset(
        {
            "question_number",
            "question_text",
            "university_name",
            "exam_session",
            "exam_unit",
            "subject",
            "chapter",
            "solution",
        }
    ),
    HscMcqQuestion: frozenset(
        {
            "question_number",
            "question_text",
            "board_name",
            "exam_year",
            "subject",
            "subject_paper",
            "chapter",
            "correct_answer",
            "solution",
        }
    ),
    HscWrittenQuestion: frozenset(
        {
            "question_number",
            "board_name",
            "exam_year",
            "subject",
            "subject_paper",
            "uddipak_text",
            "uddipak_has_image",
        }
    ),
}


_OPTION_MODEL_FOR: dict[str, Any] = {
    "admission_test": AdmissionMcqOption,
    "hsc_board": HscMcqOption,
}


def _resolve_question_model(exam_type: str, question_type: str) -> Any:
    model = _QUESTION_MODEL_FOR.get((exam_type, question_type))
    if model is None:
        raise HTTPException(
            400, f"Unknown (exam_type, question_type): ({exam_type}, {question_type})"
        )
    return model


async def _load_question(
    session: AsyncSession, model: Any, question_id: uuid.UUID
) -> Any:
    stmt = select(model).where(model.id == question_id)
    if hasattr(model, "options"):
        stmt = stmt.options(selectinload(model.options))
    if hasattr(model, "sub_parts"):
        stmt = stmt.options(selectinload(model.sub_parts))
    row = (await session.execute(stmt)).scalar_one_or_none()
    if row is None:
        raise HTTPException(404, "Question not found")
    return row


def _validate_field(field: str, value: Any) -> Any:
    """Normalize + sanity-check a patch value. Raises HTTPException(422) with a
    human-readable detail on failure. `None` is allowed for every field (the
    reviewer clearing a value); type checks apply only to non-None values."""
    if value is None:
        return None
    if field == "display_order":
        if not isinstance(value, int) or isinstance(value, bool) or value < 0:
            raise HTTPException(422, "display_order must be a non-negative integer")
        return value
    if field == "uddipak_has_image":
        if not isinstance(value, bool):
            raise HTTPException(422, "uddipak_has_image must be a boolean")
        return value
    # All remaining editable fields are free-form strings with light bounds.
    if not isinstance(value, str):
        raise HTTPException(422, f"{field} must be a string")
    stripped = value.strip()
    if field == "label":
        if not stripped:
            raise HTTPException(422, "label cannot be empty")
        if len(stripped) > 16:
            raise HTTPException(422, "label must be 16 characters or fewer")
    elif field == "correct_answer":
        if len(stripped) > 16:
            raise HTTPException(422, "correct_answer must be 16 characters or fewer")
    elif field == "question_number":
        if not stripped:
            raise HTTPException(422, "question_number cannot be empty")
        if len(stripped) > 32:
            raise HTTPException(422, "question_number must be 32 characters or fewer")
    elif field == "exam_year":
        if stripped and not stripped.isdigit():
            raise HTTPException(422, "exam_year must be numeric")
    # Fall through: accept any string (text / solution / chapter / etc.).
    return value


def _apply_patch(obj: Any, patch: dict[str, Any], allowed: frozenset[str]) -> None:
    unknown = [k for k in patch.keys() if k not in allowed]
    if unknown:
        raise HTTPException(400, f"Field(s) not editable: {', '.join(sorted(unknown))}")
    for key, value in patch.items():
        setattr(obj, key, _validate_field(key, value))


# ---------------------------------------------------------------------------
# Questions
# ---------------------------------------------------------------------------


async def update_question(
    session: AsyncSession,
    *,
    exam_type: str,
    question_type: str,
    question_id: uuid.UUID,
    patch: dict[str, Any],
) -> Any:
    model = _resolve_question_model(exam_type, question_type)
    question = await _load_question(session, model, question_id)
    _apply_patch(question, patch, _EDITABLE_QUESTION_FIELDS[model])
    await session.commit()
    await session.refresh(question)
    return _to_out(model, session, question)


async def delete_question(
    session: AsyncSession,
    *,
    exam_type: str,
    question_type: str,
    question_id: uuid.UUID,
) -> None:
    model = _resolve_question_model(exam_type, question_type)
    question = await _load_question(session, model, question_id)
    await session.delete(question)
    await session.commit()


def _to_out(model: Any, _session: AsyncSession, row: Any) -> Any:
    if model is AdmissionMcqQuestion:
        return questions_service.admission_mcq_to_out(row)
    if model is AdmissionWrittenQuestion:
        return questions_service.admission_written_to_out(row)
    if model is HscMcqQuestion:
        return questions_service.hsc_mcq_to_out(row)
    if model is HscWrittenQuestion:
        return questions_service.hsc_written_to_out(row)
    raise ValueError(f"No converter for {model!r}")


# ---------------------------------------------------------------------------
# Options (MCQ only)
# ---------------------------------------------------------------------------


_EDITABLE_OPTION_FIELDS = frozenset({"label", "text", "display_order"})


async def update_option(
    session: AsyncSession,
    *,
    exam_type: str,
    option_id: uuid.UUID,
    patch: dict[str, Any],
) -> dict[str, Any]:
    model = _OPTION_MODEL_FOR.get(exam_type)
    if model is None:
        raise HTTPException(400, f"Options are MCQ-only; exam_type={exam_type!r} invalid")
    opt = await session.get(model, option_id)
    if opt is None:
        raise HTTPException(404, "Option not found")
    _apply_patch(opt, patch, _EDITABLE_OPTION_FIELDS)
    await session.commit()
    await session.refresh(opt)
    return {
        "id": str(opt.id),
        "question_id": str(opt.question_id),
        "label": opt.label,
        "text": opt.text,
        "display_order": opt.display_order,
    }


async def delete_option(
    session: AsyncSession,
    *,
    exam_type: str,
    option_id: uuid.UUID,
) -> None:
    model = _OPTION_MODEL_FOR.get(exam_type)
    if model is None:
        raise HTTPException(400, f"Options are MCQ-only; exam_type={exam_type!r} invalid")
    opt = await session.get(model, option_id)
    if opt is None:
        raise HTTPException(404, "Option not found")
    await session.delete(opt)
    await session.commit()


async def create_option(
    session: AsyncSession,
    *,
    exam_type: str,
    question_id: uuid.UUID,
    label: str,
    text: str,
) -> dict[str, Any]:
    """Append a new option to an MCQ question. `display_order` is auto-set to
    (current max + 1) so reviewers don't have to compute it."""
    question_model = _QUESTION_MODEL_FOR.get((exam_type, "mcq"))
    opt_model = _OPTION_MODEL_FOR.get(exam_type)
    if question_model is None or opt_model is None:
        raise HTTPException(400, f"Invalid exam_type for options: {exam_type!r}")
    label = _validate_field("label", label)
    if not isinstance(text, str) or not text.strip():
        raise HTTPException(422, "option text cannot be empty")
    question = await session.get(question_model, question_id)
    if question is None:
        raise HTTPException(404, "Question not found")

    existing_orders = (
        await session.execute(
            select(opt_model.display_order).where(opt_model.question_id == question_id)
        )
    ).scalars().all()
    next_order = (max(existing_orders) + 1) if existing_orders else 0

    opt = opt_model(
        question_id=question_id,
        label=label,
        text=text,
        display_order=next_order,
    )
    session.add(opt)
    await session.commit()
    await session.refresh(opt)
    return {
        "id": str(opt.id),
        "question_id": str(opt.question_id),
        "label": opt.label,
        "text": opt.text,
        "display_order": opt.display_order,
    }


# ---------------------------------------------------------------------------
# HSC written sub-parts
# ---------------------------------------------------------------------------


_EDITABLE_SUBPART_FIELDS = frozenset({"text", "solution"})


async def update_subpart(
    session: AsyncSession,
    *,
    subpart_id: uuid.UUID,
    patch: dict[str, Any],
) -> dict[str, Any]:
    sp = await session.get(HscWrittenSubpart, subpart_id)
    if sp is None:
        raise HTTPException(404, "Sub-part not found")
    _apply_patch(sp, patch, _EDITABLE_SUBPART_FIELDS)
    await session.commit()
    await session.refresh(sp)
    return {
        "id": str(sp.id),
        "question_id": str(sp.question_id),
        "label": sp.label,
        "marks": sp.marks,
        "text": sp.text,
        "solution": sp.solution,
        "solution_status": sp.solution_status,
        "has_image": sp.has_image,
    }


# ---------------------------------------------------------------------------
# Images (replace-on-disk + delete)
# ---------------------------------------------------------------------------

# PNG magic bytes — first 8 bytes of every valid PNG file.
_PNG_MAGIC = b"\x89PNG\r\n\x1a\n"
# Cap upload size to keep crops sane. PDFs at 300 DPI rarely produce > 5 MB
# crops; anything bigger is suspicious or a re-export of the whole page.
_MAX_PNG_BYTES = 5 * 1024 * 1024


async def _resolve_image_path(
    session: AsyncSession, paper_id: uuid.UUID, filename: str
) -> Path:
    """Mirror the resolution in routers/exams.py:96-129 — `{images_path}/
    {paper_stem}/{filename}` — with the same path-traversal guard."""
    if "/" in filename or "\\" in filename or ".." in filename:
        raise HTTPException(400, "Invalid filename")
    paper = await session.get(ExamPaper, paper_id)
    if paper is None:
        raise HTTPException(404, "Exam paper not found")
    if not paper.output_json_path:
        raise HTTPException(404, "No extraction JSON stored for this paper")
    stem = Path(paper.output_json_path).stem
    return get_settings().images_path / stem / filename


def _find_image(images: list | None, image_id: str) -> dict | None:
    if not images:
        return None
    for item in images:
        if isinstance(item, dict) and str(item.get("id") or "") == image_id:
            return item
    return None


def _strip_image_token(text: str | None, image_id: str) -> str | None:
    """Remove `[IMAGE_N]` (and bare `[IMAGE]` when image_id is `IMAGE`) from
    `text`. Matches the regex in MathText.tsx — only the trailing-digits form
    is targeted, so other images on the same question survive."""
    if not text:
        return text
    suffix = image_id.removeprefix("IMAGE_")
    if suffix == "IMAGE" or suffix == "":
        token_re = re.compile(r"\[IMAGE\]")
    else:
        token_re = re.compile(rf"\[IMAGE_{re.escape(suffix)}\]")
    return token_re.sub("", text)


async def replace_image(
    session: AsyncSession,
    *,
    exam_type: str,
    question_type: str,
    question_id: uuid.UUID,
    image_id: str,
    png_bytes: bytes,
) -> dict[str, Any]:
    """Overwrite the on-disk PNG for an existing image. Filename and DB
    metadata (box_2d, page_index) are preserved; only the file contents
    change. Returns the unchanged QuestionImage record so the client can
    re-render with cache-bust."""
    if len(png_bytes) > _MAX_PNG_BYTES:
        raise HTTPException(413, f"Image must be ≤ {_MAX_PNG_BYTES // (1024 * 1024)} MB")
    if not png_bytes.startswith(_PNG_MAGIC):
        raise HTTPException(415, "Image must be a PNG (bad magic bytes)")

    model = _resolve_question_model(exam_type, question_type)
    question = await _load_question(session, model, question_id)
    image = _find_image(question.images, image_id)
    if image is None or not image.get("filename"):
        raise HTTPException(404, "Image not found on this question")

    target = await _resolve_image_path(session, question.paper_id, image["filename"])
    target.parent.mkdir(parents=True, exist_ok=True)
    tmp = target.with_suffix(target.suffix + ".tmp")
    tmp.write_bytes(png_bytes)
    os.replace(tmp, target)

    return {
        "id": str(image.get("id") or ""),
        "page_index": int(image.get("page_index") or 0),
        "box_2d": list(image.get("box_2d") or [0, 0, 0, 0]),
        "label": image.get("label"),
        "kind": str(image.get("kind") or "diagram"),
        "filename": image.get("filename"),
    }


async def delete_image(
    session: AsyncSession,
    *,
    exam_type: str,
    question_type: str,
    question_id: uuid.UUID,
    image_id: str,
) -> None:
    """Remove an image entirely:
      1. Strip the matching `[IMAGE_N]` token from question_text /
         uddipak_text / option texts / subpart texts.
      2. Delete the PNG from disk (best-effort).
      3. Drop the entry from the JSONB images list.
      4. Recompute uddipak_has_image for HSC written (has_image is a
         generated column elsewhere and updates itself).
    """
    model = _resolve_question_model(exam_type, question_type)
    question = await _load_question(session, model, question_id)
    image = _find_image(question.images, image_id)
    if image is None:
        raise HTTPException(404, "Image not found on this question")

    # Strip tokens from every text field on the question + children.
    if hasattr(question, "question_text"):
        question.question_text = _strip_image_token(question.question_text, image_id)
    if hasattr(question, "uddipak_text"):
        question.uddipak_text = _strip_image_token(question.uddipak_text, image_id)
    if hasattr(question, "options"):
        for opt in question.options:
            stripped = _strip_image_token(opt.text, image_id)
            if stripped is not None:
                opt.text = stripped
    if hasattr(question, "sub_parts"):
        for sp in question.sub_parts:
            stripped = _strip_image_token(sp.text, image_id)
            if stripped is not None:
                sp.text = stripped

    # Reassign a new list so SQLAlchemy flags the JSONB column as dirty.
    question.images = [
        item for item in (question.images or [])
        if not (isinstance(item, dict) and str(item.get("id") or "") == image_id)
    ] or None

    # Recompute uddipak_has_image (plain bool, not a generated column).
    if isinstance(question, HscWrittenQuestion):
        question.uddipak_has_image = bool(
            question.uddipak_text and "[IMAGE" in question.uddipak_text
        )

    # Best-effort file removal — a missing file is fine (race / already gone).
    filename = image.get("filename")
    if filename:
        try:
            target = await _resolve_image_path(session, question.paper_id, filename)
            target.unlink(missing_ok=True)
        except HTTPException:
            # _resolve_image_path raises on bad filename / missing paper —
            # the DB row should still be removed in that case.
            pass

    await session.commit()

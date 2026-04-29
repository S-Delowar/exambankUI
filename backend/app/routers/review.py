"""Reviewer edit/delete endpoints.

All routes require `exam_type` + `question_type` query params so the handler
can dispatch to the right child table. Request bodies are plain dicts — the
service layer validates field names against the per-model allow-list.

Routes
------
PATCH  /review/questions/{question_id}    ?exam_type=...&question_type=...
DELETE /review/questions/{question_id}    ?exam_type=...&question_type=...

PATCH  /review/options/{option_id}        ?exam_type=...
DELETE /review/options/{option_id}        ?exam_type=...
POST   /review/questions/{question_id}/options   ?exam_type=...   body={label,text}

PATCH  /review/subparts/{subpart_id}       (HSC written only)
"""

import uuid

from fastapi import APIRouter, Body, Depends, File, Query, UploadFile
from sqlalchemy.ext.asyncio import AsyncSession

from ..config import get_settings
from ..database import get_session
from ..deps import require_admin
from ..services import review_service

router = APIRouter(
    prefix="/review",
    tags=["review"],
    dependencies=[Depends(require_admin)],
)


# ---- Chapter taxonomy (read-only) -----------------------------------------


@router.get("/taxonomy/chapters")
async def get_chapter_taxonomy() -> dict[str, list[str]]:
    """Flat {subject: [chapter, ...]} map used by the reviewer's chapter
    picker. Same source as the extraction prompt so reviewer-entered chapters
    stay in sync with what Gemini is told is valid."""
    return get_settings().chapter_taxonomy


# ---- Questions -------------------------------------------------------------


@router.patch("/questions/{question_id}")
async def patch_question(
    question_id: uuid.UUID,
    exam_type: str = Query(...),
    question_type: str = Query(...),
    patch: dict = Body(...),
    session: AsyncSession = Depends(get_session),
) -> dict:
    out = await review_service.update_question(
        session,
        exam_type=exam_type,
        question_type=question_type,
        question_id=question_id,
        patch=patch,
    )
    return out.model_dump()


@router.delete("/questions/{question_id}", status_code=204)
async def delete_question(
    question_id: uuid.UUID,
    exam_type: str = Query(...),
    question_type: str = Query(...),
    session: AsyncSession = Depends(get_session),
) -> None:
    await review_service.delete_question(
        session,
        exam_type=exam_type,
        question_type=question_type,
        question_id=question_id,
    )


# ---- Options (MCQ only) ----------------------------------------------------


@router.patch("/options/{option_id}")
async def patch_option(
    option_id: uuid.UUID,
    exam_type: str = Query(...),
    patch: dict = Body(...),
    session: AsyncSession = Depends(get_session),
) -> dict:
    return await review_service.update_option(
        session, exam_type=exam_type, option_id=option_id, patch=patch
    )


@router.delete("/options/{option_id}", status_code=204)
async def delete_option(
    option_id: uuid.UUID,
    exam_type: str = Query(...),
    session: AsyncSession = Depends(get_session),
) -> None:
    await review_service.delete_option(
        session, exam_type=exam_type, option_id=option_id
    )


@router.post("/questions/{question_id}/options", status_code=201)
async def create_option(
    question_id: uuid.UUID,
    exam_type: str = Query(...),
    body: dict = Body(..., examples=[{"label": "E", "text": "new option"}]),
    session: AsyncSession = Depends(get_session),
) -> dict:
    return await review_service.create_option(
        session,
        exam_type=exam_type,
        question_id=question_id,
        label=body["label"],
        text=body["text"],
    )


# ---- HSC written sub-parts -------------------------------------------------


@router.patch("/subparts/{subpart_id}")
async def patch_subpart(
    subpart_id: uuid.UUID,
    patch: dict = Body(...),
    session: AsyncSession = Depends(get_session),
) -> dict:
    return await review_service.update_subpart(
        session, subpart_id=subpart_id, patch=patch
    )


# ---- Images (replace-on-disk + delete) -------------------------------------


@router.put("/questions/{question_id}/images/{image_id}")
async def replace_question_image(
    question_id: uuid.UUID,
    image_id: str,
    exam_type: str = Query(...),
    question_type: str = Query(...),
    file: UploadFile = File(...),
    session: AsyncSession = Depends(get_session),
) -> dict:
    """Overwrite an image's PNG file in place. The DB record (filename,
    box_2d, page_index) is preserved; only the file bytes change."""
    return await review_service.replace_image(
        session,
        exam_type=exam_type,
        question_type=question_type,
        question_id=question_id,
        image_id=image_id,
        png_bytes=await file.read(),
    )


@router.delete("/questions/{question_id}/images/{image_id}", status_code=204)
async def delete_question_image(
    question_id: uuid.UUID,
    image_id: str,
    exam_type: str = Query(...),
    question_type: str = Query(...),
    session: AsyncSession = Depends(get_session),
) -> None:
    """Remove an image from a question — strips the `[IMAGE_N]` token from
    text fields, removes the JSONB entry, and best-effort deletes the file."""
    await review_service.delete_image(
        session,
        exam_type=exam_type,
        question_type=question_type,
        question_id=question_id,
        image_id=image_id,
    )

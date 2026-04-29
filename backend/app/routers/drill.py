"""GET /drill: random-sample MCQs for practice.

Requires `exam_type` — admission drill reads admission_mcq_questions; HSC
drill reads hsc_mcq_questions. HSC drill optionally takes `subject_paper` to
scope the chapter to a specific paper (1 or 2).
"""

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession

from ..database import get_session
from ..services import drill_service

router = APIRouter(prefix="/drill", tags=["drill"])


@router.get("")
async def get_drill(
    exam_type: str = Query(..., description="'admission_test' or 'hsc_board'"),
    subject: str = Query(...),
    chapter: str = Query(...),
    subject_paper: str | None = Query(
        None, description="HSC only: '1' or '2' when drilling a paper-split subject"
    ),
    count: int = Query(10, ge=5, le=100),
    session: AsyncSession = Depends(get_session),
) -> dict:
    if exam_type not in ("admission_test", "hsc_board"):
        raise HTTPException(422, "exam_type must be 'admission_test' or 'hsc_board'")
    if exam_type == "admission_test" and subject_paper is not None:
        raise HTTPException(
            400, "subject_paper is only valid for exam_type=hsc_board"
        )

    items = await drill_service.sample_questions(
        session,
        exam_type=exam_type,
        subject=subject,
        chapter=chapter,
        count=count,
        subject_paper=subject_paper,
    )
    return {"items": [i.model_dump() for i in items]}

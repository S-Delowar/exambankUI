"""GET /questions and GET /questions/{id}.

The new list endpoint takes optional `exam_type` + `question_type` to pick the
child table. If `paper_id` is given, the discriminators can be inferred from
the paper — the client doesn't need to repeat them.

Response shape varies by type: Admission MCQ + HSC MCQ carry options;
Admission Written has a flat stem; HSC Written carries `uddipak_text` +
`sub_parts`. FastAPI serialises whichever concrete model the service returns.
"""

import uuid
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession

from ..database import get_session
from ..services import questions_service

router = APIRouter(prefix="/questions", tags=["questions"])


@router.get("")
async def list_questions(
    paper_id: Optional[uuid.UUID] = Query(None),
    exam_type: Optional[str] = Query(None),
    question_type: Optional[str] = Query(None),
    subject: Optional[str] = Query(None),
    chapter: Optional[str] = Query(None),
    has_image: Optional[bool] = Query(None),
    solution_status: Optional[str] = Query(None),
    limit: int = Query(50, ge=1, le=500),
    offset: int = Query(0, ge=0),
    session: AsyncSession = Depends(get_session),
) -> dict:
    if paper_id is None and not (exam_type and question_type):
        raise HTTPException(
            400,
            "Either paper_id or both (exam_type, question_type) are required.",
        )
    try:
        total, items = await questions_service.list_questions(
            session,
            paper_id=paper_id,
            exam_type=exam_type,
            question_type=question_type,
            subject=subject,
            chapter=chapter,
            has_image=has_image,
            solution_status=solution_status,
            limit=limit,
            offset=offset,
        )
    except ValueError as e:
        raise HTTPException(400, str(e))
    return {
        "total": total,
        "items": [item.model_dump(mode='json') for item in items],
    }


@router.get("/{question_id}")
async def get_question(
    question_id: uuid.UUID,
    exam_type: str = Query(...),
    question_type: str = Query(...),
    session: AsyncSession = Depends(get_session),
) -> dict:
    item = await questions_service.get_question(
        session,
        question_id=question_id,
        exam_type=exam_type,
        question_type=question_type,
    )
    if item is None:
        raise HTTPException(status_code=404, detail="Question not found.")
    return item.model_dump(mode='json')

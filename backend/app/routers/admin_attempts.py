"""Admin override of attempt detail/review.

The student-facing /attempts/{id} and /attempts/{id}/review filter to the
caller's own user_id. Admins need to see other students' attempts to roster
quizzes and triage problem questions, so this router exposes the same shape
without the user-scope check. Wrapped by `require_admin`.
"""

import uuid

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from ..api_schemas import QuizReviewOut
from ..database import get_session
from ..deps import require_admin
from ..schemas_user_data import AdminAttemptDetail
from ..services import attempts_service

router = APIRouter(
    prefix="/admin/attempts",
    tags=["admin-attempts"],
    dependencies=[Depends(require_admin)],
)


@router.get("/{attempt_id}", response_model=AdminAttemptDetail)
async def admin_get_attempt(
    attempt_id: uuid.UUID,
    session: AsyncSession = Depends(get_session),
) -> AdminAttemptDetail:
    return await attempts_service.get_attempt_admin(
        session, attempt_id=attempt_id
    )


@router.get("/{attempt_id}/review", response_model=QuizReviewOut)
async def admin_get_attempt_review(
    attempt_id: uuid.UUID,
    page: int = Query(1, ge=1),
    page_size: int = Query(50, ge=1, le=200),
    session: AsyncSession = Depends(get_session),
) -> QuizReviewOut:
    return await attempts_service.get_attempt_review_admin(
        session, attempt_id=attempt_id, page=page, page_size=page_size
    )

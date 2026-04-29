import uuid

from fastapi import APIRouter, Depends, Query, Response, status
from sqlalchemy.ext.asyncio import AsyncSession

from ..api_schemas import QuizQuestionsOut, QuizReviewOut
from ..database import get_session
from ..deps import get_current_user
from ..models import User
from ..schemas_user_data import (
    AttemptAnswerIn,
    AttemptAnswerOut,
    AttemptDetail,
    AttemptListOut,
    AttemptResult,
    AttemptStartIn,
    AttemptStartOut,
)
from ..services import attempts_service
from ..services.pdf_service import generate_attempt_pdf

router = APIRouter(
    prefix="/attempts",
    tags=["attempts"],
    dependencies=[Depends(get_current_user)],
)


@router.post("", response_model=AttemptStartOut, status_code=status.HTTP_201_CREATED)
async def start_attempt(
    body: AttemptStartIn,
    current: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> AttemptStartOut:
    out = await attempts_service.start_attempt(
        session, user_id=current.id, body=body, is_admin=current.is_admin
    )
    await session.commit()
    return out


@router.post("/{attempt_id}/answer", response_model=AttemptAnswerOut)
async def record_answer(
    attempt_id: uuid.UUID,
    body: AttemptAnswerIn,
    current: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> AttemptAnswerOut:
    is_correct, correct = await attempts_service.record_answer(
        session,
        user_id=current.id,
        attempt_id=attempt_id,
        question_id=body.question_id,
        selected_label=body.selected_label,
    )
    return AttemptAnswerOut(is_correct=is_correct, correct_answer=correct)


@router.post("/{attempt_id}/submit", response_model=AttemptResult)
async def submit_attempt(
    attempt_id: uuid.UUID,
    current: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> AttemptResult:
    return await attempts_service.submit_attempt(
        session, user_id=current.id, attempt_id=attempt_id
    )


@router.get("", response_model=AttemptListOut)
async def list_attempts(
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
    current: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> AttemptListOut:
    total, items = await attempts_service.list_attempts(
        session, user_id=current.id, limit=limit, offset=offset
    )
    return AttemptListOut(total=total, items=items)


@router.get("/{attempt_id}", response_model=AttemptDetail)
async def get_attempt(
    attempt_id: uuid.UUID,
    current: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> AttemptDetail:
    return await attempts_service.get_attempt(
        session, user_id=current.id, attempt_id=attempt_id
    )


@router.get("/{attempt_id}/questions", response_model=QuizQuestionsOut)
async def get_attempt_questions(
    attempt_id: uuid.UUID,
    page: int = Query(1, ge=1),
    page_size: int = Query(50, ge=1, le=200),
    current: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> QuizQuestionsOut:
    return await attempts_service.get_attempt_questions(
        session,
        user_id=current.id,
        attempt_id=attempt_id,
        page=page,
        page_size=page_size,
    )


@router.get("/{attempt_id}/review", response_model=QuizReviewOut)
async def get_attempt_review(
    attempt_id: uuid.UUID,
    page: int = Query(1, ge=1),
    page_size: int = Query(50, ge=1, le=200),
    current: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> QuizReviewOut:
    return await attempts_service.get_attempt_review(
        session,
        user_id=current.id,
        attempt_id=attempt_id,
        page=page,
        page_size=page_size,
    )


@router.get("/{attempt_id}/pdf")
async def download_attempt_pdf(
    attempt_id: uuid.UUID,
    current: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
):
    """Generate and download PDF report for an attempt."""
    # Get attempt details
    attempt = await attempts_service.get_attempt(
        session, user_id=current.id, attempt_id=attempt_id
    )
    
    # Get all review questions
    all_questions = []
    page = 1
    while True:
        review = await attempts_service.get_attempt_review(
            session, user_id=current.id, attempt_id=attempt_id, page=page, page_size=200
        )
        all_questions.extend([q.model_dump() for q in review.items])
        if page * review.page_size >= review.total:
            break
        page += 1
    
    # Generate PDF
    pdf_bytes = generate_attempt_pdf(
        user=current,
        attempt_data=attempt.model_dump(),
        questions=all_questions,
    )
    
    # Return as downloadable file with CORS headers
    return Response(
        content=pdf_bytes,
        media_type="application/pdf",
        headers={
            "Content-Disposition": f"attachment; filename=quiz_result_{attempt_id}.pdf",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET",
            "Access-Control-Allow-Headers": "Authorization",
        }
    )

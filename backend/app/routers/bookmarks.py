import uuid

from fastapi import APIRouter, Depends, Query, Response, status
from sqlalchemy.ext.asyncio import AsyncSession

from ..database import get_session
from ..deps import get_current_user
from ..models import User
from ..schemas_user_data import BookmarkCreateIn, BookmarkListOut, BookmarkOut
from ..services import bookmarks_service

router = APIRouter(
    prefix="/bookmarks",
    tags=["bookmarks"],
    dependencies=[Depends(get_current_user)],
)


@router.get("", response_model=BookmarkListOut)
async def list_bookmarks(
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
    current: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> BookmarkListOut:
    total, items = await bookmarks_service.list_for_user(
        session, user_id=current.id, limit=limit, offset=offset
    )
    return BookmarkListOut(total=total, items=items)


@router.post("", response_model=BookmarkOut, status_code=status.HTTP_201_CREATED)
async def add_bookmark(
    body: BookmarkCreateIn,
    current: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> BookmarkOut:
    return await bookmarks_service.add(
        session, user_id=current.id, question_id=body.question_id
    )


@router.delete("/{question_id}", status_code=status.HTTP_204_NO_CONTENT)
async def remove_bookmark(
    question_id: uuid.UUID,
    current: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> Response:
    await bookmarks_service.remove(
        session, user_id=current.id, question_id=question_id
    )
    return Response(status_code=status.HTTP_204_NO_CONTENT)

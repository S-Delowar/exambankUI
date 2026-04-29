from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from ..database import get_session
from ..deps import get_current_user
from ..models import User
from ..schemas_user_data import ProgressSummaryOut
from ..services import progress_service

router = APIRouter(
    prefix="/progress",
    tags=["progress"],
    dependencies=[Depends(get_current_user)],
)


@router.get("/summary", response_model=ProgressSummaryOut)
async def progress_summary(
    current: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> ProgressSummaryOut:
    return await progress_service.compute_summary(session, user_id=current.id)

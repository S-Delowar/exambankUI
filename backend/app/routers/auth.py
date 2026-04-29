from fastapi import APIRouter, Depends, Request, Response, status
from sqlalchemy.ext.asyncio import AsyncSession

from ..database import get_session
from ..deps import get_current_user
from ..models import User
from ..schemas_auth import AuthEnvelope, LoginIn, RefreshIn, SignupIn, TokenPair, UserOut
from ..services import auth_service

router = APIRouter(prefix="/auth", tags=["auth"])


def _client_info(request: Request) -> tuple[str | None, str | None]:
    ua = request.headers.get("user-agent")
    ip = request.client.host if request.client else None
    return ua, ip


@router.post("/signup", response_model=AuthEnvelope, status_code=status.HTTP_201_CREATED)
async def signup(
    body: SignupIn,
    request: Request,
    session: AsyncSession = Depends(get_session),
) -> AuthEnvelope:
    user = await auth_service.signup(
        session,
        email=body.email,
        password=body.password,
        display_name=body.display_name,
    )
    ua, ip = _client_info(request)
    access, refresh, ttl = await auth_service.issue_token_pair(
        session, user=user, user_agent=ua, ip=ip
    )
    await session.commit()
    return AuthEnvelope(
        user=UserOut.model_validate(user),
        access_token=access,
        refresh_token=refresh,
        expires_in=ttl,
    )


@router.post("/login", response_model=AuthEnvelope)
async def login(
    body: LoginIn,
    request: Request,
    session: AsyncSession = Depends(get_session),
) -> AuthEnvelope:
    user = await auth_service.authenticate(
        session, email=body.email, password=body.password
    )
    ua, ip = _client_info(request)
    access, refresh, ttl = await auth_service.issue_token_pair(
        session, user=user, user_agent=ua, ip=ip
    )
    await session.commit()
    return AuthEnvelope(
        user=UserOut.model_validate(user),
        access_token=access,
        refresh_token=refresh,
        expires_in=ttl,
    )


@router.post("/refresh", response_model=TokenPair)
async def refresh(
    body: RefreshIn,
    session: AsyncSession = Depends(get_session),
) -> TokenPair:
    _user, access, raw_new, ttl = await auth_service.rotate_refresh(
        session, raw_refresh_token=body.refresh_token
    )
    await session.commit()
    return TokenPair(access_token=access, refresh_token=raw_new, expires_in=ttl)


@router.get("/me", response_model=UserOut)
async def me(current: User = Depends(get_current_user)) -> UserOut:
    return UserOut.model_validate(current)


@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
async def logout(
    body: RefreshIn,
    session: AsyncSession = Depends(get_session),
    _current: User = Depends(get_current_user),
) -> Response:
    await auth_service.revoke_refresh(session, raw_refresh_token=body.refresh_token)
    await session.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)

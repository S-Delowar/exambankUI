"""FastAPI dependencies: current user from Bearer token."""

import uuid

import jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.ext.asyncio import AsyncSession

from .database import get_session
from .models import User
from .security import decode_access_token

_bearer = HTTPBearer(auto_error=False)


async def get_current_user(
    creds: HTTPAuthorizationCredentials | None = Depends(_bearer),
    session: AsyncSession = Depends(get_session),
) -> User:
    if creds is None or creds.scheme.lower() != "bearer":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing bearer token",
            headers={"WWW-Authenticate": "Bearer"},
        )
    try:
        payload = decode_access_token(creds.credentials)
        if payload.get("type") != "access":
            raise HTTPException(401, "Wrong token type")
        user_id = uuid.UUID(payload["sub"])
    except jwt.ExpiredSignatureError:
        raise HTTPException(401, "Token expired")
    except (jwt.InvalidTokenError, ValueError, KeyError):
        raise HTTPException(401, "Invalid token")

    user = await session.get(User, user_id)
    if user is None or not user.is_active:
        raise HTTPException(401, "User not found or disabled")
    return user


async def require_admin(
    current: User = Depends(get_current_user),
) -> User:
    if not current.is_admin:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin access required",
        )
    return current


async def get_current_user_optional(
    creds: HTTPAuthorizationCredentials | None = Depends(_bearer),
    session: AsyncSession = Depends(get_session),
) -> User | None:
    if creds is None or creds.scheme.lower() != "bearer":
        return None
    try:
        payload = decode_access_token(creds.credentials)
        if payload.get("type") != "access":
            return None
        user_id = uuid.UUID(payload["sub"])
    except (jwt.InvalidTokenError, ValueError, KeyError):
        return None
    user = await session.get(User, user_id)
    if user is None or not user.is_active:
        return None
    return user

"""Auth business logic: signup, authenticate, issue/rotate/revoke refresh tokens."""

from datetime import datetime, timezone

from fastapi import HTTPException, status
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from ..models import RefreshToken, User
from ..security import (
    dummy_verify,
    encode_access_token,
    generate_refresh_token,
    hash_password,
    hash_refresh_token,
    refresh_token_expiry,
    verify_password,
)


def _normalize_email(email: str) -> str:
    return email.strip().lower()


async def signup(
    session: AsyncSession,
    *,
    email: str,
    password: str,
    display_name: str,
) -> User:
    email = _normalize_email(email)
    existing = await session.execute(
        select(User).where(func.lower(User.email) == email)
    )
    if existing.scalar_one_or_none() is not None:
        raise HTTPException(status.HTTP_409_CONFLICT, "Email already registered")

    user = User(
        email=email,
        password_hash=hash_password(password),
        display_name=display_name.strip(),
    )
    session.add(user)
    await session.flush()
    return user


async def authenticate(
    session: AsyncSession, *, email: str, password: str
) -> User:
    email = _normalize_email(email)
    result = await session.execute(
        select(User).where(func.lower(User.email) == email)
    )
    user = result.scalar_one_or_none()
    if user is None:
        dummy_verify()
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Invalid credentials")
    if not verify_password(password, user.password_hash):
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Invalid credentials")
    if not user.is_active:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Account disabled")
    return user


async def issue_token_pair(
    session: AsyncSession,
    *,
    user: User,
    user_agent: str | None = None,
    ip: str | None = None,
) -> tuple[str, str, int]:
    """Create access + refresh token, persist refresh hash. Returns (access, refresh_raw, ttl_sec)."""
    access, ttl_sec = encode_access_token(user.id)
    raw_refresh = generate_refresh_token()
    row = RefreshToken(
        user_id=user.id,
        token_hash=hash_refresh_token(raw_refresh),
        expires_at=refresh_token_expiry(),
        user_agent=user_agent,
        ip=ip,
    )
    session.add(row)
    await session.flush()
    return access, raw_refresh, ttl_sec


async def rotate_refresh(
    session: AsyncSession, *, raw_refresh_token: str
) -> tuple[User, str, str, int]:
    """Rotate the refresh token: revoke old, issue new. Returns (user, access, refresh_raw, ttl_sec)."""
    th = hash_refresh_token(raw_refresh_token)
    result = await session.execute(
        select(RefreshToken).where(RefreshToken.token_hash == th)
    )
    old = result.scalar_one_or_none()
    now = datetime.now(timezone.utc)
    if (
        old is None
        or old.revoked_at is not None
        or old.expires_at <= now
    ):
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Invalid refresh token")

    user = await session.get(User, old.user_id)
    if user is None or not user.is_active:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "User not found or disabled")

    old.revoked_at = now

    access, ttl_sec = encode_access_token(user.id)
    raw_new = generate_refresh_token()
    new_row = RefreshToken(
        user_id=user.id,
        token_hash=hash_refresh_token(raw_new),
        expires_at=refresh_token_expiry(),
    )
    session.add(new_row)
    await session.flush()
    old.replaced_by_id = new_row.id
    await session.flush()
    return user, access, raw_new, ttl_sec


async def revoke_refresh(session: AsyncSession, *, raw_refresh_token: str) -> None:
    """Revoke a refresh token on logout. Idempotent."""
    th = hash_refresh_token(raw_refresh_token)
    result = await session.execute(
        select(RefreshToken).where(RefreshToken.token_hash == th)
    )
    row = result.scalar_one_or_none()
    if row is not None and row.revoked_at is None:
        row.revoked_at = datetime.now(timezone.utc)

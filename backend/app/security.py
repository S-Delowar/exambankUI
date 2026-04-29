"""Password hashing (pwdlib/argon2), JWT encode/decode, refresh-token hashing."""

import hashlib
import secrets
import uuid
from datetime import datetime, timedelta, timezone

import jwt
from pwdlib import PasswordHash
from pwdlib.hashers.argon2 import Argon2Hasher

from .config import get_settings

_password_hash = PasswordHash((Argon2Hasher(),))

# A fixed dummy hash used to avoid timing side-channels for unknown-email logins.
_DUMMY_HASH = _password_hash.hash("dummy-password-for-timing-safety")


def hash_password(plain: str) -> str:
    return _password_hash.hash(plain)


def verify_password(plain: str, hashed: str) -> bool:
    return _password_hash.verify(plain, hashed)


def dummy_verify() -> None:
    """Run a dummy verify to equalize timing for unknown-email logins."""
    _password_hash.verify("dummy-password-for-timing-safety", _DUMMY_HASH)


def needs_rehash(hashed: str) -> bool:
    return _password_hash.verify_and_update("", hashed)[0] is False  # pragma: no cover


def _now() -> datetime:
    return datetime.now(timezone.utc)


def encode_access_token(user_id: uuid.UUID) -> tuple[str, int]:
    """Return (token, ttl_seconds)."""
    settings = get_settings()
    ttl_sec = settings.jwt_access_ttl_min * 60
    now = _now()
    exp = now + timedelta(seconds=ttl_sec)
    payload = {
        "sub": str(user_id),
        "type": "access",
        "iat": int(now.timestamp()),
        "exp": int(exp.timestamp()),
    }
    token = jwt.encode(payload, settings.jwt_secret, algorithm="HS256")
    return token, ttl_sec


def decode_access_token(token: str) -> dict:
    settings = get_settings()
    return jwt.decode(
        token,
        settings.jwt_secret,
        algorithms=["HS256"],
        options={"require": ["sub", "type", "exp"]},
    )


def generate_refresh_token() -> str:
    """Opaque random token; store only its hash on the server."""
    return secrets.token_urlsafe(48)


def hash_refresh_token(token: str) -> str:
    return hashlib.sha256(token.encode("utf-8")).hexdigest()


def refresh_token_expiry() -> datetime:
    settings = get_settings()
    return _now() + timedelta(days=settings.jwt_refresh_ttl_days)

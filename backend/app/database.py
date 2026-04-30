from collections.abc import AsyncIterator

from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.orm import DeclarativeBase

from .config import get_settings


class Base(DeclarativeBase):
    pass


_settings = get_settings()

db_url = _settings.database_url
if db_url.startswith("postgres://"):
    db_url = db_url.replace("postgres://", "postgresql+asyncpg://", 1)
elif db_url.startswith("postgresql://"):
    db_url = db_url.replace("postgresql://", "postgresql+asyncpg://", 1)

connect_args = {}
if "?" in db_url:
    # Strip all query parameters (like sslmode=require&channel_binding=require)
    # because asyncpg doesn't accept them in the URL string directly.
    db_url = db_url.split("?")[0]
    connect_args["ssl"] = "require"

engine = create_async_engine(
    db_url, 
    echo=False, 
    pool_pre_ping=True,
    connect_args=connect_args
)
SessionLocal = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)


async def get_session() -> AsyncIterator[AsyncSession]:
    async with SessionLocal() as session:
        yield session

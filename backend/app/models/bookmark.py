"""Bookmark model — polymorphic question reference."""

import uuid
from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, String, UniqueConstraint, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .base import Base


class Bookmark(Base):
    __tablename__ = "bookmarks"
    __table_args__ = (
        UniqueConstraint(
            "user_id", "question_id", "exam_type", "question_type",
            name="uq_bookmarks_user_question",
        ),
    )

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    question_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        nullable=False,
        index=True,
    )
    exam_type: Mapped[str] = mapped_column(
        String(32), nullable=False, server_default="admission_test"
    )
    question_type: Mapped[str] = mapped_column(
        String(16), nullable=False, server_default="mcq"
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )

    user: Mapped["User"] = relationship(back_populates="bookmarks")


# Avoid circular import — TYPE_CHECKING block not needed because the
# relationship uses a string annotation ("User") resolved at mapper config time.
from .user import User  # noqa: E402, F401  # ensure User is imported for SA

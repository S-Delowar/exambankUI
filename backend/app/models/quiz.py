"""Quiz publish status, keyed by (subject, exam_type).

A "quiz" in this app is the implicit conjunction `(subject, exam_type)` — no
dedicated `quizzes` table. This row tells the API whether students should see
that quiz on their listing. Absence of a row is treated as `draft` by the
service layer, so admins create rows by publishing, not by curating.
"""

import uuid
from datetime import datetime

from sqlalchemy import CheckConstraint, DateTime, ForeignKey, String, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from .base import Base


class QuizStatus(Base):
    __tablename__ = "quiz_status"
    __table_args__ = (
        CheckConstraint(
            "status IN ('draft','published','archived')",
            name="ck_quiz_status_status",
        ),
    )

    subject: Mapped[str] = mapped_column(String(64), primary_key=True)
    exam_type: Mapped[str] = mapped_column(String(32), primary_key=True)
    status: Mapped[str] = mapped_column(
        String(16), nullable=False, default="draft", server_default="draft"
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
        onupdate=func.now(),
    )
    updated_by_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="SET NULL"),
        nullable=True,
    )

"""Admission-test written question table (no options)."""

import uuid
from datetime import datetime

from sqlalchemy import (
    Boolean,
    Computed,
    DateTime,
    ForeignKey,
    String,
    Text,
    func,
)
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column

from .base import Base


class AdmissionWrittenQuestion(Base):
    __tablename__ = "admission_written_questions"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    paper_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("exam_papers.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    question_number: Mapped[str] = mapped_column(String(32), nullable=False)
    question_text: Mapped[str] = mapped_column(Text, nullable=False)

    university_name: Mapped[str | None] = mapped_column(Text, nullable=True)
    exam_session: Mapped[str | None] = mapped_column(Text, nullable=True)
    exam_unit: Mapped[str | None] = mapped_column(Text, nullable=True)
    subject: Mapped[str | None] = mapped_column(String(64), nullable=True, index=True)
    chapter: Mapped[str | None] = mapped_column(String(128), nullable=True, index=True)

    solution: Mapped[str | None] = mapped_column(Text, nullable=True)
    solution_status: Mapped[str] = mapped_column(
        String(16), nullable=False, default="pending", server_default="pending", index=True
    )
    gemini_solution: Mapped[str | None] = mapped_column(Text, nullable=True)
    gemini_correct_answer: Mapped[str | None] = mapped_column(String(16), nullable=True)
    has_image: Mapped[bool] = mapped_column(
        Computed("question_text LIKE '%[IMAGE%'", persisted=True),
        index=True,
    )
    images: Mapped[list | None] = mapped_column(
        JSONB, nullable=True, server_default=None
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )

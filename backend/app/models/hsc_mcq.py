"""HSC board MCQ question + option tables."""

import uuid
from datetime import datetime

from sqlalchemy import (
    Boolean,
    Computed,
    DateTime,
    ForeignKey,
    Integer,
    String,
    Text,
    func,
)
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .base import Base


class HscMcqQuestion(Base):
    __tablename__ = "hsc_mcq_questions"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    paper_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("exam_papers.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    question_number: Mapped[str] = mapped_column(String(32), nullable=False)
    question_text: Mapped[str] = mapped_column(Text, nullable=False)

    board_name: Mapped[str | None] = mapped_column(Text, nullable=True, index=True)
    exam_year: Mapped[str | None] = mapped_column(String(8), nullable=True, index=True)
    subject: Mapped[str | None] = mapped_column(String(64), nullable=True, index=True)
    subject_paper: Mapped[str | None] = mapped_column(String(2), nullable=True, index=True)
    chapter: Mapped[str | None] = mapped_column(String(128), nullable=True, index=True)

    correct_answer: Mapped[str | None] = mapped_column(String(16), nullable=True)
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

    options: Mapped[list["HscMcqOption"]] = relationship(
        back_populates="question",
        cascade="all, delete-orphan",
        order_by="HscMcqOption.display_order",
    )


class HscMcqOption(Base):
    __tablename__ = "hsc_mcq_options"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    question_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("hsc_mcq_questions.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    label: Mapped[str] = mapped_column(String(16), nullable=False)
    text: Mapped[str] = mapped_column(Text, nullable=False)
    image_filename: Mapped[str | None] = mapped_column(Text, nullable=True)
    display_order: Mapped[int] = mapped_column(Integer, nullable=False)

    question: Mapped[HscMcqQuestion] = relationship(back_populates="options")

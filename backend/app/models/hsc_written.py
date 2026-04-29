"""HSC board written (creative-question) tables.

Each HSC written question owns exactly 4 sub-parts (a/b/c/d with marks 1/2/3/4).
Each sub-part has its own `solution` and `solution_status` — the solution
worker generates answers per sub-part, not per question.
"""

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
    UniqueConstraint,
    func,
)
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .base import Base


class HscWrittenQuestion(Base):
    __tablename__ = "hsc_written_questions"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    paper_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("exam_papers.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    question_number: Mapped[str] = mapped_column(String(32), nullable=False)

    board_name: Mapped[str | None] = mapped_column(Text, nullable=True, index=True)
    exam_year: Mapped[str | None] = mapped_column(String(8), nullable=True, index=True)
    subject: Mapped[str | None] = mapped_column(String(64), nullable=True, index=True)
    subject_paper: Mapped[str | None] = mapped_column(String(2), nullable=True, index=True)

    uddipak_text: Mapped[str] = mapped_column(Text, nullable=False)
    uddipak_has_image: Mapped[bool] = mapped_column(
        Boolean, nullable=False, server_default="false", default=False, index=True
    )
    images: Mapped[list | None] = mapped_column(
        JSONB, nullable=True, server_default=None
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )

    sub_parts: Mapped[list["HscWrittenSubpart"]] = relationship(
        back_populates="question",
        cascade="all, delete-orphan",
        order_by="HscWrittenSubpart.display_order",
    )


class HscWrittenSubpart(Base):
    __tablename__ = "hsc_written_subparts"
    __table_args__ = (
        UniqueConstraint("question_id", "label", name="uq_hsc_written_subparts_question_label"),
    )

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    question_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("hsc_written_questions.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    label: Mapped[str] = mapped_column(String(1), nullable=False)  # "a" | "b" | "c" | "d"
    marks: Mapped[int] = mapped_column(Integer, nullable=False)  # 1 | 2 | 3 | 4
    text: Mapped[str] = mapped_column(Text, nullable=False)
    display_order: Mapped[int] = mapped_column(Integer, nullable=False)

    solution: Mapped[str | None] = mapped_column(Text, nullable=True)
    solution_status: Mapped[str] = mapped_column(
        String(16), nullable=False, default="pending", server_default="pending", index=True
    )
    gemini_solution: Mapped[str | None] = mapped_column(Text, nullable=True)
    gemini_correct_answer: Mapped[str | None] = mapped_column(String(16), nullable=True)
    has_image: Mapped[bool] = mapped_column(
        Computed("text LIKE '%[IMAGE%'", persisted=True),
        index=True,
    )

    question: Mapped[HscWrittenQuestion] = relationship(back_populates="sub_parts")

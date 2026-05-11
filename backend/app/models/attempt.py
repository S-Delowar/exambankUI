"""Attempt and AttemptAnswer models — quiz/drill/exam tracking."""

import uuid
from datetime import datetime

from sqlalchemy import (
    Boolean,
    CheckConstraint,
    DateTime,
    ForeignKey,
    Integer,
    String,
    UniqueConstraint,
    func,
)
from sqlalchemy.dialects.postgresql import ARRAY, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .base import Base


class Attempt(Base):
    __tablename__ = "attempts"
    __table_args__ = (
        CheckConstraint(
            "kind IN ('exam','drill','subject_quiz')", name="ck_attempts_kind"
        ),
        CheckConstraint("mode IN ('timed','untimed')", name="ck_attempts_mode"),
        CheckConstraint(
            "status IN ('in_progress','submitted','abandoned')", name="ck_attempts_status"
        ),
        CheckConstraint(
            "(kind='exam' AND paper_id IS NOT NULL) OR "
            "(kind='drill' AND drill_subject IS NOT NULL AND drill_chapter IS NOT NULL) OR "
            "(kind='subject_quiz' AND drill_subject IS NOT NULL)",
            name="ck_attempts_kind_shape",
        ),
    )

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    kind: Mapped[str] = mapped_column(String(16), nullable=False)
    mode: Mapped[str] = mapped_column(String(16), nullable=False)
    paper_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("exam_papers.id", ondelete="SET NULL"),
        nullable=True,
        index=True,
    )
    drill_subject: Mapped[str | None] = mapped_column(String(64), nullable=True)
    drill_chapter: Mapped[str | None] = mapped_column(String(128), nullable=True)
    exam_type: Mapped[str | None] = mapped_column(String(32), nullable=True, index=True)
    duration_sec: Mapped[int | None] = mapped_column(Integer, nullable=True)
    question_ids: Mapped[list[uuid.UUID]] = mapped_column(
        ARRAY(UUID(as_uuid=True)), nullable=False
    )
    status: Mapped[str] = mapped_column(
        String(16), nullable=False, default="in_progress", server_default="in_progress"
    )
    started_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    submitted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    score_correct: Mapped[int | None] = mapped_column(Integer, nullable=True)
    score_total: Mapped[int | None] = mapped_column(Integer, nullable=True)
    elapsed_sec: Mapped[int | None] = mapped_column(Integer, nullable=True)

    user: Mapped["User"] = relationship(back_populates="attempts")
    answers: Mapped[list["AttemptAnswer"]] = relationship(
        back_populates="attempt", cascade="all, delete-orphan"
    )


class AttemptAnswer(Base):
    __tablename__ = "attempt_answers"
    __table_args__ = (
        UniqueConstraint(
            "attempt_id", "question_id", name="uq_attempt_answers_attempt_question"
        ),
    )

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    attempt_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("attempts.id", ondelete="CASCADE"),
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
    selected_label: Mapped[str] = mapped_column(String(16), nullable=False)
    is_correct: Mapped[bool] = mapped_column(Boolean, nullable=False)
    answered_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )

    attempt: Mapped[Attempt] = relationship(back_populates="answers")


from .user import User  # noqa: E402, F401  # ensure User is imported for SA

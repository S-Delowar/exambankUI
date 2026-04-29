"""Shared ExamPaper parent row.

One upload = one ExamPaper + N rows in exactly one child question table. The
discriminator columns `exam_type` + `question_type` say which child table the
questions live in. The nullable denorm columns (`university_name`, `board_name`,
...) are filled after extraction from the first question so listing queries
don't need a join.
"""

import uuid
from datetime import datetime

from sqlalchemy import DateTime, Integer, String, Text, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from .base import Base


class ExamPaper(Base):
    __tablename__ = "exam_papers"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    source_filename: Mapped[str] = mapped_column(Text, nullable=False)

    # Discriminators
    exam_type: Mapped[str] = mapped_column(
        String(32),
        nullable=False,
        server_default="admission_test",
        index=True,
    )
    question_type: Mapped[str] = mapped_column(
        String(16),
        nullable=False,
        server_default="mcq",
        index=True,
    )

    # Admission-test denorm fields (null for HSC rows)
    university_name: Mapped[str | None] = mapped_column(Text, nullable=True)
    exam_session: Mapped[str | None] = mapped_column(Text, nullable=True)
    exam_unit: Mapped[str | None] = mapped_column(Text, nullable=True)

    # HSC-board denorm fields (null for admission rows)
    board_name: Mapped[str | None] = mapped_column(Text, nullable=True)
    exam_year: Mapped[str | None] = mapped_column(String(8), nullable=True)
    subject: Mapped[str | None] = mapped_column(String(64), nullable=True)
    subject_paper: Mapped[str | None] = mapped_column(String(2), nullable=True)

    page_count: Mapped[int] = mapped_column(Integer, nullable=False)
    output_json_path: Mapped[str | None] = mapped_column(Text, nullable=True)
    # Absolute path to the original uploaded PDF on disk. Stored next to the
    # JSON output so reviewers can view the source in the web UI. Null on
    # pre-migration rows (no source PDF was kept in the old pipeline).
    source_pdf_path: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )

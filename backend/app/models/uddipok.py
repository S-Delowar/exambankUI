"""Uddipok (stimulus/passage) table.

Uddipoks are shared context passages that precede one or more questions in HSC
exams. Both MCQ and Written questions can reference uddipoks.
"""

import uuid
from datetime import datetime

from sqlalchemy import Boolean, DateTime, ForeignKey, Integer, Text, func
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column

from .base import Base


class Uddipok(Base):
    """Uddipok (উদ্দীপক) - stimulus passage or scenario.
    
    A single uddipok can be referenced by multiple questions. This table
    normalizes uddipok storage to avoid duplication.
    """
    __tablename__ = "uddipoks"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    paper_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("exam_papers.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    
    text: Mapped[str] = mapped_column(
        Text, 
        nullable=False,
        comment="Full uddipok text with [IMAGE_N] tokens for embedded figures"
    )
    has_image: Mapped[bool] = mapped_column(
        Boolean, 
        nullable=False, 
        default=False,
        index=True,
        comment="True if text contains [IMAGE_N] tokens"
    )
    images: Mapped[list | None] = mapped_column(
        JSONB, 
        nullable=True,
        comment="Image metadata (id, kind, caption_hint, etc.)"
    )
    
    sequence_number: Mapped[int] = mapped_column(
        Integer, 
        nullable=False,
        comment="Order of appearance in the paper (1, 2, 3, ...)"
    )
    
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), 
        server_default=func.now(), 
        nullable=False
    )

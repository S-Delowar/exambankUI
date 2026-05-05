"""Extraction workflow model for admin PDF processing pipeline."""

import uuid
from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, String, Text, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from .base import Base


class ExtractionWorkflow(Base):
    """Tracks the multi-step extraction workflow for admin users.
    
    Workflow steps:
    1. upload - PDF uploaded
    2. clean - PDF cleaning (optional)
    3. crop - Image cropping (optional)
    4. extract - Question extraction
    5. complete - Workflow finished
    """
    __tablename__ = "extraction_workflows"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    created_by: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    
    # Original PDF
    original_filename: Mapped[str] = mapped_column(String(500), nullable=False)
    original_pdf_path: Mapped[str] = mapped_column(Text, nullable=False)
    
    # Cleaned PDF (optional)
    cleaned_pdf_path: Mapped[str | None] = mapped_column(Text, nullable=True)
    cleaning_applied: Mapped[bool] = mapped_column(default=False, nullable=False)
    
    # Selected PDF for extraction (either original or cleaned)
    selected_pdf_path: Mapped[str] = mapped_column(Text, nullable=False)
    
    # Cropping (optional)
    crop_folder: Mapped[str | None] = mapped_column(String(500), nullable=True)
    cropping_applied: Mapped[bool] = mapped_column(default=False, nullable=False)
    
    # Extraction
    extraction_job_id: Mapped[str | None] = mapped_column(String(100), nullable=True)
    paper_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("exam_papers.id", ondelete="SET NULL"),
        nullable=True,
    )
    
    # Workflow state
    current_step: Mapped[str] = mapped_column(
        String(20), 
        nullable=False, 
        default="upload",
        comment="Current step: upload, clean, crop, extract, complete"
    )
    status: Mapped[str] = mapped_column(
        String(20),
        nullable=False,
        default="in_progress",
        comment="Status: in_progress, completed, failed"
    )
    error_message: Mapped[str | None] = mapped_column(Text, nullable=True)
    
    # Timestamps
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), 
        server_default=func.now(), 
        nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False
    )

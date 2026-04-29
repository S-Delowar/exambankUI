"""Persist an admission-written extraction into Postgres (no options)."""

import uuid
from pathlib import Path

from ..database import SessionLocal
from ..models import AdmissionWrittenQuestion
from ..schemas import AdmissionWrittenPdfExtraction
from ._common import build_exam_paper_row, serialize_images


async def save(
    result: AdmissionWrittenPdfExtraction,
    json_path: Path,
    source_pdf_path: Path | None = None,
) -> uuid.UUID:
    first = result.questions[0] if result.questions else None
    paper = build_exam_paper_row(
        source_filename=result.source_filename,
        exam_type="admission_test",
        question_type="written",
        page_count=result.page_count,
        json_path=str(json_path),
        source_pdf_path=str(source_pdf_path) if source_pdf_path else None,
        first_question=first,
    )

    async with SessionLocal() as session:
        async with session.begin():
            session.add(paper)
            await session.flush()
            for q in result.questions:
                session.add(
                    AdmissionWrittenQuestion(
                        paper_id=paper.id,
                        question_number=q.question_number,
                        question_text=q.question_text,
                        university_name=q.university_name,
                        exam_session=q.exam_session,
                        exam_unit=q.exam_unit,
                        subject=q.subject,
                        chapter=q.chapter,
                        images=serialize_images(q.images),
                    )
                )
        return paper.id

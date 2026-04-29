"""Persist an admission-MCQ extraction into Postgres."""

import uuid
from pathlib import Path

from ..database import SessionLocal
from ..models import AdmissionMcqOption, AdmissionMcqQuestion
from ..schemas import AdmissionMcqPdfExtraction
from ._common import build_exam_paper_row, serialize_images


async def save(
    result: AdmissionMcqPdfExtraction,
    json_path: Path,
    source_pdf_path: Path | None = None,
) -> uuid.UUID:
    first = result.questions[0] if result.questions else None
    paper = build_exam_paper_row(
        source_filename=result.source_filename,
        exam_type="admission_test",
        question_type="mcq",
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
                question = AdmissionMcqQuestion(
                    paper_id=paper.id,
                    question_number=q.question_number,
                    question_text=q.question_text,
                    university_name=q.university_name,
                    exam_session=q.exam_session,
                    exam_unit=q.exam_unit,
                    subject=q.subject,
                    chapter=q.chapter,
                    correct_answer=q.correct_answer,
                    images=serialize_images(q.images),
                )
                session.add(question)
                await session.flush()
                for idx, opt in enumerate(q.options):
                    session.add(
                        AdmissionMcqOption(
                            question_id=question.id,
                            label=opt.label,
                            text=opt.text,
                            image_filename=opt.image_filename,
                            display_order=idx,
                        )
                    )
        return paper.id

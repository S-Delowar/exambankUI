"""Persist an HSC-written extraction into Postgres (question + 4 sub-parts)."""

import uuid
from pathlib import Path

from ..database import SessionLocal
from ..models import HscWrittenQuestion, HscWrittenSubpart
from ..schemas import HscWrittenPdfExtraction
from ._common import build_exam_paper_row, serialize_images


async def save(
    result: HscWrittenPdfExtraction,
    json_path: Path,
    source_pdf_path: Path | None = None,
) -> uuid.UUID:
    first = result.questions[0] if result.questions else None
    paper = build_exam_paper_row(
        source_filename=result.source_filename,
        exam_type="hsc_board",
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
                question = HscWrittenQuestion(
                    paper_id=paper.id,
                    question_number=q.question_number,
                    board_name=q.board_name,
                    exam_year=q.exam_year,
                    subject=q.subject,
                    subject_paper=q.subject_paper,
                    uddipak_text=q.uddipak_text,
                    uddipak_has_image=q.uddipak_has_image,
                    images=serialize_images(q.images),
                )
                session.add(question)
                await session.flush()
                for idx, sp in enumerate(q.sub_questions):
                    session.add(
                        HscWrittenSubpart(
                            question_id=question.id,
                            label=sp.label,
                            marks=sp.marks,
                            text=sp.text,
                            display_order=idx,
                        )
                    )
        return paper.id

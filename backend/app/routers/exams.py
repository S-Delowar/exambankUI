"""GET /exams and GET /exams/{id}.

Filters: exam_type, question_type, plus the admission- and HSC-specific
metadata filters (university/session/unit for admission; board/year/subject/
subject_paper for HSC). All optional — omit them to see every paper.
"""

import uuid
from pathlib import Path

from fastapi import APIRouter, Depends, HTTPException, Query
from fastapi.responses import FileResponse
from sqlalchemy.ext.asyncio import AsyncSession

from ..api_schemas import ExamListOut, ExamPaperDetail
from ..config import get_settings
from ..database import get_session
from ..models import ExamPaper
from ..services import exams_service

router = APIRouter(prefix="/exams", tags=["exams"])


@router.get("", response_model=ExamListOut)
async def list_exams(
    exam_type: str | None = Query(None),
    question_type: str | None = Query(None),
    # Admission filters
    university: str | None = Query(None),
    session_q: str | None = Query(None, alias="session"),
    unit: str | None = Query(None),
    # HSC filters
    board: str | None = Query(None),
    year: str | None = Query(None),
    subject: str | None = Query(None),
    subject_paper: str | None = Query(None),
    q: str | None = Query(None),
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
    session: AsyncSession = Depends(get_session),
) -> ExamListOut:
    total, items = await exams_service.list_papers(
        session,
        exam_type=exam_type,
        question_type=question_type,
        university=university,
        session_filter=session_q,
        unit=unit,
        board=board,
        year=year,
        subject=subject,
        subject_paper=subject_paper,
        q=q,
        limit=limit,
        offset=offset,
    )
    return ExamListOut(total=total, items=items)


@router.get("/{paper_id}", response_model=ExamPaperDetail)
async def get_exam(
    paper_id: uuid.UUID,
    session: AsyncSession = Depends(get_session),
) -> ExamPaperDetail:
    detail = await exams_service.get_paper_detail(session, paper_id=paper_id)
    if detail is None:
        raise HTTPException(404, "Exam paper not found")
    return detail


@router.get("/{paper_id}/source.pdf")
async def get_exam_source_pdf(
    paper_id: uuid.UUID,
    session: AsyncSession = Depends(get_session),
) -> FileResponse:
    """Stream the original uploaded PDF for review.

    Returns 404 for papers created before source-PDF persistence, or 410 if
    the file was deleted off disk since the record was written.
    """
    paper = await session.get(ExamPaper, paper_id)
    if paper is None:
        raise HTTPException(404, "Exam paper not found")
    if not paper.source_pdf_path:
        raise HTTPException(404, "No source PDF stored for this paper")
    path = Path(paper.source_pdf_path)
    if not path.exists():
        raise HTTPException(410, "Source PDF no longer exists on disk")
    return FileResponse(
        path=str(path),
        media_type="application/pdf",
        headers={"Content-Disposition": f'inline; filename="{path.name}"'},
    )


@router.get("/{paper_id}/images/{filename}")
async def get_exam_question_image(
    paper_id: uuid.UUID,
    filename: str,
    session: AsyncSession = Depends(get_session),
) -> FileResponse:
    """Serve a cropped question image.

    The image folder is `data/images/{paper_stem}/` where `paper_stem` is the
    JSON's stem (stored on `ExamPaper.output_json_path`). Filenames are
    validated to block path traversal (`..`, leading `/`, absolute paths).
    """
    # Block path traversal. Filenames are always `p{NN}_q{qno}_{NN}.png`
    # with optional trailing `_{bump}`; any separator in the name is a bug
    # or an attack.
    if "/" in filename or "\\" in filename or ".." in filename:
        raise HTTPException(400, "Invalid filename")

    paper = await session.get(ExamPaper, paper_id)
    if paper is None:
        raise HTTPException(404, "Exam paper not found")
    if not paper.output_json_path:
        raise HTTPException(404, "No extraction JSON stored for this paper")

    stem = Path(paper.output_json_path).stem
    settings = get_settings()
    path = settings.images_path / stem / filename
    if not path.exists():
        raise HTTPException(404, "Image not found")
    return FileResponse(
        path=str(path),
        media_type="image/png",
        headers={"Cache-Control": "public, max-age=86400"},
    )

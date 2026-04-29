"""Extraction API.

One endpoint — `POST /extract` — takes a PDF plus four query params:
  exam_type       : "admission_test" | "hsc_board"      (required)
  question_type   : "mcq" | "written"                    (required)
  subjects        : comma-separated subject keys          (required)
  subject_paper   : "1" | "2"                             (required iff
                     exam_type=hsc_board AND len(subjects)==1 AND
                     that subject has a paper_1/paper_2 split)

The dispatcher in `app/extractors` then runs the matching pipeline.

Job status + result download endpoints are unchanged.
"""

import asyncio
from pathlib import Path
from typing import Literal

from fastapi import APIRouter, Depends, File, HTTPException, Query, UploadFile
from fastapi.responses import FileResponse

from ..config import get_settings
from ..deps import require_admin
from ..extractors import run_extraction
from ..jobs import job_store
from ..pdf_utils import PdfTooLargeError, render_pdf_to_images
from ..schemas import JobStatus

router = APIRouter(tags=["extract"], dependencies=[Depends(require_admin)])


# Subjects with a paper_1 / paper_2 split in the nested taxonomy. For any
# subject NOT in this set (bangla, english, ...), `subject_paper` is not
# meaningful even in single-subject HSC uploads.
_PAPER_SPLIT_SUBJECTS = frozenset({"physics", "chemistry", "mathematics", "biology"})


def _parse_subjects(subjects_raw: str) -> tuple[str, ...]:
    """Parse the comma-separated `subjects` param into a sorted, deduplicated
    tuple. Sorting gives a stable cache key for the prompt builder."""
    parts = [s.strip() for s in subjects_raw.split(",") if s.strip()]
    if not parts:
        raise HTTPException(400, "subjects must be a non-empty, comma-separated list")
    dedup = tuple(sorted(set(parts)))
    return dedup


def _validate_subjects_against_taxonomy(subjects: tuple[str, ...]) -> None:
    taxonomy = get_settings().chapter_taxonomy
    unknown = [s for s in subjects if s not in taxonomy]
    if unknown:
        raise HTTPException(400, f"Unknown subject(s): {', '.join(unknown)}")


def _validate_subject_paper(
    *,
    exam_type: str,
    subjects: tuple[str, ...],
    subject_paper: str | None,
) -> None:
    """Enforce the subject_paper rules.

    Allowed combinations:
      - exam_type=admission_test + subject_paper=None   -> OK
      - exam_type=hsc_board + multi-subject + subject_paper=None  -> OK
      - exam_type=hsc_board + single-subject (no paper split) + subject_paper=None  -> OK
      - exam_type=hsc_board + single-subject (paper-split subject) + subject_paper in {"1","2"}  -> OK
    Everything else is a 400.
    """
    if exam_type == "admission_test":
        if subject_paper is not None:
            raise HTTPException(
                400,
                "subject_paper is only valid for exam_type=hsc_board with a single subject",
            )
        return

    # exam_type == "hsc_board"
    if len(subjects) > 1:
        if subject_paper is not None:
            raise HTTPException(
                400,
                "subject_paper is only valid when exactly one subject is selected",
            )
        return

    only_subject = subjects[0]
    if only_subject in _PAPER_SPLIT_SUBJECTS:
        if subject_paper is None:
            raise HTTPException(
                400,
                f"subject_paper is required for single-subject HSC uploads where subject has a paper split "
                f"(physics/chemistry/mathematics/biology); got subject={only_subject!r}",
            )
    else:
        if subject_paper is not None:
            raise HTTPException(
                400,
                f"subject {only_subject!r} has no paper split; subject_paper must be omitted",
            )


@router.post("/extract", response_model=JobStatus)
async def extract(
    file: UploadFile = File(...),
    exam_type: Literal["admission_test", "hsc_board"] = Query(...),
    question_type: Literal["mcq", "written"] = Query(...),
    subjects: str = Query(
        ...,
        description="Comma-separated subject keys declared to be present in the PDF, e.g. 'physics,chemistry'.",
    ),
    subject_paper: Literal["1", "2"] | None = Query(None),
) -> JobStatus:
    settings = get_settings()

    if not file.filename or not file.filename.lower().endswith(".pdf"):
        raise HTTPException(status_code=400, detail="Only .pdf files are accepted.")

    subjects_tuple = _parse_subjects(subjects)
    _validate_subjects_against_taxonomy(subjects_tuple)
    _validate_subject_paper(
        exam_type=exam_type, subjects=subjects_tuple, subject_paper=subject_paper
    )

    pdf_bytes = await file.read()
    size_mb = len(pdf_bytes) / (1024 * 1024)
    if size_mb > settings.max_upload_mb:
        raise HTTPException(
            status_code=400,
            detail=f"File too large ({size_mb:.1f} MB > {settings.max_upload_mb} MB).",
        )

    # Validate the PDF can be opened and fits the page limit before enqueuing.
    try:
        render_pdf_to_images(pdf_bytes, dpi=72, max_pages=settings.max_pages)
    except PdfTooLargeError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Could not read PDF: {e}")

    job = await job_store.create()
    asyncio.create_task(
        run_extraction(
            job.job_id,
            pdf_bytes,
            file.filename,
            exam_type=exam_type,
            question_type=question_type,
            subjects=subjects_tuple,
            subject_paper=subject_paper,
        )
    )
    return job


@router.get("/jobs/{job_id}", response_model=JobStatus)
async def get_job(job_id: str) -> JobStatus:
    job = await job_store.get(job_id)
    if job is None:
        raise HTTPException(status_code=404, detail="Job not found.")
    return job


@router.get("/jobs/{job_id}/result")
async def get_job_result(job_id: str) -> FileResponse:
    job = await job_store.get(job_id)
    if job is None:
        raise HTTPException(status_code=404, detail="Job not found.")
    if job.state != "done" or not job.result_path:
        raise HTTPException(status_code=409, detail=f"Job is not ready (state={job.state}).")
    path = Path(job.result_path)
    if not path.exists():
        raise HTTPException(status_code=410, detail="Result file no longer exists on disk.")
    return FileResponse(
        path=str(path),
        media_type="application/json",
        filename=path.name,
    )

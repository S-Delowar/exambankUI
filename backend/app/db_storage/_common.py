"""Shared helpers for per-(exam_type, question_type) DB savers."""

from typing import Any

from ..models import ExamPaper
from ..schemas import ExamType, QuestionType


def serialize_images(images: Any) -> list | None:
    """Convert a list[QuestionImage] to a JSON-serialisable list of dicts for
    the JSONB column. Returns None for empty/missing so the column stays NULL
    (cheaper to index, and clearer that the question has no images)."""
    if not images:
        return None
    out = []
    for img in images:
        if hasattr(img, "model_dump"):
            out.append(img.model_dump())
        elif isinstance(img, dict):
            out.append(img)
    return out or None


def build_exam_paper_row(
    *,
    source_filename: str,
    exam_type: ExamType,
    question_type: QuestionType,
    page_count: int,
    json_path: str,
    source_pdf_path: str | None,
    first_question: Any | None,
) -> ExamPaper:
    """Build the shared ExamPaper row with the right denorm fields filled in
    based on `exam_type`.

    `first_question` is the first parsed question of whatever schema the
    runner produced; we probe it with getattr so one builder serves all 4
    combinations without knowing the concrete schema type.
    """
    def _g(key: str) -> Any:
        return getattr(first_question, key, None) if first_question else None

    return ExamPaper(
        source_filename=source_filename,
        exam_type=exam_type,
        question_type=question_type,
        # Admission denorms (set only for admission rows)
        university_name=_g("university_name") if exam_type == "admission_test" else None,
        exam_session=_g("exam_session") if exam_type == "admission_test" else None,
        exam_unit=_g("exam_unit") if exam_type == "admission_test" else None,
        # HSC denorms (set only for HSC rows)
        board_name=_g("board_name") if exam_type == "hsc_board" else None,
        exam_year=_g("exam_year") if exam_type == "hsc_board" else None,
        subject=_g("subject") if exam_type == "hsc_board" else None,
        subject_paper=_g("subject_paper") if exam_type == "hsc_board" else None,
        page_count=page_count,
        output_json_path=json_path,
        source_pdf_path=source_pdf_path,
    )

"""Dispatcher: `save_extraction_to_db(result, json_path, exam_type, question_type)`
routes to the right per-(exam_type, question_type) saver.
"""

import uuid
from pathlib import Path
from typing import Any

from ..schemas import ExamType, QuestionType
from . import admission_mcq, admission_written, hsc_mcq, hsc_written


async def save_extraction_to_db(
    result: Any,
    json_path: Path,
    *,
    exam_type: ExamType,
    question_type: QuestionType,
    source_pdf_path: Path | None = None,
) -> uuid.UUID:
    if exam_type == "admission_test" and question_type == "mcq":
        return await admission_mcq.save(result, json_path, source_pdf_path)
    if exam_type == "admission_test" and question_type == "written":
        return await admission_written.save(result, json_path, source_pdf_path)
    if exam_type == "hsc_board" and question_type == "mcq":
        return await hsc_mcq.save(result, json_path, source_pdf_path)
    if exam_type == "hsc_board" and question_type == "written":
        return await hsc_written.save(result, json_path, source_pdf_path)
    raise ValueError(
        f"No DB saver for ({exam_type!r}, {question_type!r})"
    )

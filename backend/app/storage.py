"""On-disk JSON output for extraction results.

Filename convention (deterministic, human-readable):
  admission_test + mcq      -> {University}_{YYYY-YY}_unit_{Unit}_mcq.json
  admission_test + written  -> {University}_{YYYY-YY}_unit_{Unit}_written.json
  hsc_board + mcq           -> HSC_{BoardName}_{Year}_{Subject}_p{Paper}_mcq.json
  hsc_board + written       -> HSC_{BoardName}_{Year}_{Subject}_p{Paper}_written.json

Missing metadata becomes `Unknown` / `NA` so the filename is always stable even
when the first question is malformed.
"""

import json
import re
from pathlib import Path
from typing import Any

from pydantic import BaseModel

from .schemas import ExamType, QuestionType

_SAFE_RE = re.compile(r"[^A-Za-z0-9._-]+")


def _sanitize(name: str) -> str:
    name = Path(name).stem
    name = _SAFE_RE.sub("_", name).strip("._-")
    return name or "file"


def _shorten_session(session: str | None) -> str:
    """'2010-2011' -> '2010-11'. Falls back to sanitized input if the shape
    doesn't match, or 'NA' if missing."""
    if not session:
        return "NA"
    parts = session.split("-")
    if len(parts) == 2 and len(parts[0]) == 4 and len(parts[1]) == 4:
        return f"{parts[0]}-{parts[1][-2:]}"
    return _sanitize(session)


def _first(result: Any) -> Any | None:
    questions = getattr(result, "questions", None) or []
    return questions[0] if questions else None


def _admission_filename(result: Any, question_type: QuestionType) -> str:
    first = _first(result)
    university = (getattr(first, "university_name", None) if first else None) or "Unknown"
    session = _shorten_session(getattr(first, "exam_session", None) if first else None)
    unit = (getattr(first, "exam_unit", None) if first else None) or "NA"
    stem = _sanitize(f"{university}_{session}_unit_{unit}_{question_type}")
    return f"{stem}.json"


def _hsc_filename(result: Any, question_type: QuestionType) -> str:
    first = _first(result)
    board = (getattr(first, "board_name", None) if first else None) or "Unknown"
    year = (getattr(first, "exam_year", None) if first else None) or "NA"
    subject = (getattr(first, "subject", None) if first else None) or "NA"
    paper = (getattr(first, "subject_paper", None) if first else None) or "NA"
    stem = _sanitize(f"HSC_{board}_{year}_{subject}_p{paper}_{question_type}")
    return f"{stem}.json"


def build_output_filename(
    result: Any,
    *,
    exam_type: ExamType,
    question_type: QuestionType,
) -> str:
    if exam_type == "admission_test":
        return _admission_filename(result, question_type)
    if exam_type == "hsc_board":
        return _hsc_filename(result, question_type)
    raise ValueError(f"Unknown exam_type: {exam_type!r}")


def resolve_output_path(
    output_dir: Path,
    result: Any,
    *,
    exam_type: ExamType,
    question_type: QuestionType,
) -> Path:
    """Compute the final JSON path (with collision suffix applied) WITHOUT
    writing the file. Used so the image-folder name can track the same
    collision-resolved stem the JSON will end up with.
    """
    output_dir.mkdir(parents=True, exist_ok=True)

    base = build_output_filename(result, exam_type=exam_type, question_type=question_type)
    out_path = output_dir / base
    if out_path.exists():
        stem = out_path.stem
        i = 1
        while True:
            candidate = output_dir / f"{stem}_{i}.json"
            if not candidate.exists():
                return candidate
            i += 1
    return out_path


def save_result(
    output_dir: Path,
    result: BaseModel,
    *,
    exam_type: ExamType,
    question_type: QuestionType,
    out_path: Path | None = None,
) -> Path:
    """Write the result JSON. If `out_path` is provided, use it verbatim
    (caller already resolved collisions); otherwise resolve here.
    """
    if out_path is None:
        out_path = resolve_output_path(
            output_dir, result, exam_type=exam_type, question_type=question_type
        )
    else:
        out_path.parent.mkdir(parents=True, exist_ok=True)

    with out_path.open("w", encoding="utf-8") as f:
        json.dump(
            result.model_dump(),
            f,
            ensure_ascii=False,
            indent=2,
        )
    return out_path.resolve()


def save_source_pdf(json_path: Path, pdf_bytes: bytes) -> Path:
    """Persist the original uploaded PDF alongside its extracted JSON.

    Written as `<json_stem>.pdf` next to the JSON so the two always move
    together (backup, rsync, etc.). Idempotent — overwriting is fine since
    `json_path` already carries a collision suffix from `save_result`.
    """
    pdf_path = json_path.with_suffix(".pdf")
    pdf_path.write_bytes(pdf_bytes)
    return pdf_path.resolve()

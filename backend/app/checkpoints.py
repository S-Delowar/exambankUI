"""Per-page checkpoint persistence for in-flight extraction jobs.

Why: the page loop sometimes fails on a late page (quota exhaustion, network
blip, model error). Without checkpoints, every successfully extracted page
before the failure is lost. With checkpoints, the partial JSON is kept on
disk so the operator can recover the work.

Layout: one file per job at <output_dir>/checkpoints/<job_id>.partial.json,
written atomically (temp file + rename) so a process kill mid-write can't
leave a corrupted file. Cleared on successful job completion.

Shape:
    {
      "job_id": "...",
      "filename": "DU-2023-2024-A-Unit.pdf",
      "exam_type": "admission_test",
      "question_type": "mcq",
      "page_count_seen": 9,
      "total_pages": 10,
      "questions": [ ... pydantic .model_dump() ... ]
    }

Note: this is for recovery, NOT for resume. Restarting an extraction
re-sends every page to Gemini. The checkpoint exists so the operator can
manually salvage the questions array if a job dies near the end.
"""

import json
import logging
import os
from pathlib import Path
from typing import Any

from pydantic import BaseModel

logger = logging.getLogger(__name__)


def _checkpoint_path(output_dir: Path, job_id: str) -> Path:
    return output_dir / "checkpoints" / f"{job_id}.partial.json"


def append_page(
    *,
    output_dir: Path,
    job_id: str,
    filename: str,
    exam_type: str,
    question_type: str,
    total_pages: int,
    page_count_seen: int,
    questions: list[BaseModel],
) -> Path:
    """Atomically rewrite the checkpoint file with the latest cumulative
    questions list. Called once per successfully-extracted page.

    Atomic strategy: write to a sibling .tmp file, then os.replace() onto the
    real path. os.replace is atomic on POSIX and Windows. A process kill
    between write and rename leaves the previous good checkpoint intact.
    """
    path = _checkpoint_path(output_dir, job_id)
    path.parent.mkdir(parents=True, exist_ok=True)
    payload: dict[str, Any] = {
        "job_id": job_id,
        "filename": filename,
        "exam_type": exam_type,
        "question_type": question_type,
        "total_pages": total_pages,
        "page_count_seen": page_count_seen,
        "questions": [q.model_dump() for q in questions],
    }
    tmp = path.with_suffix(path.suffix + ".tmp")
    with tmp.open("w", encoding="utf-8") as f:
        json.dump(payload, f, ensure_ascii=False, indent=2)
    os.replace(tmp, path)
    return path


def clear(output_dir: Path, job_id: str) -> None:
    """Delete the checkpoint file. Safe to call when no checkpoint exists."""
    path = _checkpoint_path(output_dir, job_id)
    try:
        path.unlink()
    except FileNotFoundError:
        return
    except Exception:
        logger.exception("Failed to delete checkpoint %s", path)


def find(output_dir: Path, job_id: str) -> Path | None:
    """Return the checkpoint path if it exists, else None."""
    path = _checkpoint_path(output_dir, job_id)
    return path if path.exists() else None

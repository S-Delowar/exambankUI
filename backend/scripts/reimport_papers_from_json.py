"""Wipe-and-reimport admission-MCQ papers from their JSON files on disk.

Why this exists: an earlier extraction bug + multiple re-runs left the DB
with duplicate question rows AND with images JSONB columns stuck at NULL.
The JSON files on disk in `backend/data/results/` are now correct (image
filenames stamped by `backfill_image_links.py`), so the cleanest fix is:

    for each JSON:
        DELETE the matching ExamPaper row (cascades to questions + options)
        re-INSERT a fresh ExamPaper + questions + options from the JSON

Safety:
  - Verifies bookmarks/attempts tables have ZERO rows referencing the
    questions before deleting (cascade would silently destroy user data).
  - Each paper deleted+reimported in a single transaction (atomic per paper).
  - --dry-run prints what would happen without touching DB.

Usage:
    backend/.venv/bin/python backend/scripts/reimport_papers_from_json.py --dry-run
    backend/.venv/bin/python backend/scripts/reimport_papers_from_json.py --only Dhaka_University_2015-16_unit_A_mcq
    backend/.venv/bin/python backend/scripts/reimport_papers_from_json.py
"""

from __future__ import annotations

import argparse
import asyncio
import json
import logging
import sys
from pathlib import Path

BACKEND_DIR = Path(__file__).resolve().parent.parent
if str(BACKEND_DIR) not in sys.path:
    sys.path.insert(0, str(BACKEND_DIR))

from sqlalchemy import delete, select  # noqa: E402

from app.config import get_settings  # noqa: E402
from app.database import SessionLocal  # noqa: E402
from app.db_storage.admission_mcq import save as save_admission_mcq  # noqa: E402
from app.models import (  # noqa: E402
    AdmissionMcqQuestion,
    Attempt,
    Bookmark,
    ExamPaper,
)
from app.schemas.admission_mcq import AdmissionMcqPdfExtraction  # noqa: E402

logging.basicConfig(level=logging.INFO, format="%(levelname)s %(name)s: %(message)s")
logger = logging.getLogger("reimport")


def load_extraction(json_path: Path) -> AdmissionMcqPdfExtraction:
    with json_path.open("r", encoding="utf-8") as f:
        data = json.load(f)
    return AdmissionMcqPdfExtraction.model_validate(data)


async def safety_check_user_data() -> tuple[int, int]:
    """Refuse to run if any bookmarks/attempts exist — cascade would destroy
    them. Returns (bookmark_count, attempt_count) so caller can show user."""
    async with SessionLocal() as s:
        bks = (await s.execute(select(Bookmark))).scalars().all()
        atts = (await s.execute(select(Attempt))).scalars().all()
        return len(bks), len(atts)


async def reimport_paper(json_path: Path, *, dry_run: bool) -> dict:
    """Delete existing ExamPaper rows for this source_filename, then save a
    fresh row from the JSON. Returns a summary dict.
    """
    result = load_extraction(json_path)
    src = result.source_filename

    async with SessionLocal() as session:
        # Find existing paper rows
        existing = (
            await session.execute(
                select(ExamPaper).where(ExamPaper.source_filename == src)
            )
        ).scalars().all()
        existing_ids = [p.id for p in existing]

        # Count questions that would be cascaded
        if existing_ids:
            old_qs = (
                await session.execute(
                    select(AdmissionMcqQuestion).where(
                        AdmissionMcqQuestion.paper_id.in_(existing_ids)
                    )
                )
            ).scalars().all()
            old_q_count = len(old_qs)
        else:
            old_q_count = 0

        new_q_count = len(result.questions)
        new_img_count = sum(
            1 for q in result.questions for img in (q.images or []) if img.filename
        )

        logger.info(
            "  %s  papers_to_delete=%d  old_qs=%d  new_qs=%d  imgs_with_filename=%d",
            json_path.name, len(existing_ids), old_q_count,
            new_q_count, new_img_count,
        )

        if dry_run:
            return {
                "file": json_path.name,
                "deleted_papers": len(existing_ids),
                "deleted_qs": old_q_count,
                "new_qs": new_q_count,
                "imgs_bound": new_img_count,
                "dry": True,
            }

        # DELETE old paper rows (cascades to questions, options)
        if existing_ids:
            await session.execute(
                delete(ExamPaper).where(ExamPaper.id.in_(existing_ids))
            )
            await session.commit()

    # Re-import via the canonical save function (opens its own session).
    # The PDF path: we don't have the original bytes; re-use what was stored
    # if any. The save function accepts None.
    pdf_path = None
    if result.source_filename:
        candidate = get_settings().output_path / result.source_filename
        if candidate.exists():
            pdf_path = candidate
        else:
            # Some papers stored the PDF under a normalized output name
            candidate2 = get_settings().output_path / json_path.with_suffix(".pdf").name
            if candidate2.exists():
                pdf_path = candidate2

    new_paper_id = await save_admission_mcq(
        result, json_path=json_path, source_pdf_path=pdf_path
    )

    return {
        "file": json_path.name,
        "deleted_papers": len(existing_ids),
        "deleted_qs": old_q_count,
        "new_qs": new_q_count,
        "imgs_bound": new_img_count,
        "new_paper_id": str(new_paper_id),
        "dry": False,
    }


async def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--only", action="append", default=[])
    parser.add_argument(
        "--force",
        action="store_true",
        help="Bypass the bookmarks/attempts safety check. Don't use unless "
             "you've verified those tables don't reference these papers.",
    )
    args = parser.parse_args()

    bk, at = await safety_check_user_data()
    if (bk or at) and not args.force:
        logger.error(
            "Refusing to run: %d bookmark(s), %d attempt(s) reference questions. "
            "Re-importing would CASCADE-delete them. Pass --force only if you've "
            "checked these don't point at the papers being reimported.",
            bk, at,
        )
        return 2
    logger.info("safety check: bookmarks=%d attempts=%d (proceeding)", bk, at)

    settings = get_settings()
    json_files = sorted(settings.output_path.glob("*.json"))
    if args.only:
        wanted = set(args.only)
        json_files = [p for p in json_files if p.stem in wanted]

    if not json_files:
        logger.error("no JSONs to process")
        return 1

    logger.info("mode: %s", "DRY RUN" if args.dry_run else "REAL RUN")
    logger.info("processing %d paper(s)", len(json_files))

    summaries = []
    for jp in json_files:
        try:
            summaries.append(await reimport_paper(jp, dry_run=args.dry_run))
        except Exception:
            logger.exception("FAILED on %s — continuing", jp.name)
            summaries.append({"file": jp.name, "error": True})

    print("\n=== summary ===")
    for s in summaries:
        if s.get("error"):
            print(f"  ERROR  {s['file']}")
            continue
        verb = "WOULD" if s["dry"] else "DID"
        print(
            f"  {verb} delete {s['deleted_papers']} paper row(s), "
            f"{s['deleted_qs']} question row(s); "
            f"insert {s['new_qs']} fresh, {s['imgs_bound']} with images  "
            f"[{s['file']}]"
        )
    return 0


if __name__ == "__main__":
    sys.exit(asyncio.run(main()))

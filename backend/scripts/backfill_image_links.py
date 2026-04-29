"""Backfill image filenames for already-extracted papers.

Why this exists: an earlier bug stamped paper_stem from the *normalized output
filename* (e.g. "Dhaka_University_2015-16_unit_A_mcq") instead of the source
PDF stem (e.g. "DU-2015-2016-A-Unit"). The image linker looked for crops at
crops_root/<paper_stem>, found nothing, and silently skipped — every JSON has
filename=null on every image stub, and backend/data/images/ is empty.

This script walks backend/data/results/*.json, finds the matching crop folder
via source_filename's stem, runs the existing linker (which copies PNGs and
stamps filenames), rewrites the JSON, and updates the DB rows in place.

Usage:
    backend/.venv/bin/python backend/scripts/backfill_image_links.py --dry-run
    backend/.venv/bin/python backend/scripts/backfill_image_links.py --only Dhaka_University_2015-16_unit_A_mcq
    backend/.venv/bin/python backend/scripts/backfill_image_links.py        # all papers, real run

Idempotent: re-running on a paper already linked just re-copies the same
files and rewrites the same filenames.
"""

from __future__ import annotations

import argparse
import asyncio
import json
import logging
import shutil
import sys
from pathlib import Path

# Make `app` importable when run as a standalone script.
BACKEND_DIR = Path(__file__).resolve().parent.parent
if str(BACKEND_DIR) not in sys.path:
    sys.path.insert(0, str(BACKEND_DIR))

from sqlalchemy import select  # noqa: E402

from app.config import get_settings  # noqa: E402
from app.database import SessionLocal  # noqa: E402
from app.image_linker import (  # noqa: E402
    link_questions_to_cropped_images,
    resolve_crop_folder,
)
from app.models import (  # noqa: E402
    AdmissionMcqOption,
    AdmissionMcqQuestion,
    ExamPaper,
)
from app.schemas.admission_mcq import AdmissionMcqPdfExtraction  # noqa: E402

logging.basicConfig(level=logging.INFO, format="%(levelname)s %(name)s: %(message)s")
logger = logging.getLogger("backfill")


def load_extraction(json_path: Path) -> AdmissionMcqPdfExtraction:
    with json_path.open("r", encoding="utf-8") as f:
        data = json.load(f)
    return AdmissionMcqPdfExtraction.model_validate(data)


def write_extraction_atomic(json_path: Path, result: AdmissionMcqPdfExtraction) -> None:
    """Backup original, then atomically rewrite the JSON."""
    backup = json_path.with_suffix(json_path.suffix + ".bak")
    if not backup.exists():
        shutil.copy2(json_path, backup)

    tmp = json_path.with_suffix(json_path.suffix + ".tmp")
    with tmp.open("w", encoding="utf-8") as f:
        json.dump(
            result.model_dump(mode="json"),
            f,
            ensure_ascii=False,
            indent=2,
        )
    tmp.replace(json_path)


async def update_db_for_paper(
    source_filename: str,
    result: AdmissionMcqPdfExtraction,
    *,
    dry_run: bool,
) -> tuple[int, int]:
    """Update images JSONB on every question + image_filename on options for
    the ExamPaper matching `source_filename`. Returns (q_updated, opt_updated).
    """
    questions_by_num: dict[str, object] = {
        q.question_number: q for q in result.questions
    }

    q_updated = 0
    opt_updated = 0

    async with SessionLocal() as session:
        paper = (
            await session.execute(
                select(ExamPaper).where(ExamPaper.source_filename == source_filename)
            )
        ).scalar_one_or_none()
        if paper is None:
            logger.warning("  no ExamPaper row for source_filename=%s", source_filename)
            return 0, 0

        db_questions = (
            await session.execute(
                select(AdmissionMcqQuestion).where(
                    AdmissionMcqQuestion.paper_id == paper.id
                )
            )
        ).scalars().all()

        for db_q in db_questions:
            mem_q = questions_by_num.get(db_q.question_number)
            if mem_q is None:
                continue

            new_images = (
                [img.model_dump(mode="json") for img in mem_q.images]
                if mem_q.images
                else None
            )
            if db_q.images != new_images:
                db_q.images = new_images
                q_updated += 1

            db_options = (
                await session.execute(
                    select(AdmissionMcqOption).where(
                        AdmissionMcqOption.question_id == db_q.id
                    )
                )
            ).scalars().all()
            opts_by_label = {o.label: o for o in db_options}
            for mem_opt in mem_q.options:
                db_opt = opts_by_label.get(mem_opt.label)
                if db_opt is None:
                    continue
                if db_opt.image_filename != mem_opt.image_filename:
                    db_opt.image_filename = mem_opt.image_filename
                    opt_updated += 1

        if dry_run:
            await session.rollback()
        else:
            await session.commit()

    return q_updated, opt_updated


async def process_paper(
    json_path: Path,
    *,
    settings,
    dry_run: bool,
) -> dict:
    logger.info("paper: %s", json_path.name)
    result = load_extraction(json_path)
    paper_stem = json_path.stem
    src_stem = Path(result.source_filename).stem

    crop_folder = resolve_crop_folder(
        paper_stem=src_stem,
        crops_root=settings.manual_crops_path,
        alias_map=settings.manual_crops_alias,
    )
    if crop_folder is None:
        logger.warning(
            "  no crop folder for source=%s under %s — skipping",
            result.source_filename, settings.manual_crops_path,
        )
        return {"file": json_path.name, "bound": 0, "skipped": True}

    logger.info("  using crops at %s", crop_folder)

    bound = link_questions_to_cropped_images(
        questions=result.questions,
        paper_stem=paper_stem,
        crops_root=crop_folder,
        images_root=settings.images_path,
    )
    logger.info("  linker bound %d image(s) → %s/%s/",
                bound, settings.images_path.name, paper_stem)

    if dry_run:
        # Linker already copied PNGs to disk (it has no dry-run mode itself).
        # Roll those back so a dry run leaves no side effects.
        out_dir = settings.images_path / paper_stem
        if out_dir.exists():
            shutil.rmtree(out_dir)
            logger.info("  [dry-run] removed %s", out_dir)
    else:
        write_extraction_atomic(json_path, result)
        logger.info("  rewrote JSON (backup at %s.bak)", json_path.name)

    q_upd, opt_upd = await update_db_for_paper(
        result.source_filename, result, dry_run=dry_run
    )
    logger.info(
        "  DB %s: %d question row(s), %d option row(s)",
        "would update" if dry_run else "updated", q_upd, opt_upd,
    )

    return {
        "file": json_path.name,
        "bound": bound,
        "q_updated": q_upd,
        "opt_updated": opt_upd,
        "skipped": False,
    }


async def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true",
                        help="parse, link in-memory, but do not write JSON, "
                             "keep no copied PNGs, and roll back DB.")
    parser.add_argument("--only", action="append", default=[],
                        help="only process JSONs whose stem matches (repeatable).")
    args = parser.parse_args()

    settings = get_settings()
    results_dir = settings.output_path
    json_files = sorted(results_dir.glob("*.json"))
    if args.only:
        wanted = set(args.only)
        json_files = [p for p in json_files if p.stem in wanted]

    if not json_files:
        logger.error("no JSONs to process under %s", results_dir)
        return 1

    logger.info("mode: %s", "DRY RUN" if args.dry_run else "REAL RUN")
    logger.info("processing %d paper(s)", len(json_files))

    summaries = []
    for jp in json_files:
        try:
            summaries.append(await process_paper(
                jp, settings=settings, dry_run=args.dry_run
            ))
        except Exception:
            logger.exception("FAILED on %s — continuing", jp.name)
            summaries.append({"file": jp.name, "error": True})

    print("\n=== summary ===")
    total_bound = 0
    for s in summaries:
        if s.get("error"):
            print(f"  ERROR  {s['file']}")
            continue
        if s.get("skipped"):
            print(f"  SKIP   {s['file']}  (no crop folder)")
            continue
        total_bound += s["bound"]
        print(
            f"  {'DRY  ' if args.dry_run else 'OK   '} {s['file']}  "
            f"bound={s['bound']}  q={s['q_updated']}  opt={s['opt_updated']}"
        )
    print(f"\ntotal images {'would-bind' if args.dry_run else 'bound'}: {total_bound}")
    return 0


if __name__ == "__main__":
    sys.exit(asyncio.run(main()))

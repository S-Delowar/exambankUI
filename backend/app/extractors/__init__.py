"""Extraction orchestrator.

Entry point: `run_extraction(job_id, pdf_bytes, filename, exam_type,
question_type, subjects, subject_paper)`.

Steps:
  1. Render the PDF to per-page PNGs.
  2. Dispatch to the matching runner based on (exam_type, question_type).
  3. Save JSON on disk + best-effort DB persistence.
  4. Mark the job done / failed.

The runners themselves handle prompt selection, page-boundary stitching, and
any type-specific post-processing.
"""

import logging

from .. import checkpoints
from ..config import get_settings
from ..db_storage import save_extraction_to_db
from ..image_linker import link_questions_to_cropped_images, resolve_crop_folder
from ..jobs import job_store
from ..pdf_utils import render_pdf_to_images
from ..schemas import ExamType, QuestionType
from ..storage import resolve_output_path, save_result, save_source_pdf
from . import admission_mcq, admission_written, hsc_mcq, hsc_written

logger = logging.getLogger(__name__)


async def run_extraction(
    job_id: str,
    pdf_bytes: bytes,
    filename: str,
    *,
    exam_type: ExamType,
    question_type: QuestionType,
    subjects: tuple[str, ...],
    subject_paper: str | None = None,
) -> None:
    settings = get_settings()
    try:
        images = render_pdf_to_images(
            pdf_bytes, dpi=settings.render_dpi, max_pages=settings.max_pages
        )
        await job_store.mark_running(job_id, len(images))

        if exam_type == "admission_test" and question_type == "mcq":
            result = await admission_mcq.run(
                job_id=job_id,
                images=images,
                filename=filename,
                settings=settings,
                subjects=subjects,
            )
        elif exam_type == "admission_test" and question_type == "written":
            result = await admission_written.run(
                job_id=job_id,
                images=images,
                filename=filename,
                settings=settings,
                subjects=subjects,
            )
        elif exam_type == "hsc_board" and question_type == "mcq":
            result = await hsc_mcq.run(
                job_id=job_id,
                images=images,
                filename=filename,
                settings=settings,
                subjects=subjects,
                subject_paper=subject_paper,
            )
        elif exam_type == "hsc_board" and question_type == "written":
            result = await hsc_written.run(
                job_id=job_id,
                images=images,
                filename=filename,
                settings=settings,
                subjects=subjects,
                subject_paper=subject_paper,
            )
        else:
            raise ValueError(
                f"Unsupported combination: exam_type={exam_type!r}, question_type={question_type!r}"
            )

        # Resolve the final JSON path *first* so the image folder uses the
        # same collision-suffixed stem (re-runs don't desync JSON↔images,
        # and the linker can look up by paper_stem).
        resolved_path = resolve_output_path(
            settings.output_path,
            result,
            exam_type=exam_type,
            question_type=question_type,
        )
        paper_stem = resolved_path.stem

        # Image association: link Pass-1 image stubs to the manually-cropped
        # PNGs on disk (test-cropping/cropped_images/<folder>/page_<N>/imageM.png).
        # If no matching crop folder exists for this paper, image stubs stay
        # unbound (extraction_status="needs_review") — the JSON is still
        # correct; the figures just have no filenames yet.
        crop_folder = resolve_crop_folder(
            paper_stem=paper_stem,
            crops_root=settings.manual_crops_path,
            alias_map=settings.manual_crops_alias,
        )
        if crop_folder is None and result.source_filename:
            from pathlib import Path as _Path
            crop_folder = resolve_crop_folder(
                paper_stem=_Path(result.source_filename).stem,
                crops_root=settings.manual_crops_path,
                alias_map=settings.manual_crops_alias,
            )
        if crop_folder is None:
            logger.warning(
                "Job %s: no manual-crop folder for paper_stem=%s under %s — "
                "questions with images will have no filenames",
                job_id, paper_stem, settings.manual_crops_path,
            )
        else:
            try:
                bound = link_questions_to_cropped_images(
                    questions=result.questions,
                    paper_stem=paper_stem,
                    crops_root=crop_folder,
                    images_root=settings.images_path,
                )
                logger.info(
                    "Job %s: linked %d manual crop(s) from %s", job_id, bound, crop_folder
                )
            except Exception:
                logger.exception(
                    "Job %s: manual-crop linker failed; images will be missing", job_id
                )

        out_path = save_result(
            settings.output_path,
            result,
            exam_type=exam_type,
            question_type=question_type,
            out_path=resolved_path,
        )

        # Persist the original PDF next to the JSON so reviewers can open the
        # source in the web UI. Best-effort: a failure here should not fail
        # the job (the JSON is still saved).
        pdf_path = None
        try:
            pdf_path = save_source_pdf(out_path, pdf_bytes)
        except Exception:
            logger.exception("Job %s: failed to persist source PDF", job_id)

        # DB save is best-effort: the JSON on disk is the durable fallback.
        paper_id: str | None = None
        try:
            paper_id = await save_extraction_to_db(
                result,
                out_path,
                exam_type=exam_type,
                question_type=question_type,
                source_pdf_path=pdf_path,
            )
            logger.info("Job %s persisted to DB as paper %s", job_id, paper_id)
        except Exception:
            logger.exception("Job %s: DB save failed; JSON saved at %s", job_id, out_path)

        await job_store.mark_done(
            job_id, str(out_path), paper_id=str(paper_id) if paper_id else None
        )
        # Final JSON written successfully — drop the partial checkpoint.
        checkpoints.clear(settings.output_path, job_id)
        logger.info(
            "Job %s finished: %d items across %d pages (%s/%s)",
            job_id,
            len(result.questions),
            result.page_count,
            exam_type,
            question_type,
        )

    except Exception as e:
        logger.exception("Job %s failed", job_id)
        partial = checkpoints.find(settings.output_path, job_id)
        if partial is not None:
            error_msg = (
                f"{type(e).__name__}: {e} | partial results saved at {partial}"
            )
        else:
            error_msg = f"{type(e).__name__}: {e}"
        await job_store.mark_failed(job_id, error_msg)

import asyncio
import logging
import sys
from pathlib import Path
from sqlalchemy import select
from sqlalchemy.orm import selectinload

from ..config import get_settings
from ..database import SessionLocal
from ..models import AdmissionMcqQuestion
from .generator import SolutionGenerator
from .prompts import (
    PHYSICS_MCQ_JSON_SYSTEM_PROMPT,
    physics_mcq_user_prompt,
)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    stream=sys.stdout,
)
logger = logging.getLogger("physics_mcq_runner")

import re

_SAFE_RE = re.compile(r"[^A-Za-z0-9._-]+")


def _sanitize(name: str) -> str:
    name = _SAFE_RE.sub("_", name).strip("._-")
    return name or "file"


def _shorten_session(session: str | None) -> str:
    if not session:
        return "NA"
    parts = session.split("-")
    if len(parts) == 2 and len(parts[0]) == 4 and len(parts[1]) == 4:
        return f"{parts[0]}-{parts[1][-2:]}"
    return _sanitize(session)


def get_paper_stem(q: AdmissionMcqQuestion) -> str:
    university = q.university_name or "Unknown"
    session = _shorten_session(q.exam_session)
    unit = q.exam_unit or "NA"
    return _sanitize(f"{university}_{session}_unit_{unit}_mcq")


async def _save_gemini_fields(
    pk, *, solution: str, label: str, status: str = "generated"
) -> None:
    async with SessionLocal() as session:
        async with session.begin():
            obj = await session.get(AdmissionMcqQuestion, pk)
            if obj is None:
                return
            obj.gemini_solution = solution
            obj.gemini_correct_answer = label
            obj.solution_status = status


async def process_physics_admission_mcq(
    generator: SolutionGenerator, limit: int
) -> int:
    settings = get_settings()
    images_base_path = settings.images_path

    async with SessionLocal() as session:
        stmt = (
            select(AdmissionMcqQuestion)
            .options(selectinload(AdmissionMcqQuestion.options))
            .where(AdmissionMcqQuestion.subject == "physics")
            .where(AdmissionMcqQuestion.images.is_not(None))
            .where(AdmissionMcqQuestion.solution_status != "generated")
            .order_by(AdmissionMcqQuestion.created_at)
            .limit(limit)
        )
        rows = list((await session.execute(stmt)).scalars().all())

    if not rows:
        logger.info("No pending physics questions with images found.")
        return 0

    processed_count = 0
    for q in rows:
        try:
            paper_stem = get_paper_stem(q)
            image_bytes_list = []

            if q.images:
                for img_info in q.images:
                    filename = img_info.get("filename")
                    if filename:
                        img_path = images_base_path / paper_stem / filename
                        if img_path.exists():
                            with open(img_path, "rb") as f:
                                image_bytes_list.append(f.read())
                            logger.info(
                                f"Loaded image: {paper_stem}/{filename} for Q: {q.question_number}"
                            )
                        else:
                            logger.warning(f"Image not found at {img_path}")

            user_prompt = physics_mcq_user_prompt(
                question_number=q.question_number,
                question_text=q.question_text,
                options=[(o.label, o.text) for o in q.options],
                correct_answer=q.correct_answer,
            )

            result = await generator.generate(
                PHYSICS_MCQ_JSON_SYSTEM_PROMPT,
                user_prompt,
                image_bytes_list=image_bytes_list if image_bytes_list else None,
            )

            await _save_gemini_fields(
                q.id, solution=result.solution, label=result.label
            )
            logger.info(
                f"Generated solution for {q.id} (Q: {q.question_number}) -> Ans: {result.label}"
            )
            processed_count += 1

        except Exception:
            logger.exception(f"Failed to process question {q.id}")

        await asyncio.sleep(4.0)

    return processed_count


async def main():
    settings = get_settings()
    generator = SolutionGenerator(settings)
    await process_physics_admission_mcq(generator, 100)


if __name__ == "__main__":
    asyncio.run(main())

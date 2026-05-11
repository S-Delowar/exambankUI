#!/usr/bin/env python3
"""Generate Gemini solutions for specific physics questions."""
import asyncio
import logging
import sys
from sqlalchemy import select
from sqlalchemy.orm import selectinload

from app.config import get_settings
from app.database import SessionLocal
from app.models import AdmissionMcqQuestion
from app.solution_worker.generator import SolutionGenerator
from app.solution_worker.prompts import PHYSICS_MCQ_JSON_SYSTEM_PROMPT, physics_mcq_user_prompt
from app.solution_worker.physics_mcq_runner import get_paper_stem

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger(__name__)


async def generate_for_questions(session_id: str, question_numbers: list[str]):
    settings = get_settings()
    generator = SolutionGenerator(settings)
    images_base_path = settings.images_path

    async with SessionLocal() as session:
        stmt = (
            select(AdmissionMcqQuestion)
            .options(selectinload(AdmissionMcqQuestion.options))
            .where(AdmissionMcqQuestion.subject == "physics")
            .where(AdmissionMcqQuestion.exam_session == session_id)
            .where(AdmissionMcqQuestion.question_number.in_(question_numbers))
        )
        rows = list((await session.execute(stmt)).scalars().all())

    if not rows:
        logger.warning(f"No questions found for session {session_id} with numbers {question_numbers}")
        return

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
                            logger.info(f"Loaded image: {filename}")

            user_prompt = physics_mcq_user_prompt(
                question_number=q.question_number,
                question_text=q.question_text,
                options=[(o.label, o.text) for o in q.options],
                correct_answer=q.correct_answer,
            )
            
            result = await generator.generate(
                PHYSICS_MCQ_JSON_SYSTEM_PROMPT, 
                user_prompt,
                image_bytes_list=image_bytes_list if image_bytes_list else None
            )
            
            async with SessionLocal() as save_session:
                async with save_session.begin():
                    obj = await save_session.get(AdmissionMcqQuestion, q.id)
                    if obj:
                        obj.gemini_solution = result.solution
                        obj.gemini_correct_answer = result.label
                        obj.solution_status = "generated"
            
            logger.info(f"✓ Q{q.question_number}: Answer={result.label}")
            await asyncio.sleep(2.0)

        except Exception as e:
            logger.error(f"✗ Q{q.question_number}: {e}")


if __name__ == "__main__":
    asyncio.run(generate_for_questions("2018-2019", ["17", "26"]))

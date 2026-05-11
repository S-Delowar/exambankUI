#!/usr/bin/env python3
"""Regenerate existing math solutions to test updated prompt."""
import asyncio
import logging
from sqlalchemy import select
from sqlalchemy.orm import selectinload

from app.config import get_settings
from app.database import SessionLocal
from app.models import AdmissionMcqQuestion
from app.solution_worker.generator import SolutionGenerator
from app.solution_worker.prompts import MATH_MCQ_JSON_SYSTEM_PROMPT, math_mcq_user_prompt
from app.solution_worker.physics_mcq_runner import get_paper_stem

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger(__name__)


async def regenerate_existing():
    settings = get_settings()
    generator = SolutionGenerator(settings)
    images_base_path = settings.images_path

    async with SessionLocal() as session:
        stmt = (
            select(AdmissionMcqQuestion)
            .options(selectinload(AdmissionMcqQuestion.options))
            .where(AdmissionMcqQuestion.subject == "mathematics")
            .where(AdmissionMcqQuestion.solution_status == "generated")
            .order_by(AdmissionMcqQuestion.created_at)
        )
        rows = list((await session.execute(stmt)).scalars().all())

    if not rows:
        logger.info("No generated mathematics questions found.")
        return

    logger.info(f"Regenerating {len(rows)} mathematics solutions with updated prompt")
    
    for idx, q in enumerate(rows, 1):
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

            user_prompt = math_mcq_user_prompt(
                question_number=q.question_number,
                question_text=q.question_text,
                options=[(o.label, o.text) for o in q.options],
                correct_answer=q.correct_answer,
            )
            
            logger.info(f"\n[{idx}/{len(rows)}] Regenerating {q.exam_session} Q{q.question_number}")
            logger.info(f"  Question: {q.question_text[:80]}...")
            
            result = await generator.generate(
                MATH_MCQ_JSON_SYSTEM_PROMPT, 
                user_prompt,
                image_bytes_list=image_bytes_list if image_bytes_list else None
            )
            
            logger.info(f"  Old answer: {q.gemini_correct_answer}")
            logger.info(f"  New answer: {result.label}")
            logger.info(f"  New solution:\n{result.solution}\n")
            
            async with SessionLocal() as save_session:
                async with save_session.begin():
                    obj = await save_session.get(AdmissionMcqQuestion, q.id)
                    if obj:
                        obj.gemini_solution = result.solution
                        obj.gemini_correct_answer = result.label
            
            await asyncio.sleep(2.0)

        except Exception as e:
            logger.error(f"[{idx}/{len(rows)}] ✗ {q.exam_session} Q{q.question_number}: {e}")
            await asyncio.sleep(2.0)


if __name__ == "__main__":
    asyncio.run(regenerate_existing())

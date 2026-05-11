#!/usr/bin/env python3
"""Test the polar coordinate question with fixed prompt."""
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


async def test_polar_question():
    settings = get_settings()
    generator = SolutionGenerator(settings)
    images_base_path = settings.images_path

    async with SessionLocal() as session:
        # Get any polar coordinate question
        stmt = (
            select(AdmissionMcqQuestion)
            .options(selectinload(AdmissionMcqQuestion.options))
            .where(AdmissionMcqQuestion.subject == "mathematics")
            .where(AdmissionMcqQuestion.question_text.like('%পোলার%'))
            .limit(1)
        )
        q = (await session.execute(stmt)).scalar_one()

    logger.info(f"Testing: {q.exam_session} {q.question_number}")
    logger.info(f"Question: {q.question_text}")
    
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
    
    result = await generator.generate(
        MATH_MCQ_JSON_SYSTEM_PROMPT, 
        user_prompt,
        image_bytes_list=image_bytes_list if image_bytes_list else None
    )
    
    logger.info(f"\nAnswer: {result.label}")
    logger.info(f"\nSolution:\n{result.solution}\n")
    
    # Save it
    async with SessionLocal() as save_session:
        async with save_session.begin():
            obj = await save_session.get(AdmissionMcqQuestion, q.id)
            if obj:
                obj.gemini_solution = result.solution
                obj.gemini_correct_answer = result.label
    
    logger.info("✓ Saved to database")


if __name__ == "__main__":
    asyncio.run(test_polar_question())

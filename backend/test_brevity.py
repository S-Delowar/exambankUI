#!/usr/bin/env python3
import asyncio
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from app.config import get_settings
from app.database import SessionLocal
from app.models import AdmissionMcqQuestion
from app.solution_worker.generator import SolutionGenerator
from app.solution_worker.prompts import MATH_MCQ_JSON_SYSTEM_PROMPT, math_mcq_user_prompt
from app.solution_worker.physics_mcq_runner import get_paper_stem

async def test():
    settings = get_settings()
    generator = SolutionGenerator(settings)
    
    async with SessionLocal() as session:
        stmt = select(AdmissionMcqQuestion).options(selectinload(AdmissionMcqQuestion.options)).where(
            AdmissionMcqQuestion.subject == 'mathematics',
            AdmissionMcqQuestion.exam_session == '2020-2021'
        ).limit(3)
        questions = list((await session.execute(stmt)).scalars().all())
    
    for q in questions:
        user_prompt = math_mcq_user_prompt(
            question_number=q.question_number,
            question_text=q.question_text,
            options=[(o.label, o.text) for o in q.options],
            correct_answer=q.correct_answer,
        )
        
        result = await generator.generate(MATH_MCQ_JSON_SYSTEM_PROMPT, user_prompt)
        print(f'\n{q.question_number}: {q.question_text[:50]}...')
        print(f'Solution:\n{result.solution}\n')
        await asyncio.sleep(2)

asyncio.run(test())

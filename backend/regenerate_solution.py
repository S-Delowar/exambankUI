"""Regenerate Gemini solution for a specific question."""
import asyncio
from sqlalchemy import select
from sqlalchemy.orm import selectinload

from app.database import SessionLocal
from app.models import AdmissionMcqQuestion
from app.solution_worker.generator import SolutionGenerator
from app.solution_worker.prompts import PHYSICS_MCQ_JSON_SYSTEM_PROMPT, physics_mcq_user_prompt
from app.config import get_settings


async def regenerate_solution(university: str, session: str, question_number: str, subject: str = "physics"):
    settings = get_settings()
    generator = SolutionGenerator(settings)
    
    async with SessionLocal() as db_session:
        # Find the question
        stmt = (
            select(AdmissionMcqQuestion)
            .options(selectinload(AdmissionMcqQuestion.options))
            .where(
                AdmissionMcqQuestion.university_name.ilike(f"%{university}%"),
                AdmissionMcqQuestion.exam_session == session,
                AdmissionMcqQuestion.question_number == question_number,
                AdmissionMcqQuestion.subject == subject,
            )
        )
        result = await db_session.execute(stmt)
        question = result.scalar_one_or_none()
        
        if not question:
            print(f"Question not found: {university} {session} {question_number}")
            return
        
        print(f"Found question: {question.id}")
        print(f"Question text: {question.question_text[:100]}...")
        print(f"Current answer: {question.correct_answer}")
        print(f"Current Gemini answer: {question.gemini_correct_answer}")
        
        # Load images if any
        images_base_path = settings.images_path
        image_bytes_list = []
        
        if question.images:
            paper_stem = f"{university.replace(' ', '_')}_{session.replace('-', '_')}_unit_{question.exam_unit or 'A'}_mcq"
            for img_info in question.images:
                filename = img_info.get("filename")
                if filename:
                    img_path = images_base_path / paper_stem / filename
                    if img_path.exists():
                        with open(img_path, "rb") as f:
                            image_bytes_list.append(f.read())
                        print(f"Loaded image: {filename}")
        
        # Generate new solution
        user_prompt = physics_mcq_user_prompt(
            question_number=question.question_number,
            question_text=question.question_text,
            options=[(o.label, o.text) for o in question.options],
            correct_answer=question.correct_answer,
        )
        
        print("\nGenerating new solution...")
        result = await generator.generate(
            PHYSICS_MCQ_JSON_SYSTEM_PROMPT,
            user_prompt,
            image_bytes_list=image_bytes_list if image_bytes_list else None
        )
        
        print(f"\nNew Gemini answer: {result.label}")
        print(f"New solution: {result.solution[:200]}...")
        
        # Update the database
        question.gemini_solution = result.solution
        question.gemini_correct_answer = result.label
        question.solution_status = "generated"
        await db_session.commit()
        
        print("\n✓ Solution updated successfully!")


if __name__ == "__main__":
    asyncio.run(regenerate_solution("Dhaka", "2018-2019", "08."))

import asyncio
import json
import os
import sys

# Add the backend directory to sys.path to allow importing 'app'
backend_path = os.path.join(os.getcwd(), "backend")
if backend_path not in sys.path:
    sys.path.append(backend_path)

from app.database import SessionLocal
from app.services import questions_service
from app.models.paper import ExamPaper
from sqlalchemy import select

async def check_api():
    async with SessionLocal() as session:
        # Find the paper
        stmt = select(ExamPaper).where(
            ExamPaper.university_name == "Dhaka University",
            ExamPaper.exam_session == "2015-2016"
        )
        result = await session.execute(stmt)
        paper = result.scalars().first()
        if not paper:
            print("Paper not found")
            return
        
        print(f"Paper ID: {paper.id}")
        
        # Call the service method that the router uses
        total, items = await questions_service.list_questions(
            session,
            paper_id=paper.id,
            limit=500,
            offset=0,
            exam_type=None,
            question_type=None,
            subject=None,
            chapter=None,
            has_image=None,
            solution_status=None
        )
        
        for item in items:
            # item is a Pydantic model (AdmissionMcqQuestionOut)
            if item.question_number in ["20", "21"]:
                print(f"Q{item.question_number}:")
                data = item.model_dump()
                print(f"  gemini_correct_answer: {data.get('gemini_correct_answer')}")
                print(f"  gemini_solution: {data.get('gemini_solution')[:50] if data.get('gemini_solution') else 'None'}")

if __name__ == "__main__":
    asyncio.run(check_api())

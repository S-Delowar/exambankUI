import asyncio
import os
import sys

# Add the backend directory to sys.path
backend_path = os.path.join(os.getcwd(), "backend")
if backend_path not in sys.path:
    sys.path.append(backend_path)

from app.database import SessionLocal
from app.services import questions_service
from app.models.paper import ExamPaper
from sqlalchemy import select

async def check_api():
    paper_id = "2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4" # DU 2015-2016
    async with SessionLocal() as session:
        paper = await session.get(ExamPaper, paper_id)
        if not paper:
            print("Paper not found")
            return
        
        print(f"Paper: {paper.university_name} {paper.exam_session}")
        
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
        
        found = 0
        for item in items:
            if item.gemini_solution:
                found += 1
                if item.question_number in ["20", "21"]:
                    print(f"Q{item.question_number} ({item.subject}): Correct={item.correct_answer}, GeminiCorrect={item.gemini_correct_answer}, Solution={item.gemini_solution[:30]}...")
        
        print(f"Total questions with solutions returned by API: {found}")

if __name__ == "__main__":
    asyncio.run(check_api())

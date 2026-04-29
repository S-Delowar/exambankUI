import asyncio
import os
import sys

# Add the backend directory to sys.path
backend_path = os.path.join(os.getcwd(), "backend")
if backend_path not in sys.path:
    sys.path.append(backend_path)

from app.database import SessionLocal
from app.models.admission_mcq import AdmissionMcqQuestion
from sqlalchemy import select

async def check_paper_id():
    paper_id = "55086422-ef06-4659-a0be-10579b6abde5"
    async with SessionLocal() as session:
        stmt = select(AdmissionMcqQuestion).where(
            AdmissionMcqQuestion.paper_id == paper_id,
            AdmissionMcqQuestion.question_number.in_(["20", "21"])
        )
        result = await session.execute(stmt)
        questions = result.scalars().all()
        
        print(f"Found {len(questions)} questions for paper {paper_id}")
        for q in questions:
            print(f"Q{q.question_number} (Subject: {q.subject}): GeminiCorrect={q.gemini_correct_answer}, GeminiSolution={'Yes' if q.gemini_solution else 'No'}")

if __name__ == "__main__":
    asyncio.run(check_paper_id())

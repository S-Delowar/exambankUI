import asyncio
import os
import sys

# Add the backend directory to sys.path
backend_path = os.path.join(os.getcwd(), "backend")
if backend_path not in sys.path:
    sys.path.append(backend_path)

from app.database import SessionLocal
from app.models.paper import ExamPaper
from app.models.admission_mcq import AdmissionMcqQuestion
from sqlalchemy import select

async def check_paper():
    paper_id = "55086422-ef06-4659-a0be-10579b6abde5"
    async with SessionLocal() as session:
        paper = await session.get(ExamPaper, paper_id)
        if not paper:
            print("Paper not found")
            return
        print(f"Paper: {paper.university_name} {paper.exam_session} {paper.exam_unit}")
        
        # Count questions
        stmt = select(AdmissionMcqQuestion).where(AdmissionMcqQuestion.paper_id == paper_id)
        result = await session.execute(stmt)
        qs = result.scalars().all()
        print(f"Questions: {len(qs)}")
        
        # Check if ANY have gemini_solution
        with_sol = [q for q in qs if q.gemini_solution]
        print(f"Questions with Gemini solution: {len(with_sol)}")

if __name__ == "__main__":
    asyncio.run(check_paper())

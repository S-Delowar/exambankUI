import asyncio
import os
import sys

# Add the backend directory to sys.path
backend_path = os.path.join(os.getcwd(), "backend")
if backend_path not in sys.path:
    sys.path.append(backend_path)

from app.database import SessionLocal
from app.models.admission_mcq import AdmissionMcqQuestion
from sqlalchemy import select, func

async def count_solutions():
    async with SessionLocal() as session:
        stmt = select(func.count()).select_from(AdmissionMcqQuestion).where(
            AdmissionMcqQuestion.gemini_solution.isnot(None)
        )
        result = await session.execute(stmt)
        count = result.scalar()
        print(f"Total Admission MCQ with gemini_solution: {count}")
        
        if count > 0:
            # Show a few examples
            stmt = select(AdmissionMcqQuestion).where(
                AdmissionMcqQuestion.gemini_solution.isnot(None)
            ).limit(5)
            result = await session.execute(stmt)
            qs = result.scalars().all()
            for q in qs:
                print(f"ID: {q.id}, PaperID: {q.paper_id}, Q#: {q.question_number}, Solution: {q.gemini_solution[:30]}...")

if __name__ == "__main__":
    asyncio.run(count_solutions())

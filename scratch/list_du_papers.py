import asyncio
import os
import sys

# Add the backend directory to sys.path
backend_path = os.path.join(os.getcwd(), "backend")
if backend_path not in sys.path:
    sys.path.append(backend_path)

from app.database import SessionLocal
from app.models.paper import ExamPaper
from sqlalchemy import select

async def list_du_papers():
    async with SessionLocal() as session:
        stmt = select(ExamPaper).where(
            ExamPaper.university_name == "Dhaka University"
        )
        result = await session.execute(stmt)
        papers = result.scalars().all()
        
        for p in papers:
            print(f"ID: {p.id}, {p.university_name} {p.exam_session} {p.exam_unit}")

if __name__ == "__main__":
    asyncio.run(list_du_papers())

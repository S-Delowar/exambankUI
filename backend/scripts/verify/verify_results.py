import asyncio
from app.database import SessionLocal
from app.models import AdmissionMcqQuestion
from sqlalchemy import select

async def check():
    async with SessionLocal() as s:
        stmt = select(AdmissionMcqQuestion).where(AdmissionMcqQuestion.id == "dfa449d1-1841-483a-9d3c-fae10a197a8e")
        row = (await s.execute(stmt)).scalar()
        
        if not row:
            print("Question not found.")
            return

        print("-" * 20)
        print(f"ID: {row.id}")
        print(f"Question: {row.question_text[:100]}...")
        print(f"Images field: {row.images}")
        print(f"Status: {row.solution_status}")
        print(f"Gemini Ans: {row.gemini_correct_answer}")
        print(f"Gemini Sol: {row.gemini_solution}")

if __name__ == "__main__":
    asyncio.run(check())

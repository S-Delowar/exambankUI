import asyncio
import uuid
from sqlalchemy import select
from backend.app.database import SessionLocal
from backend.app.models.admission_mcq import AdmissionMcqQuestion

async def check_data():
    async with SessionLocal() as session:
        stmt = select(AdmissionMcqQuestion).where(
            AdmissionMcqQuestion.university_name == "Dhaka University",
            AdmissionMcqQuestion.exam_session == "2015-2016",
            AdmissionMcqQuestion.subject == "physics"
        ).order_by(AdmissionMcqQuestion.question_number)
        
        result = await session.execute(stmt)
        questions = result.scalars().all()
        
        print(f"Found {len(questions)} questions")
        for q in questions:
            print(f"Q{q.question_number}: Correct={q.correct_answer}, GeminiCorrect={q.gemini_correct_answer}, GeminiSolution={'Yes' if q.gemini_solution else 'No'}")
            if q.question_number in ["20", "21"]:
                print(f"  Gemini Solution sample: {q.gemini_solution[:100] if q.gemini_solution else 'None'}")

if __name__ == "__main__":
    asyncio.run(check_data())

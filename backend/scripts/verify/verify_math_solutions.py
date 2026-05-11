#!/usr/bin/env python3
"""Verify math solution generation progress."""
import asyncio
from sqlalchemy import select, func
from app.database import SessionLocal
from app.models import AdmissionMcqQuestion

async def verify():
    async with SessionLocal() as session:
        # Overall status
        stmt = select(
            AdmissionMcqQuestion.solution_status, 
            func.count(AdmissionMcqQuestion.id)
        ).where(
            AdmissionMcqQuestion.subject == "mathematics"
        ).group_by(AdmissionMcqQuestion.solution_status)
        
        result = await session.execute(stmt)
        print("Math Solution Status:")
        for status, count in result.all():
            print(f"  {status}: {count}")
        
        # Check for mismatches
        stmt = select(func.count(AdmissionMcqQuestion.id)).where(
            AdmissionMcqQuestion.subject == "mathematics",
            AdmissionMcqQuestion.solution_status == "generated",
            AdmissionMcqQuestion.correct_answer != AdmissionMcqQuestion.gemini_correct_answer
        )
        mismatch_count = (await session.execute(stmt)).scalar()
        print(f"\nAnswer mismatches: {mismatch_count}")
        
        # Sample of generated solutions
        stmt = select(AdmissionMcqQuestion).where(
            AdmissionMcqQuestion.subject == "mathematics",
            AdmissionMcqQuestion.solution_status == "generated"
        ).limit(3)
        
        samples = (await session.execute(stmt)).scalars().all()
        if samples:
            print("\nSample generated solutions:")
            for q in samples:
                print(f"\n  Q{q.question_number} ({q.exam_session}):")
                print(f"    Book answer: {q.correct_answer}")
                print(f"    Gemini answer: {q.gemini_correct_answer}")
                print(f"    Solution preview: {q.gemini_solution[:100]}...")

asyncio.run(verify())

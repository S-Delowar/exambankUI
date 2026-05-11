import asyncio
from sqlalchemy import select, func
from app.database import SessionLocal
from app.models import (
    AdmissionMcqQuestion,
    AdmissionWrittenQuestion,
    HscMcqQuestion,
    HscWrittenSubpart,
)


async def count_solutions():
    async with SessionLocal() as session:
        # Count AdmissionMcqQuestion solutions
        admission_mcq = await session.scalar(
            select(func.count()).where(
                AdmissionMcqQuestion.solution_status == "generated"
            )
        )
        
        # Count AdmissionWrittenQuestion solutions
        admission_written = await session.scalar(
            select(func.count()).where(
                AdmissionWrittenQuestion.solution_status == "generated"
            )
        )
        
        # Count HscMcqQuestion solutions
        hsc_mcq = await session.scalar(
            select(func.count()).where(
                HscMcqQuestion.solution_status == "generated"
            )
        )
        
        # Count HscWrittenSubpart solutions
        hsc_written = await session.scalar(
            select(func.count()).where(
                HscWrittenSubpart.solution_status == "generated"
            )
        )
        
        total = admission_mcq + admission_written + hsc_mcq + hsc_written
        
        print("=" * 60)
        print("SOLUTIONS COUNT BY TYPE")
        print("=" * 60)
        print(f"Admission MCQ Questions:     {admission_mcq:>6}")
        print(f"Admission Written Questions: {admission_written:>6}")
        print(f"HSC MCQ Questions:           {hsc_mcq:>6}")
        print(f"HSC Written Subparts:        {hsc_written:>6}")
        print("-" * 60)
        print(f"TOTAL SOLUTIONS:             {total:>6}")
        print("=" * 60)


if __name__ == "__main__":
    asyncio.run(count_solutions())

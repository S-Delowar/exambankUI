"""Test script to verify mismatch count calculation."""
import asyncio
from app.database import SessionLocal
from app.services.exams_service import list_papers


async def test_mismatch_count():
    async with SessionLocal() as session:
        total, papers = await list_papers(
            session,
            exam_type=None,
            question_type="mcq",
            university=None,
            session_filter=None,
            unit=None,
            board=None,
            year=None,
            subject=None,
            subject_paper=None,
            q=None,
            limit=10,
            offset=0,
        )
        
        print(f"Found {total} MCQ papers")
        print("\nPapers with mismatch counts:")
        print("-" * 80)
        for paper in papers:
            print(f"Paper: {paper.source_filename}")
            print(f"  Questions: {paper.question_count}")
            print(f"  Mismatches: {paper.answer_mismatch_count}")
            if paper.answer_mismatch_count > 0:
                print(f"  ⚠️  {paper.answer_mismatch_count} answer(s) don't match!")
            print()


if __name__ == "__main__":
    asyncio.run(test_mismatch_count())

#!/usr/bin/env python3
"""Update database image URLs to use Cloudinary."""
import asyncio
from sqlalchemy import text
from app.database import SessionLocal

CLOUDINARY_BASE = "https://res.cloudinary.com/dtairwxkx/image/upload/exambank"

# Mapping of paper folders we uploaded
PAPER_FOLDERS = [
    "Dhaka_University_2015-16_unit_A_mcq",
    "Dhaka_University_2016-17_unit_A_mcq",
    "Dhaka_University_2017-18_unit_A_mcq",
    "Dhaka_University_2018-19_unit_A_mcq",
    "Dhaka_University_2019-20_unit_A_mcq",
    "Dhaka_University_2020-21_unit_A_mcq",
    "Dhaka_University_2021-22_unit_A_mcq",
]

async def update_urls():
    async with SessionLocal() as session:
        for folder in PAPER_FOLDERS:
            # Update admission questions
            result = await session.execute(
                text("""
                    UPDATE admission_mcq_questions
                    SET images = (
                        SELECT jsonb_agg(
                            jsonb_set(
                                img,
                                '{filename}',
                                to_jsonb(:cloudinary_url || '/' || img->>'filename')
                            )
                        )
                        FROM jsonb_array_elements(images) AS img
                    )
                    WHERE images IS NOT NULL
                    AND images::text LIKE '%' || :filename_pattern || '%'
                    AND images::text NOT LIKE '%cloudinary%'
                """),
                {"cloudinary_url": f"{CLOUDINARY_BASE}/{folder}", "filename_pattern": "p0"}
            )
            print(f"Updated {result.rowcount} questions for {folder}")
        
        await session.commit()
        print(f"\n✅ All images updated to Cloudinary URLs")

if __name__ == "__main__":
    asyncio.run(update_urls())

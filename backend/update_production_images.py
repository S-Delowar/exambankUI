#!/usr/bin/env python3
import os
import json
import asyncio
from dotenv import load_dotenv
from sqlalchemy import text
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker

load_dotenv()
DATABASE_URL = os.getenv("NEON_CONNECTING_STRING") or os.getenv("DATABASE_URL")

if not DATABASE_URL:
    print("❌ NEON_CONNECTING_STRING or DATABASE_URL not found in .env")
    exit(1)

# Convert postgresql:// to postgresql+asyncpg://
if DATABASE_URL.startswith("postgresql://"):
    DATABASE_URL = DATABASE_URL.replace("postgresql://", "postgresql+asyncpg://", 1)

# Remove sslmode parameter (asyncpg uses ssl instead)
if "?sslmode=" in DATABASE_URL:
    DATABASE_URL = DATABASE_URL.split("?sslmode=")[0] + "?ssl=require"
elif "&sslmode=" in DATABASE_URL:
    DATABASE_URL = DATABASE_URL.split("&sslmode=")[0]

print(f"Connecting to production database...")

async def update_images():
    engine = create_async_engine(DATABASE_URL)
    async_session = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
    
    updates = [
        ("2015-2016", "Dhaka_University_2015-16_unit_A_mcq"),
        ("2016-2017", "Dhaka_University_2016-17_unit_A_mcq"),
        ("2017-2018", "Dhaka_University_2017-18_unit_A_mcq"),
        ("2018-2019", "Dhaka_University_2018-19_unit_A_mcq"),
        ("2019-2020", "Dhaka_University_2019-20_unit_A_mcq"),
        ("2020-2021", "Dhaka_University_2020-21_unit_A_mcq"),
        ("2021-2022", "Dhaka_University_2021-22_unit_A_mcq"),
    ]
    
    async with async_session() as session:
        total_updated = 0
        
        for exam_session, folder in updates:
            # Get questions for this session
            result = await session.execute(text("""
                SELECT id, images 
                FROM admission_mcq_questions 
                WHERE university_name = 'Dhaka University' 
                AND exam_session = :session
                AND images IS NOT NULL 
                AND images::text NOT LIKE '%cloudinary%'
            """), {"session": exam_session})
            
            questions = result.fetchall()
            
            for q_id, images in questions:
                if images:
                    # Update each image filename
                    for img in images:
                        if 'filename' in img and not img['filename'].startswith('http'):
                            img['filename'] = f"https://res.cloudinary.com/dtairwxkx/image/upload/exambank/{folder}/{img['filename']}"
                    
                    # Update the question
                    await session.execute(text("""
                        UPDATE admission_mcq_questions 
                        SET images = :images::jsonb
                        WHERE id = :id
                    """), {"images": json.dumps(images), "id": q_id})
                    total_updated += 1
            
            print(f"✓ Updated {len(questions)} questions for {exam_session}")
        
        await session.commit()
        print(f"\n✅ Total questions updated: {total_updated}")
    
    await engine.dispose()

if __name__ == "__main__":
    asyncio.run(update_images())

import logging

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .routers import (
    admin_attempts,
    admin_quizzes,
    attempts,
    auth,
    bookmarks,
    drill,
    exams,
    extract,
    progress,
    questions,
    review,
    stats,
    taxonomy,
)

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s: %(message)s",
)

app = FastAPI(title="ExamBank API", version="0.2.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
async def health() -> dict:
    return {"status": "ok"}


app.include_router(extract.router)
app.include_router(questions.router)
app.include_router(auth.router)
app.include_router(exams.router)
app.include_router(drill.router)
app.include_router(bookmarks.router)
app.include_router(attempts.router)
app.include_router(progress.router)
app.include_router(review.router)
app.include_router(stats.router)
app.include_router(taxonomy.router)
app.include_router(admin_quizzes.router)
app.include_router(admin_attempts.router)

"""SQLAlchemy model package.

Re-exports every model so that `from app.models import ...` keeps working
across the codebase and so Alembic's `Base.metadata` sees every table.

`Question` / `QuestionOption` aliases are kept pointing at the admission-MCQ
tables for backward compatibility with any downstream code that hasn't been
migrated yet.
"""

from .admission_mcq import AdmissionMcqOption, AdmissionMcqQuestion
from .admission_written import AdmissionWrittenQuestion
from .base import Base
from .hsc_mcq import HscMcqOption, HscMcqQuestion
from .hsc_written import HscWrittenQuestion, HscWrittenSubpart
from .paper import ExamPaper
from .quiz import QuizStatus
from .user import Attempt, AttemptAnswer, Bookmark, RefreshToken, User

# Legacy aliases (pre-split): several call sites used to import `Question` and
# `QuestionOption` directly. Point them at the admission-MCQ equivalents so
# existing bookmark/attempt/exam-session flows keep working unchanged.
Question = AdmissionMcqQuestion
QuestionOption = AdmissionMcqOption

__all__ = [
    "Base",
    "ExamPaper",
    "AdmissionMcqQuestion",
    "AdmissionMcqOption",
    "AdmissionWrittenQuestion",
    "HscMcqQuestion",
    "HscMcqOption",
    "HscWrittenQuestion",
    "HscWrittenSubpart",
    "User",
    "RefreshToken",
    "Bookmark",
    "Attempt",
    "AttemptAnswer",
    "QuizStatus",
    # Legacy aliases
    "Question",
    "QuestionOption",
]

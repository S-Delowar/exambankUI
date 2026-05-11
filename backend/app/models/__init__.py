"""SQLAlchemy model package.

Re-exports every model so that `from app.models import ...` keeps working
across the codebase and so Alembic's `Base.metadata` sees every table.
"""

from .admission_mcq import AdmissionMcqOption, AdmissionMcqQuestion
from .admission_written import AdmissionWrittenQuestion
from .attempt import Attempt, AttemptAnswer
from .base import Base
from .bookmark import Bookmark
from .hsc_mcq import HscMcqOption, HscMcqQuestion
from .hsc_written import HscWrittenQuestion, HscWrittenSubpart
from .paper import ExamPaper
from .quiz import QuizStatus
from .uddipok import Uddipok
from .user import RefreshToken, User
from .workflow import ExtractionWorkflow

# Legacy aliases (pre-split): several call sites used to import `Question` and
# `QuestionOption` directly. Point them at the admission-MCQ equivalents so
# existing bookmark/attempt/exam-session flows keep working unchanged.
Question = AdmissionMcqQuestion
QuestionOption = AdmissionMcqOption

__all__ = [
    "Base",
    "ExamPaper",
    "Uddipok",
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
    "ExtractionWorkflow",
    "Question",
    "QuestionOption",
]

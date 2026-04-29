"""User-scoped schemas: bookmarks, attempts, progress, drill.

Attempts and bookmarks are MCQ-only (see plan Follow-ups). `DrillSpec` carries
`exam_type` so attempts can drill HSC MCQs alongside admission MCQs. The
admission-MCQ question list is still surfaced via `QuestionOut` — for HSC
drills, items use `HscMcqQuestionOut`. Both shapes share the MCQ field set
except for the metadata columns, so the wire format stays uniform-ish.
"""

import uuid
from datetime import datetime
from typing import Any, Literal

from pydantic import BaseModel, ConfigDict, Field, model_validator

from .api_schemas import QuestionOut


# ---- Bookmarks -------------------------------------------------------------


class BookmarkCreateIn(BaseModel):
    question_id: uuid.UUID


class BookmarkOut(BaseModel):
    question_id: uuid.UUID
    created_at: datetime
    question: QuestionOut  # admission-MCQ for now; see plan Follow-ups.


class BookmarkListOut(BaseModel):
    total: int
    items: list[BookmarkOut]


# ---- Attempts --------------------------------------------------------------


class DrillSpec(BaseModel):
    exam_type: Literal["admission_test", "hsc_board"] = "admission_test"
    subject: str
    chapter: str
    subject_paper: Literal["1", "2"] | None = None
    count: int = Field(ge=5, le=100)

    @model_validator(mode="after")
    def _validate_paper(self) -> "DrillSpec":
        if self.exam_type == "admission_test" and self.subject_paper is not None:
            raise ValueError("subject_paper only applies to exam_type='hsc_board'")
        return self


class AttemptStartIn(BaseModel):
    kind: Literal["exam", "drill", "subject_quiz"]
    mode: Literal["timed", "untimed"]
    paper_id: uuid.UUID | None = None
    drill: DrillSpec | None = None
    subject: str | None = None
    # For subject_quiz: which exam pool the quiz pulls from. Defaults to
    # admission_test for backward compatibility with the pre-quiz-status
    # frontend. HSC-board is accepted by the schema but rejected at runtime
    # until the polymorphic attempt_answers FK lands.
    exam_type: Literal["admission_test", "hsc_board"] = "admission_test"
    duration_sec: int | None = None

    @model_validator(mode="after")
    def _validate_shape(self) -> "AttemptStartIn":
        if self.kind == "exam" and self.paper_id is None:
            raise ValueError("kind='exam' requires paper_id")
        if self.kind == "drill" and self.drill is None:
            raise ValueError("kind='drill' requires drill")
        if self.kind == "subject_quiz" and not self.subject:
            raise ValueError("kind='subject_quiz' requires subject")
        if self.mode == "timed" and (self.duration_sec is None or self.duration_sec <= 0):
            raise ValueError("mode='timed' requires positive duration_sec")
        return self


class AttemptStartOut(BaseModel):
    id: uuid.UUID
    question_ids: list[uuid.UUID]
    started_at: datetime


class AttemptAnswerIn(BaseModel):
    question_id: uuid.UUID
    selected_label: str


class AttemptAnswerOut(BaseModel):
    is_correct: bool
    correct_answer: str | None


class SubjectStat(BaseModel):
    subject: str
    attempted: int
    correct: int
    accuracy: float


class ChapterStat(BaseModel):
    subject: str
    chapter: str
    attempted: int
    correct: int
    accuracy: float


class AttemptBreakdown(BaseModel):
    by_subject: list[SubjectStat]
    by_chapter: list[ChapterStat]


class AttemptResult(BaseModel):
    id: uuid.UUID
    score_correct: int
    score_total: int
    elapsed_sec: int
    breakdown: AttemptBreakdown


class AttemptSummary(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    kind: str
    mode: str
    paper_id: uuid.UUID | None
    drill_subject: str | None
    drill_chapter: str | None
    exam_type: str | None
    status: str
    started_at: datetime
    submitted_at: datetime | None
    score_correct: int | None
    score_total: int | None


class AttemptAnswerRecord(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    question_id: uuid.UUID
    selected_label: str
    is_correct: bool
    answered_at: datetime


class AttemptDetail(AttemptSummary):
    question_ids: list[uuid.UUID]
    answers: list[AttemptAnswerRecord]


class AdminAttemptDetail(AttemptDetail):
    """Admin-only attempt detail — adds the owner's identity so the admin
    drill-down can show *whose* attempt this is. Kept separate from
    AttemptDetail so the public student endpoint doesn't leak fields it
    doesn't need."""

    user_id: uuid.UUID
    user_email: str
    user_display_name: str


class AttemptListOut(BaseModel):
    total: int
    items: list[AttemptSummary]


# ---- Progress --------------------------------------------------------------


class ProgressSummaryOut(BaseModel):
    streak_days: int
    total_attempts: int
    total_questions: int
    total_correct: int
    weekly_accuracy: float
    by_subject: list[SubjectStat]
    by_chapter: list[ChapterStat]


# ---- Drill -----------------------------------------------------------------


class DrillOut(BaseModel):
    # Items may be either AdmissionMcqQuestionOut (== QuestionOut) or
    # HscMcqQuestionOut depending on the drill's exam_type. Typed as Any so
    # FastAPI lets the service layer choose per response.
    items: list[Any]

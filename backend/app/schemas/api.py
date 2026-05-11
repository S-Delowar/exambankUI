"""Pydantic models for HTTP responses.

Response shape changes with the API surface; extraction schemas change with
the model prompt — different lifecycles.

Response models cover every (exam_type, question_type) variant:
  - Admission MCQ    -> AdmissionMcqQuestionOut + AdmissionMcqOptionOut
  - Admission Written -> AdmissionWrittenQuestionOut
  - HSC MCQ          -> HscMcqQuestionOut + HscMcqOptionOut
  - HSC Written      -> HscWrittenQuestionOut + HscWrittenSubpartOut

A shared `ExamPaperSummary` carries the discriminators + every denorm field so
a single listing endpoint can describe any paper.
"""

import uuid
from typing import Optional

from pydantic import BaseModel


# ---------------------------------------------------------------------------
# Option (for MCQ variants)
# ---------------------------------------------------------------------------


class OptionOut(BaseModel):
    id: Optional[uuid.UUID] = None  # surfaced so reviewers can PATCH/DELETE
    label: str
    text: str
    # Filled by the image linker when the option is itself a figure. Frontend
    # builds the URL as `/exams/{paper_id}/images/{image_filename}`.
    image_filename: Optional[str] = None


class QuestionImageOut(BaseModel):
    """Mirror of extraction-time QuestionImage for the API.

    The frontend resolves a `[IMAGE_N]` token in any of this question's text
    fields by finding the entry with `id == "IMAGE_N"` and loading
    `/exams/{paper_id}/images/{filename}`.
    """
    id: str
    page_index: int
    box_2d: list[int]
    label: Optional[str] = None
    kind: str = "diagram"
    filename: Optional[str] = None


# ---------------------------------------------------------------------------
# Per-(exam_type, question_type) question response models
# ---------------------------------------------------------------------------


class AdmissionMcqQuestionOut(BaseModel):
    id: uuid.UUID
    paper_id: uuid.UUID
    question_number: str
    question_text: str
    university_name: Optional[str] = None
    exam_session: Optional[str] = None
    exam_unit: Optional[str] = None
    subject: Optional[str] = None
    chapter: Optional[str] = None
    correct_answer: Optional[str] = None
    solution: Optional[str] = None
    solution_status: str
    has_image: bool
    images: list[QuestionImageOut] = []
    options: list[OptionOut]
    gemini_solution: Optional[str] = None
    gemini_correct_answer: Optional[str] = None


class AdmissionWrittenQuestionOut(BaseModel):
    id: uuid.UUID
    paper_id: uuid.UUID
    question_number: str
    question_text: str
    university_name: Optional[str] = None
    exam_session: Optional[str] = None
    exam_unit: Optional[str] = None
    subject: Optional[str] = None
    chapter: Optional[str] = None
    solution: Optional[str] = None
    solution_status: str
    has_image: bool
    images: list[QuestionImageOut] = []
    gemini_solution: Optional[str] = None
    gemini_correct_answer: Optional[str] = None


class HscMcqQuestionOut(BaseModel):
    id: uuid.UUID
    paper_id: uuid.UUID
    question_number: str
    question_text: str
    board_name: Optional[str] = None
    exam_year: Optional[str] = None
    subject: Optional[str] = None
    subject_paper: Optional[str] = None
    chapter: Optional[str] = None
    correct_answer: Optional[str] = None
    solution: Optional[str] = None
    solution_status: str
    has_image: bool
    images: list[QuestionImageOut] = []
    options: list[OptionOut]
    gemini_solution: Optional[str] = None
    gemini_correct_answer: Optional[str] = None


class HscWrittenSubpartOut(BaseModel):
    id: uuid.UUID
    label: str
    marks: int
    text: str
    solution: Optional[str] = None
    solution_status: str
    has_image: bool
    gemini_solution: Optional[str] = None
    gemini_correct_answer: Optional[str] = None


class HscWrittenQuestionOut(BaseModel):
    id: uuid.UUID
    paper_id: uuid.UUID
    question_number: str
    board_name: Optional[str] = None
    exam_year: Optional[str] = None
    subject: Optional[str] = None
    subject_paper: Optional[str] = None
    uddipak_text: str
    uddipak_has_image: bool
    images: list[QuestionImageOut] = []
    sub_parts: list[HscWrittenSubpartOut]


# Back-compat alias: `QuestionOut` is used by the existing drill/bookmark/
# attempt flows which are MCQ-only (and currently admission-MCQ-only).
QuestionOut = AdmissionMcqQuestionOut


# ---------------------------------------------------------------------------
# Question list wrappers
# ---------------------------------------------------------------------------


class QuestionListOut(BaseModel):
    total: int
    items: list[QuestionOut]


class AdmissionMcqQuestionListOut(BaseModel):
    total: int
    items: list[AdmissionMcqQuestionOut]


class AdmissionWrittenQuestionListOut(BaseModel):
    total: int
    items: list[AdmissionWrittenQuestionOut]


class HscMcqQuestionListOut(BaseModel):
    total: int
    items: list[HscMcqQuestionOut]


class HscWrittenQuestionListOut(BaseModel):
    total: int
    items: list[HscWrittenQuestionOut]


# ---------------------------------------------------------------------------
# Exam paper summary / detail
# ---------------------------------------------------------------------------


class ExamPaperSummary(BaseModel):
    id: uuid.UUID
    source_filename: str
    exam_type: str
    question_type: str
    university_name: Optional[str] = None
    exam_session: Optional[str] = None
    exam_unit: Optional[str] = None
    board_name: Optional[str] = None
    exam_year: Optional[str] = None
    subject: Optional[str] = None
    subject_paper: Optional[str] = None
    page_count: int
    question_count: int
    has_source_pdf: bool = False
    created_at: Optional[str] = None
    answer_mismatch_count: int = 0


class ExamPaperDetail(ExamPaperSummary):
    chapter_counts: dict[str, int] = {}


class ExamListOut(BaseModel):
    total: int
    items: list[ExamPaperSummary]


# ---------------------------------------------------------------------------
# Quiz-time question shapes
# ---------------------------------------------------------------------------


class PublicMcqQuestionOut(BaseModel):
    """Question payload served while a quiz is in progress — no answers."""
    id: uuid.UUID
    paper_id: uuid.UUID
    question_number: str
    question_text: str
    subject: Optional[str] = None
    chapter: Optional[str] = None
    has_image: bool
    images: list[QuestionImageOut] = []
    options: list[OptionOut]
    university_name: Optional[str] = None
    exam_session: Optional[str] = None
    exam_unit: Optional[str] = None


class QuizQuestionsOut(BaseModel):
    total: int
    page: int
    page_size: int
    items: list[PublicMcqQuestionOut]


class ReviewMcqQuestionOut(BaseModel):
    """Question payload for the post-submit review screen."""
    id: uuid.UUID
    paper_id: uuid.UUID
    question_number: str
    question_text: str
    subject: Optional[str] = None
    chapter: Optional[str] = None
    has_image: bool
    images: list[QuestionImageOut] = []
    options: list[OptionOut]
    correct_answer: Optional[str] = None
    solution: Optional[str] = None
    gemini_solution: Optional[str] = None
    selected_label: Optional[str] = None
    university_name: Optional[str] = None
    exam_session: Optional[str] = None
    exam_unit: Optional[str] = None
    is_correct: Optional[bool] = None


class QuizReviewOut(BaseModel):
    total: int
    page: int
    page_size: int
    items: list[ReviewMcqQuestionOut]

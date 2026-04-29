"""Pydantic models for HTTP responses.

Kept separate from `app.schemas` (which holds Gemini extraction schemas).
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


# ---------------------------------------------------------------------------
# Back-compat alias: `QuestionOut` is used by the existing drill/bookmark/
# attempt flows which are MCQ-only (and currently admission-MCQ-only). Keep
# the alias so nothing breaks until those flows are expanded.
# ---------------------------------------------------------------------------


QuestionOut = AdmissionMcqQuestionOut


# ---------------------------------------------------------------------------
# Question list wrappers
# ---------------------------------------------------------------------------


class QuestionListOut(BaseModel):
    """Legacy list response — items are admission-MCQ questions.

    For other (exam_type, question_type) variants, the listing endpoint returns
    the appropriate `*ListOut` below.
    """
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
    # Admission denorms
    university_name: Optional[str] = None
    exam_session: Optional[str] = None
    exam_unit: Optional[str] = None
    # HSC denorms
    board_name: Optional[str] = None
    exam_year: Optional[str] = None
    subject: Optional[str] = None
    subject_paper: Optional[str] = None
    page_count: int
    question_count: int
    # True when the original uploaded PDF is still on disk. The web review UI
    # uses this to decide whether to render the PDF pane.
    has_source_pdf: bool = False
    created_at: Optional[str] = None
    answer_mismatch_count: int = 0


class ExamPaperDetail(ExamPaperSummary):
    # Only populated for MCQ variants that tag chapters. For HSC written this
    # is always an empty dict (sub-parts aren't chapter-tagged).
    chapter_counts: dict[str, int] = {}


class ExamListOut(BaseModel):
    total: int
    items: list[ExamPaperSummary]


# ---------------------------------------------------------------------------
# Quiz-time question shapes
# ---------------------------------------------------------------------------


class PublicMcqQuestionOut(BaseModel):
    """Question payload served while a quiz is in progress.

    Strips `correct_answer`, `solution`, `solution_status`, and any other field
    that would let the client cheat. The frontend uses `images` + `paper_id` to
    build image URLs the same way as the admin views.
    """
    id: uuid.UUID
    paper_id: uuid.UUID
    question_number: str
    question_text: str
    subject: Optional[str] = None
    chapter: Optional[str] = None
    has_image: bool
    images: list[QuestionImageOut] = []
    options: list[OptionOut]
    # Source metadata — denormalized onto the question row at extraction time.
    # Used by the client to render an "exam · session · unit · Q-number" line
    # so students (and debuggers) can identify where a question came from.
    university_name: Optional[str] = None
    exam_session: Optional[str] = None
    exam_unit: Optional[str] = None


class QuizQuestionsOut(BaseModel):
    total: int
    page: int
    page_size: int
    items: list[PublicMcqQuestionOut]


class ReviewMcqQuestionOut(BaseModel):
    """Question payload for the post-submit review screen.

    Includes the correct answer + solution, plus the user's selected label and
    correctness flag from the attempt. `selected_label` is null for questions
    the user skipped.
    """
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

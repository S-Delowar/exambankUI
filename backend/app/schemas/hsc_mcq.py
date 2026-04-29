"""HSC board MCQ extraction schemas.

HSC PDFs are usually per-subject-per-paper (e.g. "Physics 1st Paper 2023 Dhaka
Board"). When the upload declares exactly one subject + subject_paper, the
pipeline stamps those values on every question post-parse. When multi-subject,
the model infers `subject` per question like admission.
"""

from typing import Literal, Optional

from pydantic import BaseModel, Field

from .common import Option, QuestionImage, QuestionRegion


class HscMcqQuestion(BaseModel):
    board_name: Optional[str] = Field(
        None,
        description=(
            "HSC board name normalised to English, e.g. 'Dhaka Board', 'Rajshahi Board', "
            "'Comilla Board'. Printed as 'ঢাকা বোর্ড' etc. on the page — return English."
        ),
    )
    exam_year: Optional[str] = Field(
        None,
        description="Single exam year as 4-digit string, e.g. '2023'. Not a session range.",
    )
    subject: Optional[str] = Field(
        None,
        description="Subject of the question, lowercase snake_case.",
    )
    subject_paper: Optional[Literal["1", "2"]] = Field(
        None,
        description=(
            "'1' for 1st Paper, '2' for 2nd Paper. Only meaningful for subjects with a paper "
            "split (physics/chemistry/mathematics/biology). Null for bangla/english/etc."
        ),
    )
    chapter: Optional[str] = Field(
        None,
        description="Chapter key from CHAPTER_TAXONOMY for this subject (+ paper if fixed).",
    )
    question_number: str = Field(...)
    question_text: str = Field(...)
    options: list[Option] = Field(...)
    correct_answer: Optional[str] = Field(None)
    images: list[QuestionImage] = Field(
        default_factory=list,
        description=(
            "One entry per diagram/figure/graph/circuit/table for this question. "
            "Ids IMAGE_1, IMAGE_2, ... each referenced as a [IMAGE_N] token in "
            "question_text or options[].text. Pass 1 fills id/kind/caption_hint/label "
            "only — leaves spatial fields null."
        ),
    )
    question_region: Optional[QuestionRegion] = Field(
        None,
        description=(
            "Bounding box of the WHOLE question on its page. Required only if "
            "`images` is non-empty — pass 2 uses this to crop just the question's "
            "portion of the page before localising diagrams. Null for pure-text questions."
        ),
    )


class HscMcqPageExtraction(BaseModel):
    questions: list[HscMcqQuestion] = Field(default_factory=list)
    tail_text: str = Field("")
    last_question_incomplete: bool = Field(False)


class HscMcqPdfExtraction(BaseModel):
    source_filename: str
    page_count: int
    questions: list[HscMcqQuestion]

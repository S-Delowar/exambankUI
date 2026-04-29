"""Admission-test written (short-answer / essay) extraction schemas.

Written admission questions have a flat stem (no uddipak + sub-parts structure,
unlike HSC written). Same metadata as admission MCQ, minus options and answer.
"""

from typing import Optional

from pydantic import BaseModel, Field

from .common import QuestionImage, QuestionRegion


class AdmissionWrittenQuestion(BaseModel):
    university_name: Optional[str] = Field(None)
    exam_session: Optional[str] = Field(None)
    exam_unit: Optional[str] = Field(None)
    subject: Optional[str] = Field(
        None,
        description="Subject of the question, lowercase snake_case. MUST be one of DECLARED_SUBJECTS.",
    )
    chapter: Optional[str] = Field(
        None,
        description="Chapter key from CHAPTER_TAXONOMY for this subject. Null if no chapter fits.",
    )
    question_number: str = Field(..., description="As printed; preserve suffixes like '(a)'.")
    question_text: str = Field(
        ...,
        description="Full question stem. Math/chemistry/image rules identical to MCQ.",
    )
    images: list[QuestionImage] = Field(
        default_factory=list,
        description=(
            "One entry for every diagram/figure/graph/table belonging to this "
            "question. Use sequential ids IMAGE_1, IMAGE_2, ... and reference each "
            "as a [IMAGE_N] token at the exact position in question_text. Pass 1 "
            "fills id/kind/caption_hint/label only — leaves spatial fields null."
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


class AdmissionWrittenPageExtraction(BaseModel):
    questions: list[AdmissionWrittenQuestion] = Field(default_factory=list)
    tail_text: str = Field("")
    last_question_incomplete: bool = Field(False)


class AdmissionWrittenPdfExtraction(BaseModel):
    source_filename: str
    page_count: int
    questions: list[AdmissionWrittenQuestion]

"""Admission-test MCQ extraction schemas.

Admission PDFs are typically multi-subject (Physics + Chemistry + Math + ...).
The model infers `subject` per question from section headers. The client
declares the full set of subjects present via the upload-time `subjects`
checkbox so the prompt can scope the chapter taxonomy.
"""

from typing import Optional

from pydantic import BaseModel, Field

from .common import Option, QuestionImage, QuestionRegion


class AdmissionMcqQuestion(BaseModel):
    university_name: Optional[str] = Field(
        None,
        description="Full or abbreviated university name (e.g. 'Dhaka University', 'DU', 'RU').",
    )
    exam_session: Optional[str] = Field(
        None,
        description=(
            "Bangladeshi admission-test academic session, normalised to 4-4 digits, "
            "e.g. '2010-2011'. Accepts printed forms like '2010-11' or 'সেশন ২০১০-১১' but "
            "must be returned as the full 4-4 form. Null if not printed anywhere in the PDF."
        ),
    )
    exam_unit: Optional[str] = Field(
        None,
        description="Exam unit/group (e.g. 'A', 'B', 'Ga', 'ক', 'খ').",
    )
    subject: Optional[str] = Field(
        None,
        description=(
            "Subject of the question, lowercase snake_case. MUST be one of the subjects "
            "declared by the uploader (shown in DECLARED_SUBJECTS). Null only if truly unknown."
        ),
    )
    chapter: Optional[str] = Field(
        None,
        description=(
            "Chapter key from the subject's list in CHAPTER_TAXONOMY. MUST be one of the "
            "listed chapters for this question's subject, matched by the exact snake_case key. "
            "Null if no chapter fits confidently. Never invent a chapter name."
        ),
    )
    question_number: str = Field(
        ...,
        description="Question number as printed, kept as string (supports '1', '12', '1(a)', '১২').",
    )
    question_text: str = Field(
        ...,
        description=(
            "Full question stem. Math MUST be LaTeX in $...$ (inline) or $$...$$ (display). "
            "Chemistry via \\ce{...} (mhchem). Preserve Bangla Unicode outside math."
        ),
    )
    options: list[Option] = Field(
        ..., description="All printed options for this question."
    )
    correct_answer: Optional[str] = Field(
        None,
        description="Label of the correct option (must match one of options[].label). Null if not printed.",
    )
    images: list[QuestionImage] = Field(
        default_factory=list,
        description=(
            "One entry for every diagram/figure/graph/circuit/table belonging to "
            "this question. Use sequential ids IMAGE_1, IMAGE_2, ... and reference "
            "each id as a [IMAGE_N] token at the exact position in question_text or "
            "options[].text. Empty list if the question is pure text. Pass 1 fills "
            "id/kind/caption_hint/label only — leaves spatial fields null."
        ),
    )
    question_region: Optional[QuestionRegion] = Field(
        None,
        description=(
            "Bounding box of the WHOLE question on its page (number + stem + options "
            "+ diagrams). Required only if `images` is non-empty — pass 2 uses this "
            "to crop just the question's portion of the page before localising "
            "diagrams. Null for pure-text questions."
        ),
    )


class AdmissionMcqPageExtraction(BaseModel):
    questions: list[AdmissionMcqQuestion] = Field(
        default_factory=list,
        description="All complete questions on this page (including any continued from the previous page).",
    )
    tail_text: str = Field(
        "",
        description="Verbatim raw text of the last visible question on the page (~600 chars), used to stitch with the next page.",
    )
    last_question_incomplete: bool = Field(
        False,
        description="True if the last question on this page is visibly cut off (missing options or truncated).",
    )


class AdmissionMcqPdfExtraction(BaseModel):
    source_filename: str
    page_count: int
    questions: list[AdmissionMcqQuestion]

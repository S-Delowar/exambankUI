"""HSC board written (creative question / সৃজনশীল) extraction schemas.

Every HSC written question is a "creative question": a stimulus passage (উদ্দীপক,
uddipak) followed by sub-parts. Two patterns exist:

  - Most subjects: 4 sub-parts (a=1, b=2, c=3, d=4 marks, total 10)
  - Mathematics:   3 sub-parts (a=2, b=4, c=4 marks, total 10)
"""

from typing import Literal, Optional

from pydantic import BaseModel, Field

from .common import QuestionImage, QuestionRegion
from .uddipok import Uddipok


class HscWrittenSubpart(BaseModel):
    label: Literal["a", "b", "c", "d"] = Field(
        ..., description="Sub-part label; one of a/b/c (math) or a/b/c/d (other subjects)."
    )
    marks: int = Field(
        ...,
        ge=1,
        le=10,
        description=(
            "Marks for this sub-part. Two patterns: "
            "most subjects: a=1, b=2, c=3, d=4. "
            "Mathematics: a=2, b=4, c=4."
        ),
    )
    text: str = Field(
        ..., description="Sub-question text with math/chemistry/image rules applied."
    )


class HscWrittenQuestion(BaseModel):
    board_name: Optional[str] = Field(None)
    exam_year: Optional[str] = Field(None)
    subject: Optional[str] = Field(None)
    subject_paper: Optional[Literal["1", "2"]] = Field(None)
    question_number: str = Field(
        ..., description="Question number as printed (e.g. '১', '1', '৭')."
    )
    uddipok_id: str = Field(
        ...,
        description=(
            "Reference to uddipok ID (e.g., 'UDDIPOK_1'). Every written question has "
            "an uddipok. Extract the uddipok into the uddipoks array and reference it here."
        ),
    )
    sub_questions: list[HscWrittenSubpart] = Field(
        ...,
        description=(
            "Sub-parts in order. Most subjects: 4 parts (a=1, b=2, c=3, d=4). "
            "Mathematics: 3 parts (a=2, b=4, c=4). "
            "Emit exactly 3 or 4 depending on subject."
        ),
        min_length=3,
        max_length=4,
    )
    images: list[QuestionImage] = Field(
        default_factory=list,
        description=(
            "One entry per diagram/figure/graph/table belonging to this question. "
            "Ids IMAGE_1, IMAGE_2, ... each referenced as a [IMAGE_N] token at "
            "the exact position inside uddipak_text OR any sub_questions[].text. "
            "A single question has ONE images[] array — ids are unique across the "
            "uddipak and all 4 sub-parts combined. Pass 1 fills id/kind/caption_hint/label "
            "only — leaves spatial fields null."
        ),
    )
    question_regions: list[QuestionRegion] = Field(
        default_factory=list,
        description=(
            "Bounding boxes of the question on EACH page it appears on (HSC creative "
            "questions can span multiple pages — uddipak on one page, sub-parts on "
            "the next). Required only if `images` is non-empty. One QuestionRegion "
            "per page, in page-order. Pass 2 crops each region and concatenates them "
            "vertically before localising diagrams."
        ),
    )


class HscWrittenPageExtraction(BaseModel):
    uddipoks: list[Uddipok] = Field(
        default_factory=list,
        description=(
            "All uddipoks (stimulus passages) on this page. Every written question "
            "references an uddipok via uddipok_id."
        ),
    )
    questions: list[HscWrittenQuestion] = Field(default_factory=list)
    tail_text: str = Field(
        "",
        description=(
            "Verbatim raw text of the last visible (possibly partial) question on the page, "
            "including uddipak and any sub-parts visible. Used to stitch across pages."
        ),
    )
    last_question_incomplete: bool = Field(
        False,
        description=(
            "True if the last question on this page does NOT have all expected sub-parts "
            "visible (3 for math, 4 for others). E.g., uddipak only, or fewer parts than expected."
        ),
    )


class HscWrittenPdfExtraction(BaseModel):
    source_filename: str
    page_count: int
    uddipoks: list[Uddipok] = Field(
        default_factory=list,
        description="All unique uddipoks across the entire PDF, deduplicated by uddipok_id.",
    )
    questions: list[HscWrittenQuestion]

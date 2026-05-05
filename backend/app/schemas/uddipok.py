"""Uddipok (stimulus/passage) extraction schemas.

Used during extraction to represent uddipoks before they're persisted to the
database. The uddipok_id is a temporary identifier (e.g., "UDDIPOK_1") that
questions use to reference their uddipok within a single extraction batch.
"""

from pydantic import BaseModel, Field

from .common import QuestionImage


class Uddipok(BaseModel):
    """Uddipok extracted from a page.
    
    Multiple questions can reference the same uddipok via uddipok_id.
    """
    uddipok_id: str = Field(
        ...,
        description=(
            "Temporary identifier for this uddipok within the extraction batch. "
            "Use format 'UDDIPOK_1', 'UDDIPOK_2', etc. Questions reference this ID."
        ),
    )
    text: str = Field(
        ...,
        description=(
            "Full uddipok text. Apply MATH & CHEMISTRY formatting rules. "
            "If the uddipok includes a figure/diagram/graph/chart, insert [IMAGE_N] "
            "token at the exact position."
        ),
    )
    has_image: bool = Field(
        default=False,
        description="True if text contains [IMAGE_N] tokens, else false.",
    )
    images: list[QuestionImage] = Field(
        default_factory=list,
        description=(
            "Image metadata for figures in the uddipok. Same format as question images."
        ),
    )

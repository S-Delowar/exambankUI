"""add per-question images JSONB + broaden has_image pattern to match [IMAGE_N]

Revision ID: 0005
Revises: 0004
Create Date: 2026-04-21
"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects.postgresql import JSONB

revision: str = "0005"
down_revision: Union[str, None] = "0004"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


# The 4 question tables + the HSC subpart table each have a `has_image`
# generated column that currently matches `%[IMAGE]%`. The prompt now emits
# numbered tokens `[IMAGE_1]`, `[IMAGE_2]`, ..., which the old pattern would
# miss. Broaden to `%[IMAGE%` so both legacy and new tokens count.
_HAS_IMAGE_TABLES = [
    ("admission_mcq_questions", "question_text"),
    ("admission_written_questions", "question_text"),
    ("hsc_mcq_questions", "question_text"),
    ("hsc_written_subparts", "text"),
]


def _recreate_has_image(table: str, text_col: str, pattern: str) -> None:
    """Generated columns can't be ALTERed; drop and re-add with the new formula."""
    op.drop_column(table, "has_image")
    op.add_column(
        table,
        sa.Column(
            "has_image",
            sa.Boolean(),
            sa.Computed(f"{text_col} LIKE '{pattern}'", persisted=True),
            nullable=False,
        ),
    )
    op.create_index(f"ix_{table}_has_image", table, ["has_image"])


def upgrade() -> None:
    # 1. Add `images` JSONB columns to the 4 question-owning tables.
    for table in (
        "admission_mcq_questions",
        "admission_written_questions",
        "hsc_mcq_questions",
        "hsc_written_questions",
    ):
        op.add_column(
            table,
            sa.Column("images", JSONB(), nullable=True),
        )

    # 2. Broaden `has_image` patterns to match numbered tokens.
    for table, text_col in _HAS_IMAGE_TABLES:
        _recreate_has_image(table, text_col, "%[IMAGE%")


def downgrade() -> None:
    for table, text_col in _HAS_IMAGE_TABLES:
        _recreate_has_image(table, text_col, "%[IMAGE]%")

    for table in (
        "admission_mcq_questions",
        "admission_written_questions",
        "hsc_mcq_questions",
        "hsc_written_questions",
    ):
        op.drop_column(table, "images")

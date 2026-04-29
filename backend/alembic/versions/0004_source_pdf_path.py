"""add exam_papers.source_pdf_path (stores original uploaded PDF path)

Revision ID: 0004
Revises: 0003
Create Date: 2026-04-18
"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "0004"
down_revision: Union[str, None] = "0003"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "exam_papers",
        sa.Column("source_pdf_path", sa.Text(), nullable=True),
    )


def downgrade() -> None:
    op.drop_column("exam_papers", "source_pdf_path")

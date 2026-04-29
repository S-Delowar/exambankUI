"""add image_filename to MCQ option tables

Revision ID: 0006
Revises: 0005
Create Date: 2026-04-27
"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "0006"
down_revision: Union[str, None] = "0005"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


_OPTION_TABLES = ("admission_mcq_options", "hsc_mcq_options")


def upgrade() -> None:
    for table in _OPTION_TABLES:
        op.add_column(table, sa.Column("image_filename", sa.Text(), nullable=True))


def downgrade() -> None:
    for table in _OPTION_TABLES:
        op.drop_column(table, "image_filename")

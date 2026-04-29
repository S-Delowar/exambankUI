"""add_gemini_fields_to_hsc_mcq

Revision ID: e5d31493a649
Revises: 43f2a85d37b7
Create Date: 2026-04-29 14:49:51.020157

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'e5d31493a649'
down_revision: Union[str, None] = '43f2a85d37b7'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column('hsc_mcq_questions', sa.Column('gemini_solution', sa.Text(), nullable=True))
    op.add_column('hsc_mcq_questions', sa.Column('gemini_correct_answer', sa.String(length=16), nullable=True))


def downgrade() -> None:
    op.drop_column('hsc_mcq_questions', 'gemini_correct_answer')
    op.drop_column('hsc_mcq_questions', 'gemini_solution')

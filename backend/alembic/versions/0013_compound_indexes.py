"""compound_indexes_for_common_queries

Revision ID: 0013_compound_indexes
Revises: 0012_polymorphic_bk_att
Create Date: 2026-05-11 13:00:00.000000

Add compound indexes for drill queries (subject, chapter) and attempt
aggregation patterns.
"""
from typing import Sequence, Union

from alembic import op

# revision identifiers, used by Alembic.
revision: str = '0013_compound_indexes'
down_revision: Union[str, None] = '0012_polymorphic_bk_att'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Drill queries filter by (subject, chapter) with correct_answer IS NOT NULL.
    op.create_index(
        "ix_admission_mcq_q_subject_chapter",
        "admission_mcq_questions",
        ["subject", "chapter"],
    )
    op.create_index(
        "ix_hsc_mcq_q_subject_chapter",
        "hsc_mcq_questions",
        ["subject", "chapter"],
    )

    # Attempt submission aggregates by (attempt_id, question_id) — the existing
    # indexes cover these individually, but a compound on attempt_answers helps
    # the submit_attempt JOIN with question tables.
    op.create_index(
        "ix_attempt_answers_attempt_question",
        "attempt_answers",
        ["attempt_id", "question_id"],
    )


def downgrade() -> None:
    op.drop_index("ix_attempt_answers_attempt_question", "attempt_answers")
    op.drop_index("ix_hsc_mcq_q_subject_chapter", "hsc_mcq_questions")
    op.drop_index("ix_admission_mcq_q_subject_chapter", "admission_mcq_questions")

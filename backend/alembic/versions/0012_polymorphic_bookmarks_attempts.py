"""polymorphic_bookmarks_and_attempt_answers

Revision ID: 0012_polymorphic_bk_att
Revises: 0011_extraction_workflows
Create Date: 2026-05-11 12:00:00.000000

Drop hard FK from bookmarks.question_id and attempt_answers.question_id
to admission_mcq_questions. Add (exam_type, question_type) columns so any
of the 4 question tables can be referenced. Validation moves to the
service layer.
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision: str = '0012_polymorphic_bk_att'
down_revision: Union[str, None] = '0011_extraction_workflows'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # -- bookmarks --
    # Drop the FK constraint to admission_mcq_questions.
    op.drop_constraint(
        "bookmarks_question_id_fkey", "bookmarks", type_="foreignkey"
    )
    # Drop the old unique constraint (user_id, question_id) and replace with
    # a wider one that includes the question type dimensions.
    op.drop_constraint(
        "uq_bookmarks_user_question", "bookmarks", type_="unique"
    )
    # Add type discriminator columns (defaulting to admission_test/mcq for
    # existing rows).
    op.add_column(
        "bookmarks",
        sa.Column(
            "exam_type", sa.String(32), nullable=False,
            server_default="admission_test",
        ),
    )
    op.add_column(
        "bookmarks",
        sa.Column(
            "question_type", sa.String(16), nullable=False,
            server_default="mcq",
        ),
    )
    op.create_unique_constraint(
        "uq_bookmarks_user_question",
        "bookmarks",
        ["user_id", "question_id", "exam_type", "question_type"],
    )
    op.create_index(
        "ix_bookmarks_question_id", "bookmarks", ["question_id"],
    )

    # -- attempt_answers --
    op.drop_constraint(
        "attempt_answers_question_id_fkey", "attempt_answers", type_="foreignkey"
    )
    op.add_column(
        "attempt_answers",
        sa.Column(
            "exam_type", sa.String(32), nullable=False,
            server_default="admission_test",
        ),
    )
    op.add_column(
        "attempt_answers",
        sa.Column(
            "question_type", sa.String(16), nullable=False,
            server_default="mcq",
        ),
    )


def downgrade() -> None:
    # -- attempt_answers --
    op.drop_column("attempt_answers", "question_type")
    op.drop_column("attempt_answers", "exam_type")
    op.create_foreign_key(
        "attempt_answers_question_id_fkey",
        "attempt_answers", "admission_mcq_questions",
        ["question_id"], ["id"],
        ondelete="CASCADE",
    )

    # -- bookmarks --
    op.drop_index("ix_bookmarks_question_id", "bookmarks")
    op.drop_constraint(
        "uq_bookmarks_user_question", "bookmarks", type_="unique"
    )
    op.drop_column("bookmarks", "question_type")
    op.drop_column("bookmarks", "exam_type")
    op.create_unique_constraint(
        "uq_bookmarks_user_question",
        "bookmarks",
        ["user_id", "question_id"],
    )
    op.create_foreign_key(
        "bookmarks_question_id_fkey",
        "bookmarks", "admission_mcq_questions",
        ["question_id"], ["id"],
        ondelete="CASCADE",
    )

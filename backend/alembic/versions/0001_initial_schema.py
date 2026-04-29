"""initial schema: exam_papers, questions, options

Revision ID: 0001
Revises:
Create Date: 2026-04-18

"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision: str = "0001"
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "exam_papers",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("source_filename", sa.Text(), nullable=False),
        sa.Column("university_name", sa.Text(), nullable=True),
        sa.Column("exam_session", sa.Text(), nullable=True),
        sa.Column("exam_unit", sa.Text(), nullable=True),
        sa.Column("page_count", sa.Integer(), nullable=False),
        sa.Column("output_json_path", sa.Text(), nullable=True),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.func.now(),
            nullable=False,
        ),
    )

    op.create_table(
        "questions",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column(
            "paper_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("exam_papers.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("question_number", sa.String(length=32), nullable=False),
        sa.Column("question_text", sa.Text(), nullable=False),
        sa.Column("subject", sa.String(length=64), nullable=True),
        sa.Column("chapter", sa.String(length=128), nullable=True),
        sa.Column("correct_answer", sa.String(length=16), nullable=True),
        sa.Column("solution", sa.Text(), nullable=True),
        sa.Column(
            "solution_status",
            sa.String(length=16),
            nullable=False,
            server_default="pending",
        ),
        sa.Column(
            "has_image",
            sa.Boolean(),
            sa.Computed("question_text LIKE '%[IMAGE]%'", persisted=True),
            nullable=False,
        ),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.func.now(),
            nullable=False,
        ),
    )
    op.create_index("ix_questions_paper_id", "questions", ["paper_id"])
    op.create_index("ix_questions_subject", "questions", ["subject"])
    op.create_index("ix_questions_chapter", "questions", ["chapter"])
    op.create_index("ix_questions_solution_status", "questions", ["solution_status"])
    op.create_index("ix_questions_has_image", "questions", ["has_image"])

    op.create_table(
        "options",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column(
            "question_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("questions.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("label", sa.String(length=16), nullable=False),
        sa.Column("text", sa.Text(), nullable=False),
        sa.Column("display_order", sa.Integer(), nullable=False),
    )
    op.create_index("ix_options_question_id", "options", ["question_id"])


def downgrade() -> None:
    op.drop_index("ix_options_question_id", table_name="options")
    op.drop_table("options")
    op.drop_index("ix_questions_has_image", table_name="questions")
    op.drop_index("ix_questions_solution_status", table_name="questions")
    op.drop_index("ix_questions_chapter", table_name="questions")
    op.drop_index("ix_questions_subject", table_name="questions")
    op.drop_index("ix_questions_paper_id", table_name="questions")
    op.drop_table("questions")
    op.drop_table("exam_papers")

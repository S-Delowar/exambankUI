"""quiz_status table + attempts.exam_type for (subject, exam_type) quizzes

Revision ID: 0008
Revises: 0007
Create Date: 2026-04-28
"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "0008"
down_revision: Union[str, None] = "0007"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # 1. attempts.exam_type — nullable so existing rows don't blow up. New
    #    subject_quiz / drill / exam attempts will populate it.
    op.add_column(
        "attempts",
        sa.Column("exam_type", sa.String(length=32), nullable=True),
    )
    op.create_index(
        "ix_attempts_subject_exam",
        "attempts",
        ["drill_subject", "exam_type"],
    )

    # 2. quiz_status — composite PK on (subject, exam_type). Status is the
    #    publish state students see; absence of a row is treated as draft by
    #    the resolver.
    op.create_table(
        "quiz_status",
        sa.Column("subject", sa.String(length=64), nullable=False),
        sa.Column("exam_type", sa.String(length=32), nullable=False),
        sa.Column("status", sa.String(length=16), nullable=False, server_default="draft"),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.func.now(),
        ),
        sa.Column("updated_by_id", sa.dialects.postgresql.UUID(as_uuid=True), nullable=True),
        sa.PrimaryKeyConstraint("subject", "exam_type", name="pk_quiz_status"),
        sa.ForeignKeyConstraint(
            ["updated_by_id"],
            ["users.id"],
            name="fk_quiz_status_updated_by",
            ondelete="SET NULL",
        ),
        sa.CheckConstraint(
            "status IN ('draft','published','archived')",
            name="ck_quiz_status_status",
        ),
    )


def downgrade() -> None:
    op.drop_table("quiz_status")
    op.drop_index("ix_attempts_subject_exam", table_name="attempts")
    op.drop_column("attempts", "exam_type")

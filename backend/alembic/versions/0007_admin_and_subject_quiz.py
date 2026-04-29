"""add users.is_admin; allow attempts.kind='subject_quiz'

Revision ID: 0007
Revises: 0006
Create Date: 2026-04-28
"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "0007"
down_revision: Union[str, None] = "0006"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "users",
        sa.Column(
            "is_admin",
            sa.Boolean(),
            nullable=False,
            server_default=sa.text("false"),
        ),
    )

    op.drop_constraint("ck_attempts_kind", "attempts", type_="check")
    op.drop_constraint("ck_attempts_kind_shape", "attempts", type_="check")
    op.create_check_constraint(
        "ck_attempts_kind",
        "attempts",
        "kind IN ('exam','drill','subject_quiz')",
    )
    op.create_check_constraint(
        "ck_attempts_kind_shape",
        "attempts",
        "(kind='exam' AND paper_id IS NOT NULL) OR "
        "(kind='drill' AND drill_subject IS NOT NULL AND drill_chapter IS NOT NULL) OR "
        "(kind='subject_quiz' AND drill_subject IS NOT NULL)",
    )


def downgrade() -> None:
    op.drop_constraint("ck_attempts_kind_shape", "attempts", type_="check")
    op.drop_constraint("ck_attempts_kind", "attempts", type_="check")
    op.create_check_constraint(
        "ck_attempts_kind",
        "attempts",
        "kind IN ('exam','drill')",
    )
    op.create_check_constraint(
        "ck_attempts_kind_shape",
        "attempts",
        "(kind='exam' AND paper_id IS NOT NULL) OR "
        "(kind='drill' AND drill_subject IS NOT NULL AND drill_chapter IS NOT NULL)",
    )

    op.drop_column("users", "is_admin")

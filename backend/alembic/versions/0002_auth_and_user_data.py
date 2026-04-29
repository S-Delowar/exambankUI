"""auth + user data: users, refresh_tokens, bookmarks, attempts, attempt_answers

Revision ID: 0002
Revises: 0001
Create Date: 2026-04-18

"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision: str = "0002"
down_revision: Union[str, None] = "0001"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # users
    op.create_table(
        "users",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("email", sa.Text(), nullable=False, unique=True),
        sa.Column("password_hash", sa.Text(), nullable=False),
        sa.Column("display_name", sa.Text(), nullable=True),
        sa.Column(
            "is_active", sa.Boolean(), nullable=False, server_default=sa.text("true")
        ),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.func.now(),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.func.now(),
            nullable=False,
        ),
    )
    op.create_index(
        "uq_users_email_lower",
        "users",
        [sa.text("lower(email)")],
        unique=True,
    )

    # refresh_tokens
    op.create_table(
        "refresh_tokens",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column(
            "user_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("users.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("token_hash", sa.Text(), nullable=False, unique=True),
        sa.Column(
            "issued_at",
            sa.DateTime(timezone=True),
            server_default=sa.func.now(),
            nullable=False,
        ),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("revoked_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column(
            "replaced_by_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("refresh_tokens.id", ondelete="SET NULL"),
            nullable=True,
        ),
        sa.Column("user_agent", sa.Text(), nullable=True),
        sa.Column("ip", sa.Text(), nullable=True),
    )
    op.create_index("ix_refresh_tokens_user_id", "refresh_tokens", ["user_id"])
    op.create_index("ix_refresh_tokens_expires_at", "refresh_tokens", ["expires_at"])

    # bookmarks
    op.create_table(
        "bookmarks",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column(
            "user_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("users.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column(
            "question_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("questions.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.func.now(),
            nullable=False,
        ),
        sa.UniqueConstraint("user_id", "question_id", name="uq_bookmarks_user_question"),
    )
    op.create_index("ix_bookmarks_user_id", "bookmarks", ["user_id"])
    op.create_index(
        "ix_bookmarks_user_created_at",
        "bookmarks",
        ["user_id", sa.text("created_at DESC")],
    )

    # attempts
    op.create_table(
        "attempts",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column(
            "user_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("users.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("kind", sa.String(length=16), nullable=False),
        sa.Column("mode", sa.String(length=16), nullable=False),
        sa.Column(
            "paper_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("exam_papers.id", ondelete="SET NULL"),
            nullable=True,
        ),
        sa.Column("drill_subject", sa.String(length=64), nullable=True),
        sa.Column("drill_chapter", sa.String(length=128), nullable=True),
        sa.Column("duration_sec", sa.Integer(), nullable=True),
        sa.Column(
            "question_ids",
            postgresql.ARRAY(postgresql.UUID(as_uuid=True)),
            nullable=False,
        ),
        sa.Column(
            "status",
            sa.String(length=16),
            nullable=False,
            server_default="in_progress",
        ),
        sa.Column(
            "started_at",
            sa.DateTime(timezone=True),
            server_default=sa.func.now(),
            nullable=False,
        ),
        sa.Column("submitted_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("score_correct", sa.Integer(), nullable=True),
        sa.Column("score_total", sa.Integer(), nullable=True),
        sa.Column("elapsed_sec", sa.Integer(), nullable=True),
        sa.CheckConstraint("kind IN ('exam','drill')", name="ck_attempts_kind"),
        sa.CheckConstraint("mode IN ('timed','untimed')", name="ck_attempts_mode"),
        sa.CheckConstraint(
            "status IN ('in_progress','submitted','abandoned')",
            name="ck_attempts_status",
        ),
        sa.CheckConstraint(
            "(kind='exam' AND paper_id IS NOT NULL) OR "
            "(kind='drill' AND drill_subject IS NOT NULL AND drill_chapter IS NOT NULL)",
            name="ck_attempts_kind_shape",
        ),
    )
    op.create_index("ix_attempts_user_id", "attempts", ["user_id"])
    op.create_index(
        "ix_attempts_user_started",
        "attempts",
        ["user_id", sa.text("started_at DESC")],
    )
    op.create_index(
        "ix_attempts_user_submitted", "attempts", ["user_id", "submitted_at"]
    )
    op.create_index("ix_attempts_paper_id", "attempts", ["paper_id"])

    # attempt_answers
    op.create_table(
        "attempt_answers",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column(
            "attempt_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("attempts.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column(
            "question_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("questions.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("selected_label", sa.String(length=16), nullable=False),
        sa.Column("is_correct", sa.Boolean(), nullable=False),
        sa.Column(
            "answered_at",
            sa.DateTime(timezone=True),
            server_default=sa.func.now(),
            nullable=False,
        ),
        sa.UniqueConstraint(
            "attempt_id", "question_id", name="uq_attempt_answers_attempt_question"
        ),
    )
    op.create_index(
        "ix_attempt_answers_attempt_id", "attempt_answers", ["attempt_id"]
    )
    op.create_index(
        "ix_attempt_answers_question_id", "attempt_answers", ["question_id"]
    )


def downgrade() -> None:
    op.drop_index("ix_attempt_answers_question_id", table_name="attempt_answers")
    op.drop_index("ix_attempt_answers_attempt_id", table_name="attempt_answers")
    op.drop_table("attempt_answers")

    op.drop_index("ix_attempts_paper_id", table_name="attempts")
    op.drop_index("ix_attempts_user_submitted", table_name="attempts")
    op.drop_index("ix_attempts_user_started", table_name="attempts")
    op.drop_index("ix_attempts_user_id", table_name="attempts")
    op.drop_table("attempts")

    op.drop_index("ix_bookmarks_user_created_at", table_name="bookmarks")
    op.drop_index("ix_bookmarks_user_id", table_name="bookmarks")
    op.drop_table("bookmarks")

    op.drop_index("ix_refresh_tokens_expires_at", table_name="refresh_tokens")
    op.drop_index("ix_refresh_tokens_user_id", table_name="refresh_tokens")
    op.drop_table("refresh_tokens")

    op.drop_index("uq_users_email_lower", table_name="users")
    op.drop_table("users")

"""exam_type/question_type split: rename questions -> admission_mcq, add 5 new tables

Revision ID: 0003
Revises: 0002
Create Date: 2026-04-18

This migration splits the single `questions` / `options` pair into four parallel
question tables, discriminated by (exam_type, question_type) on the shared
`exam_papers` parent row.

Steps:
  1. Add discriminator + denorm columns to `exam_papers` (nullable + backfill +
     NOT NULL where appropriate).
  2. Rename `questions` -> `admission_mcq_questions` and `options` ->
     `admission_mcq_options`. Rename indexes to match. This preserves all
     existing data and existing FKs (bookmarks.question_id,
     attempt_answers.question_id) because Postgres rewrites FK targets
     automatically on ALTER TABLE ... RENAME.
  3. Also copy the per-question denorm columns (university_name, exam_session,
     exam_unit) onto the new `admission_mcq_questions` table — these were
     previously only on the paper; storing them per-row matches the new model
     and keeps query shapes uniform across all four question tables.
  4. Create `admission_written_questions`, `hsc_mcq_questions`,
     `hsc_mcq_options`, `hsc_written_questions`, `hsc_written_subparts`.
"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision: str = "0003"
down_revision: Union[str, None] = "0002"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # --- 1. exam_papers: discriminators + denorm fields ---------------------
    op.add_column(
        "exam_papers",
        sa.Column(
            "exam_type",
            sa.String(length=32),
            nullable=True,
        ),
    )
    op.add_column(
        "exam_papers",
        sa.Column(
            "question_type",
            sa.String(length=16),
            nullable=True,
        ),
    )
    op.add_column("exam_papers", sa.Column("board_name", sa.Text(), nullable=True))
    op.add_column("exam_papers", sa.Column("exam_year", sa.String(length=8), nullable=True))
    op.add_column("exam_papers", sa.Column("subject", sa.String(length=64), nullable=True))
    op.add_column("exam_papers", sa.Column("subject_paper", sa.String(length=2), nullable=True))

    # Backfill every existing row to admission MCQ (that's the only flow that
    # existed before this migration).
    op.execute("UPDATE exam_papers SET exam_type = 'admission_test' WHERE exam_type IS NULL")
    op.execute("UPDATE exam_papers SET question_type = 'mcq' WHERE question_type IS NULL")

    op.alter_column(
        "exam_papers",
        "exam_type",
        existing_type=sa.String(length=32),
        nullable=False,
        server_default="admission_test",
    )
    op.alter_column(
        "exam_papers",
        "question_type",
        existing_type=sa.String(length=16),
        nullable=False,
        server_default="mcq",
    )
    op.create_index("ix_exam_papers_exam_type", "exam_papers", ["exam_type"])
    op.create_index("ix_exam_papers_question_type", "exam_papers", ["question_type"])

    # --- 2. Rename questions/options -> admission_mcq_* ---------------------
    op.rename_table("questions", "admission_mcq_questions")
    op.rename_table("options", "admission_mcq_options")

    # Rename the existing indexes to match the new table names.
    op.execute("ALTER INDEX ix_questions_paper_id RENAME TO ix_admission_mcq_questions_paper_id")
    op.execute("ALTER INDEX ix_questions_subject RENAME TO ix_admission_mcq_questions_subject")
    op.execute("ALTER INDEX ix_questions_chapter RENAME TO ix_admission_mcq_questions_chapter")
    op.execute(
        "ALTER INDEX ix_questions_solution_status RENAME TO ix_admission_mcq_questions_solution_status"
    )
    op.execute("ALTER INDEX ix_questions_has_image RENAME TO ix_admission_mcq_questions_has_image")
    op.execute("ALTER INDEX ix_options_question_id RENAME TO ix_admission_mcq_options_question_id")

    # --- 3. Per-row admission denorm columns --------------------------------
    op.add_column(
        "admission_mcq_questions",
        sa.Column("university_name", sa.Text(), nullable=True),
    )
    op.add_column(
        "admission_mcq_questions",
        sa.Column("exam_session", sa.Text(), nullable=True),
    )
    op.add_column(
        "admission_mcq_questions",
        sa.Column("exam_unit", sa.Text(), nullable=True),
    )
    # Backfill from the parent paper so existing questions get the values they
    # would have been stamped with under the new schema.
    op.execute(
        """
        UPDATE admission_mcq_questions q
        SET university_name = p.university_name,
            exam_session    = p.exam_session,
            exam_unit       = p.exam_unit
        FROM exam_papers p
        WHERE q.paper_id = p.id
        """
    )

    # --- 4. New tables ------------------------------------------------------
    # admission_written_questions
    op.create_table(
        "admission_written_questions",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column(
            "paper_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("exam_papers.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("question_number", sa.String(length=32), nullable=False),
        sa.Column("question_text", sa.Text(), nullable=False),
        sa.Column("university_name", sa.Text(), nullable=True),
        sa.Column("exam_session", sa.Text(), nullable=True),
        sa.Column("exam_unit", sa.Text(), nullable=True),
        sa.Column("subject", sa.String(length=64), nullable=True),
        sa.Column("chapter", sa.String(length=128), nullable=True),
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
    op.create_index(
        "ix_admission_written_questions_paper_id",
        "admission_written_questions",
        ["paper_id"],
    )
    op.create_index(
        "ix_admission_written_questions_subject",
        "admission_written_questions",
        ["subject"],
    )
    op.create_index(
        "ix_admission_written_questions_chapter",
        "admission_written_questions",
        ["chapter"],
    )
    op.create_index(
        "ix_admission_written_questions_solution_status",
        "admission_written_questions",
        ["solution_status"],
    )
    op.create_index(
        "ix_admission_written_questions_has_image",
        "admission_written_questions",
        ["has_image"],
    )

    # hsc_mcq_questions
    op.create_table(
        "hsc_mcq_questions",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column(
            "paper_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("exam_papers.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("question_number", sa.String(length=32), nullable=False),
        sa.Column("question_text", sa.Text(), nullable=False),
        sa.Column("board_name", sa.Text(), nullable=True),
        sa.Column("exam_year", sa.String(length=8), nullable=True),
        sa.Column("subject", sa.String(length=64), nullable=True),
        sa.Column("subject_paper", sa.String(length=2), nullable=True),
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
    op.create_index("ix_hsc_mcq_questions_paper_id", "hsc_mcq_questions", ["paper_id"])
    op.create_index("ix_hsc_mcq_questions_board_name", "hsc_mcq_questions", ["board_name"])
    op.create_index("ix_hsc_mcq_questions_exam_year", "hsc_mcq_questions", ["exam_year"])
    op.create_index("ix_hsc_mcq_questions_subject", "hsc_mcq_questions", ["subject"])
    op.create_index(
        "ix_hsc_mcq_questions_subject_paper", "hsc_mcq_questions", ["subject_paper"]
    )
    op.create_index("ix_hsc_mcq_questions_chapter", "hsc_mcq_questions", ["chapter"])
    op.create_index(
        "ix_hsc_mcq_questions_solution_status", "hsc_mcq_questions", ["solution_status"]
    )
    op.create_index("ix_hsc_mcq_questions_has_image", "hsc_mcq_questions", ["has_image"])

    # hsc_mcq_options
    op.create_table(
        "hsc_mcq_options",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column(
            "question_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("hsc_mcq_questions.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("label", sa.String(length=16), nullable=False),
        sa.Column("text", sa.Text(), nullable=False),
        sa.Column("display_order", sa.Integer(), nullable=False),
    )
    op.create_index("ix_hsc_mcq_options_question_id", "hsc_mcq_options", ["question_id"])

    # hsc_written_questions
    op.create_table(
        "hsc_written_questions",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column(
            "paper_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("exam_papers.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("question_number", sa.String(length=32), nullable=False),
        sa.Column("board_name", sa.Text(), nullable=True),
        sa.Column("exam_year", sa.String(length=8), nullable=True),
        sa.Column("subject", sa.String(length=64), nullable=True),
        sa.Column("subject_paper", sa.String(length=2), nullable=True),
        sa.Column("uddipak_text", sa.Text(), nullable=False),
        sa.Column(
            "uddipak_has_image",
            sa.Boolean(),
            nullable=False,
            server_default=sa.text("false"),
        ),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.func.now(),
            nullable=False,
        ),
    )
    op.create_index("ix_hsc_written_questions_paper_id", "hsc_written_questions", ["paper_id"])
    op.create_index("ix_hsc_written_questions_board_name", "hsc_written_questions", ["board_name"])
    op.create_index("ix_hsc_written_questions_exam_year", "hsc_written_questions", ["exam_year"])
    op.create_index("ix_hsc_written_questions_subject", "hsc_written_questions", ["subject"])
    op.create_index(
        "ix_hsc_written_questions_subject_paper", "hsc_written_questions", ["subject_paper"]
    )
    op.create_index(
        "ix_hsc_written_questions_uddipak_has_image",
        "hsc_written_questions",
        ["uddipak_has_image"],
    )

    # hsc_written_subparts
    op.create_table(
        "hsc_written_subparts",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column(
            "question_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("hsc_written_questions.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("label", sa.String(length=1), nullable=False),
        sa.Column("marks", sa.Integer(), nullable=False),
        sa.Column("text", sa.Text(), nullable=False),
        sa.Column("display_order", sa.Integer(), nullable=False),
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
            sa.Computed("text LIKE '%[IMAGE]%'", persisted=True),
            nullable=False,
        ),
        sa.UniqueConstraint(
            "question_id",
            "label",
            name="uq_hsc_written_subparts_question_label",
        ),
    )
    op.create_index(
        "ix_hsc_written_subparts_question_id", "hsc_written_subparts", ["question_id"]
    )
    op.create_index(
        "ix_hsc_written_subparts_solution_status",
        "hsc_written_subparts",
        ["solution_status"],
    )
    op.create_index(
        "ix_hsc_written_subparts_has_image", "hsc_written_subparts", ["has_image"]
    )


def downgrade() -> None:
    # Drop new tables in reverse order of creation (respecting FKs).
    op.drop_index("ix_hsc_written_subparts_has_image", table_name="hsc_written_subparts")
    op.drop_index(
        "ix_hsc_written_subparts_solution_status", table_name="hsc_written_subparts"
    )
    op.drop_index("ix_hsc_written_subparts_question_id", table_name="hsc_written_subparts")
    op.drop_table("hsc_written_subparts")

    op.drop_index(
        "ix_hsc_written_questions_uddipak_has_image", table_name="hsc_written_questions"
    )
    op.drop_index(
        "ix_hsc_written_questions_subject_paper", table_name="hsc_written_questions"
    )
    op.drop_index("ix_hsc_written_questions_subject", table_name="hsc_written_questions")
    op.drop_index("ix_hsc_written_questions_exam_year", table_name="hsc_written_questions")
    op.drop_index("ix_hsc_written_questions_board_name", table_name="hsc_written_questions")
    op.drop_index("ix_hsc_written_questions_paper_id", table_name="hsc_written_questions")
    op.drop_table("hsc_written_questions")

    op.drop_index("ix_hsc_mcq_options_question_id", table_name="hsc_mcq_options")
    op.drop_table("hsc_mcq_options")

    op.drop_index("ix_hsc_mcq_questions_has_image", table_name="hsc_mcq_questions")
    op.drop_index("ix_hsc_mcq_questions_solution_status", table_name="hsc_mcq_questions")
    op.drop_index("ix_hsc_mcq_questions_chapter", table_name="hsc_mcq_questions")
    op.drop_index("ix_hsc_mcq_questions_subject_paper", table_name="hsc_mcq_questions")
    op.drop_index("ix_hsc_mcq_questions_subject", table_name="hsc_mcq_questions")
    op.drop_index("ix_hsc_mcq_questions_exam_year", table_name="hsc_mcq_questions")
    op.drop_index("ix_hsc_mcq_questions_board_name", table_name="hsc_mcq_questions")
    op.drop_index("ix_hsc_mcq_questions_paper_id", table_name="hsc_mcq_questions")
    op.drop_table("hsc_mcq_questions")

    op.drop_index(
        "ix_admission_written_questions_has_image", table_name="admission_written_questions"
    )
    op.drop_index(
        "ix_admission_written_questions_solution_status",
        table_name="admission_written_questions",
    )
    op.drop_index(
        "ix_admission_written_questions_chapter", table_name="admission_written_questions"
    )
    op.drop_index(
        "ix_admission_written_questions_subject", table_name="admission_written_questions"
    )
    op.drop_index(
        "ix_admission_written_questions_paper_id", table_name="admission_written_questions"
    )
    op.drop_table("admission_written_questions")

    # Drop the denorm columns we added onto admission_mcq_questions.
    op.drop_column("admission_mcq_questions", "exam_unit")
    op.drop_column("admission_mcq_questions", "exam_session")
    op.drop_column("admission_mcq_questions", "university_name")

    # Rename admission_mcq_* back to questions/options.
    op.execute(
        "ALTER INDEX ix_admission_mcq_options_question_id RENAME TO ix_options_question_id"
    )
    op.execute(
        "ALTER INDEX ix_admission_mcq_questions_has_image RENAME TO ix_questions_has_image"
    )
    op.execute(
        "ALTER INDEX ix_admission_mcq_questions_solution_status RENAME TO ix_questions_solution_status"
    )
    op.execute(
        "ALTER INDEX ix_admission_mcq_questions_chapter RENAME TO ix_questions_chapter"
    )
    op.execute(
        "ALTER INDEX ix_admission_mcq_questions_subject RENAME TO ix_questions_subject"
    )
    op.execute(
        "ALTER INDEX ix_admission_mcq_questions_paper_id RENAME TO ix_questions_paper_id"
    )
    op.rename_table("admission_mcq_options", "options")
    op.rename_table("admission_mcq_questions", "questions")

    # Drop exam_papers discriminators + denorm fields.
    op.drop_index("ix_exam_papers_question_type", table_name="exam_papers")
    op.drop_index("ix_exam_papers_exam_type", table_name="exam_papers")
    op.drop_column("exam_papers", "subject_paper")
    op.drop_column("exam_papers", "subject")
    op.drop_column("exam_papers", "exam_year")
    op.drop_column("exam_papers", "board_name")
    op.drop_column("exam_papers", "question_type")
    op.drop_column("exam_papers", "exam_type")

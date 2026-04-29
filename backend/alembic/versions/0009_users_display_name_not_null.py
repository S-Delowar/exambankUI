"""Make users.display_name NOT NULL.

Backfill any existing NULL rows with `User-<short-hex>` so the constraint
can be added without a data error. Today (the time this migration was
authored) every row already carries a display_name, but the backfill is
defensive — anyone running this against an older snapshot won't fail.

Revision ID: 0009
Revises: 0008
Create Date: 2026-04-28
"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "0009"
down_revision: Union[str, None] = "0008"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # 1. Backfill NULL display_name with `User-<short-hex>`. Postgres has no
    #    short-uuid built-in, but `gen_random_uuid()` is in pgcrypto by
    #    default in modern Postgres; if it's not available we fall back to
    #    md5-of-id which is always present.
    op.execute(
        """
        UPDATE users
        SET display_name = 'User-' || substr(md5(id::text), 1, 6)
        WHERE display_name IS NULL OR btrim(display_name) = ''
        """
    )

    # 2. Tighten the column to NOT NULL.
    op.alter_column(
        "users",
        "display_name",
        existing_type=sa.Text(),
        nullable=False,
    )


def downgrade() -> None:
    op.alter_column(
        "users",
        "display_name",
        existing_type=sa.Text(),
        nullable=True,
    )

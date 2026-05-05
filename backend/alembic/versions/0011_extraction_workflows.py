"""add_extraction_workflows

Revision ID: 0011_extraction_workflows
Revises: 0010_normalized_uddipoks
Create Date: 2026-05-05 13:15:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = '0011_extraction_workflows'
down_revision: Union[str, None] = '0010_normalized_uddipoks'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        'extraction_workflows',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('created_by', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('original_filename', sa.String(length=500), nullable=False),
        sa.Column('original_pdf_path', sa.Text(), nullable=False),
        sa.Column('cleaned_pdf_path', sa.Text(), nullable=True),
        sa.Column('cleaning_applied', sa.Boolean(), nullable=False, server_default='false'),
        sa.Column('selected_pdf_path', sa.Text(), nullable=False),
        sa.Column('crop_folder', sa.String(length=500), nullable=True),
        sa.Column('cropping_applied', sa.Boolean(), nullable=False, server_default='false'),
        sa.Column('extraction_job_id', sa.String(length=100), nullable=True),
        sa.Column('paper_id', postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column('current_step', sa.String(length=20), nullable=False, server_default='upload', comment='Current step: upload, clean, crop, extract, complete'),
        sa.Column('status', sa.String(length=20), nullable=False, server_default='in_progress', comment='Status: in_progress, completed, failed'),
        sa.Column('error_message', sa.Text(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.ForeignKeyConstraint(['created_by'], ['users.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['paper_id'], ['exam_papers.id'], ondelete='SET NULL'),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index('idx_extraction_workflows_created_by', 'extraction_workflows', ['created_by'])


def downgrade() -> None:
    op.drop_index('idx_extraction_workflows_created_by', 'extraction_workflows')
    op.drop_table('extraction_workflows')

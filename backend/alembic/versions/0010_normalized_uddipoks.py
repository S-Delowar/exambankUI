"""add_normalized_uddipoks

Revision ID: 0010_normalized_uddipoks
Revises: e5d31493a649
Create Date: 2026-05-05 09:30:00.000000

This migration implements the normalized uddipok design:
1. Creates the uddipoks table
2. Adds uddipok_id to hsc_mcq_questions (nullable)
3. Adds uddipok_id to hsc_written_questions (NOT NULL)
4. Drops uddipak_text and uddipak_has_image from hsc_written_questions

NOTE: This migration assumes no existing data in hsc_written_questions.
If you have existing data, you need to:
1. Extract uddipak_text from hsc_written_questions
2. Create Uddipok records
3. Update uddipok_id references
4. Then drop the old columns
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = '0010_normalized_uddipoks'
down_revision: Union[str, None] = 'e5d31493a649'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # 1. Create uddipoks table
    op.create_table(
        'uddipoks',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('paper_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('text', sa.Text(), nullable=False, comment='Full uddipok text with [IMAGE_N] tokens for embedded figures'),
        sa.Column('has_image', sa.Boolean(), nullable=False, server_default='false', comment='True if text contains [IMAGE_N] tokens'),
        sa.Column('images', postgresql.JSONB(astext_type=sa.Text()), nullable=True, comment='Image metadata (id, kind, caption_hint, etc.)'),
        sa.Column('sequence_number', sa.Integer(), nullable=False, comment='Order of appearance in the paper (1, 2, 3, ...)'),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.ForeignKeyConstraint(['paper_id'], ['exam_papers.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index('idx_uddipoks_paper_id', 'uddipoks', ['paper_id'])
    op.create_index('idx_uddipoks_has_image', 'uddipoks', ['has_image'])
    
    # 2. Add uddipok_id to hsc_mcq_questions (nullable)
    op.add_column(
        'hsc_mcq_questions',
        sa.Column(
            'uddipok_id',
            postgresql.UUID(as_uuid=True),
            nullable=True,
            comment='Reference to uddipok (stimulus passage) if this question has one'
        )
    )
    op.create_foreign_key(
        'fk_hsc_mcq_questions_uddipok_id',
        'hsc_mcq_questions',
        'uddipoks',
        ['uddipok_id'],
        ['id'],
        ondelete='SET NULL'
    )
    op.create_index('idx_hsc_mcq_questions_uddipok_id', 'hsc_mcq_questions', ['uddipok_id'])
    
    # 3. Add uddipok_id to hsc_written_questions (NOT NULL)
    # First add as nullable
    op.add_column(
        'hsc_written_questions',
        sa.Column(
            'uddipok_id',
            postgresql.UUID(as_uuid=True),
            nullable=True,  # Temporarily nullable for migration
            comment='Reference to uddipok (stimulus passage) - required for written questions'
        )
    )
    
    # NOTE: If you have existing data, you would:
    # - Extract uddipak_text from each row
    # - Create Uddipok records
    # - Update uddipok_id references
    # - Then alter column to NOT NULL
    
    # For new installations, make it NOT NULL immediately
    op.alter_column('hsc_written_questions', 'uddipok_id', nullable=False)
    
    op.create_foreign_key(
        'fk_hsc_written_questions_uddipok_id',
        'hsc_written_questions',
        'uddipoks',
        ['uddipok_id'],
        ['id'],
        ondelete='CASCADE'
    )
    op.create_index('idx_hsc_written_questions_uddipok_id', 'hsc_written_questions', ['uddipok_id'])
    
    # 4. Drop old columns from hsc_written_questions
    op.drop_column('hsc_written_questions', 'uddipak_has_image')
    op.drop_column('hsc_written_questions', 'uddipak_text')


def downgrade() -> None:
    # Reverse the changes
    
    # 1. Add back old columns to hsc_written_questions
    op.add_column(
        'hsc_written_questions',
        sa.Column('uddipak_text', sa.Text(), nullable=False, server_default='')
    )
    op.add_column(
        'hsc_written_questions',
        sa.Column('uddipak_has_image', sa.Boolean(), nullable=False, server_default='false')
    )
    
    # 2. Drop uddipok_id from hsc_written_questions
    op.drop_index('idx_hsc_written_questions_uddipok_id', 'hsc_written_questions')
    op.drop_constraint('fk_hsc_written_questions_uddipok_id', 'hsc_written_questions', type_='foreignkey')
    op.drop_column('hsc_written_questions', 'uddipok_id')
    
    # 3. Drop uddipok_id from hsc_mcq_questions
    op.drop_index('idx_hsc_mcq_questions_uddipok_id', 'hsc_mcq_questions')
    op.drop_constraint('fk_hsc_mcq_questions_uddipok_id', 'hsc_mcq_questions', type_='foreignkey')
    op.drop_column('hsc_mcq_questions', 'uddipok_id')
    
    # 4. Drop uddipoks table
    op.drop_index('idx_uddipoks_has_image', 'uddipoks')
    op.drop_index('idx_uddipoks_paper_id', 'uddipoks')
    op.drop_table('uddipoks')

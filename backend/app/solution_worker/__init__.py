"""Background solution generator.

Entry point: `python -m app.solution_worker`.

Drains pending rows from every (exam_type, question_type) table:
  - admission_mcq_questions (MCQ explanations)
  - hsc_mcq_questions (MCQ explanations)
  - admission_written_questions (model answers)
  - hsc_written_subparts (one model answer per sub-part a/b/c/d)
"""

from .generator import SolutionGenerator
from .runner import run_loop

__all__ = ["run_loop", "SolutionGenerator"]

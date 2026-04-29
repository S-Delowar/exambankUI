"""Prompt dispatcher: picks the right (system_prompt, user_prompt_builder) pair
for a given (exam_type, question_type, subjects, subject_paper) combination.

Callers outside this package should only import `get_prompt` and the
`UserPromptBuilder` type.
"""

from typing import Callable, Protocol

from ..schemas import ExamType, QuestionType
from . import admission_mcq, admission_written, hsc_mcq, hsc_written


class UserPromptBuilder(Protocol):
    def __call__(
        self,
        prev_tail: str,
        prev_incomplete: bool,
        page_index: int,
        total_pages: int,
        known_metadata: dict | None = None,
    ) -> str: ...


_BUILDERS: dict[
    tuple[ExamType, QuestionType],
    tuple[
        # (system_prompt_builder, user_prompt_builder)
        Callable[..., str],
        UserPromptBuilder,
    ],
] = {
    ("admission_test", "mcq"): (admission_mcq.build_system_prompt, admission_mcq.build_user_prompt),
    ("admission_test", "written"): (
        admission_written.build_system_prompt,
        admission_written.build_user_prompt,
    ),
    ("hsc_board", "mcq"): (hsc_mcq.build_system_prompt, hsc_mcq.build_user_prompt),
    ("hsc_board", "written"): (hsc_written.build_system_prompt, hsc_written.build_user_prompt),
}


def get_prompt(
    exam_type: ExamType,
    question_type: QuestionType,
    subjects: tuple[str, ...],
    subject_paper: str | None,
) -> tuple[str, UserPromptBuilder]:
    """Return (system_prompt_text, user_prompt_builder) for this combination.

    - subjects is a sorted, deduplicated tuple (so the cache key is stable).
    - subject_paper is only consulted for HSC prompts; admission builders ignore it.
    """
    if (exam_type, question_type) not in _BUILDERS:
        raise ValueError(f"No prompt registered for ({exam_type}, {question_type})")

    sys_builder, user_builder = _BUILDERS[(exam_type, question_type)]

    if exam_type == "hsc_board":
        system_prompt = sys_builder(subjects, subject_paper)
    else:
        system_prompt = sys_builder(subjects)

    return system_prompt, user_builder


__all__ = ["get_prompt", "UserPromptBuilder"]

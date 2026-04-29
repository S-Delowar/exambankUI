"""Public stats endpoints used by the student quiz browser.

The endpoint reports one entry per `(subject, exam_type)` quiz — that's the
identity the rest of the system uses (no `quizzes` table; see plan). Each
question table maps to a single exam_type:

  AdmissionMcqQuestion / AdmissionWrittenQuestion → admission_test
  HscMcqQuestion / HscWrittenQuestion             → hsc_board

For non-admins, we filter to quizzes whose `quiz_status.status = 'published'`
(missing rows count as draft, so the default visibility is invisible).
Admins see every quiz with its current status so the admin grid can render
draft / archived alongside published.
"""

from collections import defaultdict
from typing import Any

from fastapi import APIRouter, Depends
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from ..database import get_session
from ..deps import get_current_user
from ..models import (
    AdmissionMcqQuestion,
    AdmissionWrittenQuestion,
    HscMcqQuestion,
    HscWrittenQuestion,
    QuizStatus,
    User,
)

router = APIRouter(prefix="/stats", tags=["stats"])


# (model, exam_type) — exam_type is fixed per table and the endpoint groups
# by both. HscWrittenQuestion has no `chapter` column (uses subject_paper
# grouping), so its chapter bucket falls back to "".
_QUESTION_SOURCES: tuple[tuple[Any, str], ...] = (
    (AdmissionMcqQuestion, "admission_test"),
    (AdmissionWrittenQuestion, "admission_test"),
    (HscMcqQuestion, "hsc_board"),
    (HscWrittenQuestion, "hsc_board"),
)


@router.get("/subjects")
async def get_quiz_stats(
    session: AsyncSession = Depends(get_session),
    user: User = Depends(get_current_user),
) -> dict[str, Any]:
    """Return one entry per `(subject, exam_type)` quiz.

    Shape:
      ```
      {
        "quizzes": [
          {
            "subject": "physics",
            "exam_type": "admission_test",
            "total": 200,
            "by_chapter": {"vector": 12, ...},
            "status": "published"  // admins always see this; students
                                   // only see entries where status=published
          },
          ...
        ]
      }
      ```

    Questions with NULL subject are dropped (not reachable from any quiz).
    NULL chapters bucket under the empty string so per-chapter counts still
    add up to `total`.
    """
    by_quiz: dict[tuple[str, str], dict[str, int]] = defaultdict(
        lambda: defaultdict(int)
    )

    for model, exam_type in _QUESTION_SOURCES:
        has_chapter = hasattr(model, "chapter")
        cols = [model.subject]
        if has_chapter:
            cols.append(model.chapter)
        cols.append(func.count())
        stmt = select(*cols).where(model.subject.is_not(None)).group_by(*cols[:-1])
        for row in (await session.execute(stmt)).all():
            if has_chapter:
                subject, chapter, count = row
            else:
                subject, count = row
                chapter = None
            by_quiz[(subject, exam_type)][chapter or ""] += count

    # One round-trip to load the entire quiz_status table — it's tiny (one
    # row per (subject, exam_type) the admin has touched).
    status_rows = (await session.execute(select(QuizStatus))).scalars().all()
    status_map: dict[tuple[str, str], str] = {
        (row.subject, row.exam_type): row.status for row in status_rows
    }

    quizzes: list[dict[str, Any]] = []
    for (subject, exam_type), chapters in by_quiz.items():
        status = status_map.get((subject, exam_type), "draft")
        # Students only see published quizzes. Admins see every row.
        if not user.is_admin and status != "published":
            continue
        quizzes.append(
            {
                "subject": subject,
                "exam_type": exam_type,
                "total": sum(chapters.values()),
                "by_chapter": dict(chapters),
                "status": status,
            }
        )

    # Stable ordering: subject asc, then admission_test before hsc_board.
    quizzes.sort(key=lambda q: (q["subject"], q["exam_type"]))
    return {"quizzes": quizzes}

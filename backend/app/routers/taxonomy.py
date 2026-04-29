"""Public chapter taxonomy.

Exposes the same source as the admin reviewer's `/review/taxonomy/chapters`,
but auth-only (any logged-in user) and including the nested HSC paper grouping
when present. Powers the student `/subjects/[subject]` page.
"""

from typing import Any

from fastapi import APIRouter, Depends

from ..config import get_settings
from ..deps import get_current_user

router = APIRouter(prefix="/taxonomy", tags=["taxonomy"])


@router.get("/chapters")
async def get_chapter_taxonomy(
    _user=Depends(get_current_user),
) -> dict[str, Any]:
    """Return both flat and nested taxonomy plus Bangla display labels.

    - `flat[subject]` is the merged chapter list (papers concatenated, dedup),
      suitable for admission-test subjects that have no paper split. The
      order here defines the syllabus position used for chapter serial
      numbers and chapter sectioning in the quiz runner.
    - `nested[subject]` is the raw `chapters.yaml` shape: either
      `{paper_1: [...], paper_2: [...]}` (HSC) or `[chapter, ...]`. The
      frontend uses this to decide whether to render a paper-grouped UI.
    - `labels_bn[subject][chapter_key]` is the Bangla display label loaded
      from `chapters_bn.yaml`. Missing entries fall back to a prettified
      English key on the client.
    """
    settings = get_settings()
    return {
        "flat": settings.chapter_taxonomy,
        "nested": settings.chapter_taxonomy_nested,
        "labels_bn": settings.chapter_labels_bn,
    }

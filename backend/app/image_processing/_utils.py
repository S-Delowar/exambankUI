"""Shared utilities for image processing modules."""

import re

_SAFE_FILENAME_RE = re.compile(r"[^A-Za-z0-9._-]+")


def safe_qnum(question_number: str) -> str:
    """Convert question_number to a filename-safe slug.

    '১২' / '12(a)' / etc. → underscore-delimited ASCII. Empty → 'q'.
    Used by both the extractor (Pass-2 cropper) and the linker (manual-crop
    pairing) — they MUST produce identical filenames for the same question.
    """
    slug = _SAFE_FILENAME_RE.sub("_", question_number).strip("._-")
    return slug or "q"

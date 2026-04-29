"""Admission-test written-question prompt."""

from functools import lru_cache

from .shared import (
    FORMAT_BLOCK,
    IMAGE_BLOCK,
    MATH_CHEMISTRY_BLOCK,
    STITCHING_BLOCK,
    format_scoped_taxonomy,
    format_subjects_list,
)


_TEMPLATE = """You are an expert extractor of WRITTEN (short-answer / essay / derivation) questions from scanned pages of Bangladeshi public-university admission-test question papers. Pages may contain English, Bangla, or both.

TASK
Extract every complete written question visible on this page into the provided JSON schema. SKIP any MCQs entirely — they are extracted in a separate pass.

DECLARED_SUBJECTS (uploader has stated this PDF contains ONLY these subjects)
  {declared_subjects}

FIELDS PER QUESTION
- university_name, exam_session, exam_unit: same rules as the admission MCQ extractor. Propagate headers across every question on the page.
- subject: lowercase snake_case, MUST be one of DECLARED_SUBJECTS. Infer from section headers. If you cannot map it to one of DECLARED_SUBJECTS, return null.
- chapter: snake_case key from CHAPTER_TAXONOMY for this subject. Null if nothing fits.
- question_number: as printed.
- question_text: the full question stem. If the question has labelled parts (e.g. "(a) ... (b) ..."), keep them inline within question_text — do NOT split into sub-parts (this is admission-style, not HSC creative-question style).

CHAPTER_TAXONOMY
{taxonomy_block}

{math_chemistry}

{image}

DO NOT EXTRACT
- MCQ questions (they have options like A/B/C/D or ক/খ/গ/ঘ — skip them).
- Solutions, worked-out answers, or model answers — including ANY figure, diagram, graph, OR table that appears inside such a block. Nothing from a solution may leak into the output (no text, no `[IMAGE_N]` token, no inline markdown table, no `images[]` entry).
- Section headers, page numbers, decorative text.
- Partial questions at the bottom of the page — use the tail fields.

{stitching}

{format_block}
"""


@lru_cache(maxsize=32)
def build_system_prompt(subjects: tuple[str, ...]) -> str:
    return _TEMPLATE.format(
        declared_subjects=format_subjects_list(subjects),
        taxonomy_block=format_scoped_taxonomy(subjects, subject_paper=None),
        math_chemistry=MATH_CHEMISTRY_BLOCK,
        image=IMAGE_BLOCK,
        stitching=STITCHING_BLOCK,
        format_block=FORMAT_BLOCK,
    )


def build_user_prompt(
    prev_tail: str,
    prev_incomplete: bool,
    page_index: int,
    total_pages: int,
    known_metadata: dict | None = None,
) -> str:
    header = f"PAGE {page_index + 1} of {total_pages}."

    metadata_block = ""
    if known_metadata and any(
        known_metadata.get(k) for k in ("university_name", "exam_session", "exam_unit")
    ):
        u = known_metadata.get("university_name")
        s = known_metadata.get("exam_session")
        un = known_metadata.get("exam_unit")
        metadata_block = (
            "\n\nKNOWN EXAM METADATA (copy into every question on THIS page unless a new header is printed):\n"
            f"  university_name: {u!r}\n"
            f"  exam_session: {s!r}\n"
            f"  exam_unit: {un!r}\n"
        )

    if not prev_tail and not prev_incomplete:
        return (
            f"{header}\n"
            "No previous-page context.\n"
            "Extract all complete WRITTEN questions from this page per the system instructions."
            f"{metadata_block}"
        )
    return (
        f"{header}\n"
        "PREVIOUS_PAGE_TAIL:\n<<<\n"
        f"{prev_tail}\n>>>\n"
        f"LAST_QUESTION_WAS_INCOMPLETE: {str(prev_incomplete).lower()}\n\n"
        "Apply the page-boundary stitching rules and extract all complete written questions."
        f"{metadata_block}"
    )

"""Admission-test MCQ prompt (scoped by caller-declared subjects)."""

from functools import lru_cache

from .shared import (
    FORMAT_BLOCK,
    IMAGE_BLOCK,
    MATH_CHEMISTRY_BLOCK,
    STITCHING_BLOCK,
    format_scoped_taxonomy,
    format_subjects_list,
)


_TEMPLATE = """You are an expert extractor of MCQs from scanned pages of Bangladeshi public-university admission-test question banks. Pages may contain English, Bangla, or both. Pages come from CamScanner scans so expect some noise.

TASK
Extract every complete multiple-choice question visible on this page into the provided JSON schema.

DECLARED_SUBJECTS (the uploader has stated this PDF contains ONLY these subjects; do not emit any other subject)
  {declared_subjects}

FIELDS PER QUESTION
- university_name: the university the question belongs to (e.g. "Dhaka University", "DU", "RU", "JU", "CU"). If a section/page header names the university, propagate that value to every question on the page. Null only if truly unknown.
- exam_session: the academic session as printed, normalised to the full 4-4 digit form (e.g. "2010-2011"). Pages often print it as "2010-11", "সেশন ২০১০-১১", "Session: 2019-20" — always expand to two full years joined by a hyphen. If only a single year is printed, return null (do NOT invent the other half). Null only if no session is printed anywhere.
- exam_unit: unit/group label as printed (e.g. "A", "B", "Ga", "ক", "খ"). Null if not printed.
- subject: lowercase snake_case subject. MUST be one of DECLARED_SUBJECTS. Infer from the section/chapter header (e.g. "পদার্থবিজ্ঞান"/"Physics" → "physics", "রসায়ন"/"Chemistry" → "chemistry", "জীববিজ্ঞান"/"Biology" → "biology", "উচ্চতর গণিত"/"Higher Math"/"Mathematics" → "mathematics", "বাংলা" → "bangla", "ইংরেজি"/"English" → "english") and propagate to every question on the page. If no header is visible, infer from the content. If you would emit a subject NOT in DECLARED_SUBJECTS, return null instead.
- chapter: the HSC chapter the question maps to. MUST be exactly one of the snake_case keys listed for the question's subject in CHAPTER_TAXONOMY below. Never invent a new chapter name, never translate or substitute synonyms — copy the key verbatim. If no chapter fits confidently, or if subject is null/unlisted, return null.
- question_number: as printed, kept as a string. Preserve suffixes like "(a)" and Bangla numerals as-is.
- question_text: the full question stem, cleanly joined across line breaks. Do NOT include the options. Apply the MATH & CHEMISTRY rules below.
- options: every printed option as {{label, text}}. The label is exactly what precedes the option (e.g. "A", "B", "ক", "খ", "i", "1"). Do not invent labels. Preserve order. Apply the MATH & CHEMISTRY rules below to option text.
- correct_answer: the LABEL (matching one of options[].label) of the correct option. The answer is usually marked in the book via a key, circle, tick, bold, or a separate answer line near the question. If not indicated, return null. Never return the option text here.

CHAPTER_TAXONOMY
Pick `chapter` ONLY from the list for the question's subject. Exact snake_case match, no variations.
{taxonomy_block}

{math_chemistry}

{image}

DO NOT EXTRACT
- Written / short-answer questions — this PDF is an MCQ extraction pass; skip any non-MCQ content on the page.
- Solutions, explanations, worked-out derivations, or answer-key write-ups. Skip them entirely — including ANY figure, diagram, graph, OR table that appears inside such a block. Nothing from a solution may leak into the output (no text, no `[IMAGE_N]` token, no inline markdown table, no `images[]` entry). The ONLY thing a solution block may contribute is the `correct_answer` label, when the key is presented as a label like "Ans: B" / "উত্তর: খ".
- Section headers, page numbers, running titles, decorative text.
- Partial / visibly cut-off questions at the very bottom — handle them via the tail fields described below.
- Image content — never describe, transcribe, or invent values from a figure/diagram/graph; only emit the `[IMAGE_N]` placeholder per the IMAGE rules above.

{stitching}

{format_block}
"""


@lru_cache(maxsize=32)
def build_system_prompt(subjects: tuple[str, ...]) -> str:
    """Byte-stable per `subjects` tuple. Cache so each page of a PDF reuses the
    same string → Gemini prefix caching stays warm."""
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
            "\n\nKNOWN EXAM METADATA (from earlier pages of this same PDF — copy these values "
            "into EVERY question on THIS page unless a different header is visibly printed on this page):\n"
            f"  university_name: {u!r}\n"
            f"  exam_session: {s!r}\n"
            f"  exam_unit: {un!r}\n"
        )

    if not prev_tail and not prev_incomplete:
        return (
            f"{header}\n"
            "No previous-page context (this is the first page, or the previous page ended cleanly).\n"
            "Extract all complete MCQs from this page image per the system instructions."
            f"{metadata_block}"
        )
    return (
        f"{header}\n"
        "PREVIOUS_PAGE_TAIL (raw text from the bottom of the previous page — may contain the start of this page's first question):\n"
        "<<<\n"
        f"{prev_tail}\n"
        ">>>\n"
        f"LAST_QUESTION_WAS_INCOMPLETE: {str(prev_incomplete).lower()}\n\n"
        "Apply the page-boundary stitching rules from the system instructions and extract all complete MCQs."
        f"{metadata_block}"
    )

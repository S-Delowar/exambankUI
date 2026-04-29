"""HSC board written (creative question / সৃজনশীল) prompt.

Every HSC written question has the creative-question shape:
  <uddipak / stimulus>
  (a) ... [1 mark]
  (b) ... [2 marks]
  (c) ... [3 marks]
  (d) ... [4 marks]

Always exactly 4 sub-parts. Uddipak may contain an image (diagram/graph/figure)
marked with the literal `[IMAGE]` token. A single question frequently spans
two pages — the stitching logic merges uddipak on page N with the sub-parts on
page N+1.
"""

from functools import lru_cache

from .shared import (
    FORMAT_BLOCK,
    IMAGE_BLOCK,
    MATH_CHEMISTRY_BLOCK,
    STITCHING_BLOCK,
    format_scoped_taxonomy,
    format_subjects_list,
)


_FIXED_SUBJECT_HEADER = (
    "SUBJECT IS FIXED FOR THIS PDF: {subject}{paper_suffix}\n"
    "Every question on this page belongs to the fixed subject above. Do NOT attempt to classify subject from headers."
)


_TEMPLATE = """You are an expert extractor of CREATIVE QUESTIONS (সৃজনশীল প্রশ্ন / written questions) from scanned pages of Bangladeshi HSC board examination papers. Pages may contain English, Bangla, or both. HSC creative questions follow a strict shape — read the SHAPE section carefully.

{subject_header_block}

TASK
Extract every complete creative question visible on this page into the provided JSON schema. SKIP any MCQs entirely — they are extracted in a separate pass.

SHAPE (CRITICAL — never deviate)
Every creative question consists of:
  1. An UDDIPAK (উদ্দীপক) — a stimulus passage, scenario, figure, table, or graph at the top.
  2. Exactly 4 sub-questions labelled (a), (b), (c), (d) below the uddipak, with fixed marks 1, 2, 3, 4.
Even if the paper uses different labels (ক/খ/গ/ঘ, i/ii/iii/iv, 1/2/3/4), MAP them by position: first → "a"/1, second → "b"/2, third → "c"/3, fourth → "d"/4.
Marks are ALWAYS 1/2/3/4 for a/b/c/d in that order, regardless of what's printed. If a question has fewer than 4 sub-parts or more than 4, DO NOT emit it — it's either malformed or a non-creative question.

FIELDS PER QUESTION
- board_name: HSC board, normalised English ("Dhaka Board", "Rajshahi Board", etc.). Null if not printed.
- exam_year: single 4-digit year string. Null if not printed.
- subject: {subject_field_instruction}
- subject_paper: "1" or "2". {paper_field_instruction}
- question_number: as printed ("১", "1", "৭", etc.).
- uddipak_text: the FULL stimulus text (passage / scenario). Apply MATH & CHEMISTRY rules. If the uddipak includes a figure/diagram/graph/chart, insert the literal `[IMAGE]` token at the exact position — do NOT describe the image.
- uddipak_has_image: true iff uddipak_text contains one or more `[IMAGE]` tokens, else false.
- sub_questions: array of EXACTLY 4 objects, in order a → b → c → d:
    [
      {{ "label": "a", "marks": 1, "text": "..." }},
      {{ "label": "b", "marks": 2, "text": "..." }},
      {{ "label": "c", "marks": 3, "text": "..." }},
      {{ "label": "d", "marks": 4, "text": "..." }}
    ]
  Apply MATH & CHEMISTRY rules to each text.

{math_chemistry}

{image}

CHAPTER_TAXONOMY (reference only — creative questions are not chapter-tagged at this stage; the `chapter` field is omitted from the schema.)
{taxonomy_block}

DO NOT EXTRACT
- MCQ questions (they have option lists).
- Solution, answer, or model-answer content — including ANY figure, diagram, graph, OR table that appears inside such a block. Nothing from a solution may leak into the output (no text, no `[IMAGE_N]` token, no inline markdown table, no `images[]` entry).
- Section headers, page numbers.
- Any question missing one or more of its 4 sub-parts — hold via the tail fields for stitching on the next page.

{stitching}

STITCHING NOTE FOR CREATIVE QUESTIONS
It is COMMON for a creative question to span two pages: the uddipak and part of the sub-questions on page N, the remaining sub-questions on page N+1. When LAST_QUESTION_WAS_INCOMPLETE is true, use PREVIOUS_PAGE_TAIL as the start of the question (including the uddipak) and complete it with the sub-parts found on THIS page. Only emit the question when all 4 sub-parts are assembled.

{format_block}
"""


def _subject_header_block(
    subjects: tuple[str, ...], subject_paper: str | None
) -> str:
    if len(subjects) != 1:
        return ""
    subject = subjects[0]
    paper_suffix = f", PAPER {subject_paper}" if subject_paper else ""
    return _FIXED_SUBJECT_HEADER.format(subject=subject, paper_suffix=paper_suffix) + "\n"


def _subject_field_instruction(subjects: tuple[str, ...]) -> str:
    if len(subjects) == 1:
        return (
            f"FIXED to '{subjects[0]}' for every question on this page. Return exactly this value."
        )
    return (
        f"MUST be one of DECLARED_SUBJECTS [{format_subjects_list(subjects)}]. "
        "Infer from section headers."
    )


def _paper_field_instruction(
    subjects: tuple[str, ...], subject_paper: str | None
) -> str:
    if len(subjects) == 1 and subject_paper is not None:
        return f"FIXED to '{subject_paper}' for every question on this page."
    return (
        "Only set when clearly printed. Null for subjects without a paper split or when not printed."
    )


@lru_cache(maxsize=64)
def build_system_prompt(
    subjects: tuple[str, ...], subject_paper: str | None
) -> str:
    return _TEMPLATE.format(
        subject_header_block=_subject_header_block(subjects, subject_paper),
        subject_field_instruction=_subject_field_instruction(subjects),
        paper_field_instruction=_paper_field_instruction(subjects, subject_paper),
        taxonomy_block=format_scoped_taxonomy(subjects, subject_paper),
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
        known_metadata.get(k) for k in ("board_name", "exam_year")
    ):
        b = known_metadata.get("board_name")
        y = known_metadata.get("exam_year")
        metadata_block = (
            "\n\nKNOWN BOARD METADATA (copy into every question on THIS page unless a new header is printed):\n"
            f"  board_name: {b!r}\n"
            f"  exam_year: {y!r}\n"
        )

    if not prev_tail and not prev_incomplete:
        return (
            f"{header}\n"
            "No previous-page context.\n"
            "Extract all complete creative questions (uddipak + 4 sub-parts) from this page per the system instructions."
            f"{metadata_block}"
        )
    return (
        f"{header}\n"
        "PREVIOUS_PAGE_TAIL (may contain a creative question's uddipak and partial sub-parts awaiting completion):\n"
        "<<<\n"
        f"{prev_tail}\n"
        ">>>\n"
        f"LAST_QUESTION_WAS_INCOMPLETE: {str(prev_incomplete).lower()}\n\n"
        "Apply stitching and extract all complete creative questions (all 4 sub-parts required)."
        f"{metadata_block}"
    )

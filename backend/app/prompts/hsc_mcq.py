"""HSC board MCQ prompt.

Two modes:
  - single-subject (len(subjects)==1, subject_paper optional): prompt declares
    the subject is fixed and inlines ONLY that subject's (possibly paper-scoped)
    chapter list.
  - multi-subject: prompt shows the declared-subjects list and their chapters,
    asks the model to infer `subject` per question.
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


_TEMPLATE = """You are an expert extractor of MCQs from scanned pages of Bangladeshi HSC board examination papers (e.g. Dhaka Board, Rajshahi Board, Comilla Board). Pages may contain English, Bangla, or both. HSC papers follow the NCTB syllabus.

{subject_header_block}

TASK
Extract every complete multiple-choice question visible on this page into the provided JSON schema.

FIELDS PER QUESTION
- board_name: the HSC education board, normalised to English — e.g. "Dhaka Board", "Rajshahi Board", "Jessore Board", "Comilla Board", "Chittagong Board", "Barisal Board", "Sylhet Board", "Dinajpur Board", "Mymensingh Board", "Madrasah Board". The page may print it in Bangla ("ঢাকা বোর্ড") — still return English. If only "BOARD" or abbreviation appears, use the English form. Null only if truly not printed.
- exam_year: the single 4-digit year as printed, e.g. "2023". HSC exam papers print a single year, not a session range. Null if not printed.
- subject: lowercase snake_case. {subject_field_instruction}
- subject_paper: "1" for 1st Paper, "2" for 2nd Paper. {paper_field_instruction}
- chapter: snake_case key from CHAPTER_TAXONOMY below for this question's subject. Never invent. Null if nothing fits.
- question_number: as printed.
- question_text: full stem (no options). Apply MATH & CHEMISTRY rules.
- options: every printed option as {{label, text}}. Preserve order and labels verbatim.
- correct_answer: label of the correct option. HSC boards commonly print the answer key as a separate section at the end of the paper (উত্তরমালা) OR mark the correct option inline (circle, tick, bold). If you see a trailing key page, match its entries back to the question numbers and fill correct_answer. Null if no answer is indicated anywhere.

CHAPTER_TAXONOMY
Pick `chapter` ONLY from the list for the question's subject. Exact snake_case match, no variations.
{taxonomy_block}

{math_chemistry}

{image}

DO NOT EXTRACT
- Written / creative-question (সৃজনশীল) content — this PDF is an MCQ extraction pass.
- Solutions, worked-out answers, or answer-key write-ups — including ANY figure, diagram, graph, OR table that appears inside such a block. Nothing from a solution may leak into the output (no text, no `[IMAGE_N]` token, no inline markdown table, no `images[]` entry). The ONLY thing a solution block may contribute is the `correct_answer` label, when the key is presented as a label like "Ans: B" / "উত্তর: খ".
- Section headers, page numbers, running titles.
- Partial questions at the bottom of the page — use the tail fields.

{stitching}

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
            f"FIXED to '{subjects[0]}' for every question on this page (see SUBJECT IS FIXED above). "
            "Return exactly this value."
        )
    return (
        f"MUST be one of DECLARED_SUBJECTS [{format_subjects_list(subjects)}]. "
        "Infer from section headers. Null only if you cannot map it to one of the declared subjects."
    )


def _paper_field_instruction(
    subjects: tuple[str, ...], subject_paper: str | None
) -> str:
    if len(subjects) == 1 and subject_paper is not None:
        return f"FIXED to '{subject_paper}' for every question on this page."
    return (
        "Only set when clearly printed on the page (e.g. 'Physics 1st Paper'). "
        "Null for subjects without a paper split (bangla/english/etc.) or when not printed."
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
            "Extract all complete MCQs from this page per the system instructions."
            f"{metadata_block}"
        )
    return (
        f"{header}\n"
        "PREVIOUS_PAGE_TAIL:\n<<<\n"
        f"{prev_tail}\n>>>\n"
        f"LAST_QUESTION_WAS_INCOMPLETE: {str(prev_incomplete).lower()}\n\n"
        "Apply the page-boundary stitching rules and extract all complete MCQs."
        f"{metadata_block}"
    )

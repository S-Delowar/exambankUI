"""Shared schema primitives used by every (exam_type, question_type) pair."""

from typing import Literal, Optional

from pydantic import BaseModel, Field


ExamType = Literal["admission_test", "hsc_board"]
QuestionType = Literal["mcq", "written"]

ExtractionStatus = Literal["pending", "ok", "needs_review", "failed"]


class Option(BaseModel):
    label: str = Field(
        ..., description="Option label as printed (e.g. 'A', 'B', 'ক', 'খ', '1', '2')."
    )
    text: str = Field(
        ...,
        description=(
            "Option text as printed. Math MUST be LaTeX in $...$ / $$...$$. "
            "Chemistry formulas/equations MUST use \\ce{...} (mhchem). "
            "Preserve Bangla Unicode outside math. "
            "If the option itself IS an image (no printed text besides the figure), "
            "emit the matching [IMAGE_N] token as the text value."
        ),
    )
    image_filename: Optional[str] = Field(
        None,
        description=(
            "Filled by the image linker AFTER extraction when the option's text "
            "contains a single [IMAGE_N] token and a matching cropped PNG is "
            "available on disk. Frontend builds the URL as "
            "`/exams/{paper_id}/images/{image_filename}` and renders the image "
            "in place of the option text. Null for text-only options or when "
            "no crop is available."
        ),
    )


class QuestionRegion(BaseModel):
    """The bounding box of an entire question on a page.

    Pass-1 emits one of these per question. Pass-2 crops it from the page PNG
    and re-runs Gemini against ONLY the crop to localise individual diagrams.
    Localising one big region per question is much more reliable than asking
    the model to localise each individual diagram against a full page.
    """

    page_index: int = Field(
        ...,
        description=(
            "0-based index of the page this question appears on. For questions "
            "that span pages, use the page where the MAJORITY of the question "
            "(stem + options) is printed."
        ),
        ge=0,
    )
    box_2d: list[int] = Field(
        ...,
        description=(
            "Bounding box of the WHOLE question on the page, as "
            "[ymin, xmin, ymax, xmax], each integer 0-1000, normalised to the "
            "rendered page image's height and width. Y-FIRST. Include the "
            "question number, full stem, every option, AND every diagram/table "
            "that belongs to the question — be GENEROUS, prefer over-cropping "
            "to under-cropping."
        ),
        min_length=4,
        max_length=4,
    )


class QuestionImage(BaseModel):
    """A diagram/figure region belonging to a single question.

    Tables are NOT represented here — they are inlined as GitHub-Flavoured
    Markdown directly in the question_text or options[].text where they
    appear (see IMAGE_BLOCK Part B in prompts/shared.py). The `"table"` value
    on `kind` is retained only for backward compatibility with previously
    extracted papers; new extractions emit `kind="diagram"` exclusively.

    Two-pass extraction lifecycle:
      Pass 1 (page-level, JSON extraction):
        - emit `id`, `kind="diagram"`, optional `caption_hint`
        - leave `page_index`, `box_2d`, `markdown`, `filename` null
        - `extraction_status` defaults to "pending"
      Pass 2 (question-crop, diagram-only Gemini call):
        - fill `page_index` + `box_2d` (page-coord pixels)
      Cropper (offline PIL):
        - crop the box and set `filename`
        - mark `extraction_status` accordingly
    """

    id: str = Field(
        ...,
        description=(
            "Sequential id `IMAGE_1`, `IMAGE_2`, ... unique within a single question. "
            "Must match a `[IMAGE_N]` token appearing in question_text, options[].text, "
            "uddipak_text, or sub_questions[].text for this question."
        ),
    )
    kind: Literal["diagram", "table"] = Field(
        "diagram",
        description=(
            "`diagram` for figures/graphs/circuits/drawings → cropped to PNG. "
            "`table` for tabular layouts → transcribed to Markdown in pass 2 "
            "(NOT cropped to PNG)."
        ),
    )
    caption_hint: Optional[str] = Field(
        None,
        description=(
            "Pass 1 only: a short verbatim snippet of the printed caption or label "
            "near the figure (e.g. 'চিত্র: ১.২', 'Fig 3', 'Table 2'). Helps pass 2 "
            "disambiguate when a question has multiple diagrams. Null if no "
            "visible caption."
        ),
    )
    label: Optional[str] = Field(
        None,
        description=(
            "Short snake_case label describing the figure (e.g. 'circuit_diagram', "
            "'geometry_figure', 'graph', 'data_table'). Optional."
        ),
    )

    # ---- Filled by pass 2 / cropper. Pass 1 leaves these null. ----
    page_index: Optional[int] = Field(
        None,
        description="0-based page index of the diagram. Filled by pass 2.",
        ge=0,
    )
    box_2d: Optional[list[int]] = Field(
        None,
        description=(
            "[ymin, xmin, ymax, xmax] in PAGE-PIXEL coordinates (not 0-1000). "
            "Filled by pass 2 after re-projecting the crop-local box back to "
            "page coords. Null until pass 2 runs."
        ),
        min_length=4,
        max_length=4,
    )
    markdown: Optional[str] = Field(
        None,
        description=(
            "For kind='table' only: the table transcribed as GitHub-Flavoured "
            "Markdown. Filled by pass 2. Null for diagrams."
        ),
    )
    filename: Optional[str] = Field(
        None,
        description=(
            "For kind='diagram' only: filled by the cropper after writing the PNG. "
            "Frontend builds the URL as `{paper_id}/images/{filename}`. Null for "
            "tables (use `markdown` instead)."
        ),
    )
    extraction_status: ExtractionStatus = Field(
        "pending",
        description=(
            "Lifecycle flag set by the pipeline. `pending` after pass 1, `ok` after "
            "successful pass-2 + crop/transcription, `needs_review` if any step "
            "produced suspicious output (degenerate bbox, token/image mismatch, "
            "fallback to question-region crop), `failed` if no usable output."
        ),
    )
    review_notes: Optional[str] = Field(
        None,
        description="Free-text reason when extraction_status != 'ok'. For the review UI.",
    )


JobState = Literal["pending", "running", "done", "failed"]


class JobProgress(BaseModel):
    page: int = 0
    total: int = 0


class JobStatus(BaseModel):
    job_id: str
    state: JobState
    progress: JobProgress = Field(default_factory=JobProgress)
    result_path: Optional[str] = None
    paper_id: Optional[str] = None
    error: Optional[str] = None

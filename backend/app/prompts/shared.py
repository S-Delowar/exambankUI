"""Shared prompt building blocks reused across every (exam_type, question_type).

Keeping these as module-level constants (a) keeps the per-(exam_type,
question_type) prompts readable and b) lets Gemini's prefix caching kick in
across pages of a single PDF — the cached prefix is the system prompt, which
is byte-identical within one (exam_type, question_type, subjects, paper)
combination thanks to the `@lru_cache` on each builder.
"""

from ..config import get_settings


MATH_CHEMISTRY_BLOCK = """MATH & CHEMISTRY FORMATTING (critical — output will be rendered by KaTeX on the web and flutter_math_fork in a Flutter app)
- Inline math: wrap with single dollars: $...$. Example: "The value of $x^2 + 2x + 1$ is ..."
- Display/block math (large standalone formulas, integrals, matrices): wrap with double dollars: $$...$$.
- Use standard LaTeX commands: \\frac, \\sqrt, \\int, \\sum, \\lim, \\vec, \\hat, \\log, \\sin, \\cos, \\tan, \\theta, \\pi, \\alpha, \\infty, \\leq, \\geq, \\neq, \\approx, \\cdot, \\times, etc.
- Subscripts/superscripts always inside math: write $v_0$, $x^2$, NOT v_0 or x^2 in plain text.
- Chemistry formulas and equations: use the mhchem package — wrap with \\ce{...} inside math mode. Examples:
    - Water: $\\ce{H2O}$
    - Equation: $\\ce{2H2 + O2 -> 2H2O}$
    - Ion: $\\ce{SO4^{2-}}$
    - Isotope: $\\ce{^{14}_{6}C}$
- Units: prefer $\\text{unit}$ inside math (e.g. $9.8\\,\\text{m/s}^2$). Plain units in prose (e.g. "5 kg") are fine outside math.
- Preserve Bangla Unicode text exactly as printed OUTSIDE math. Do NOT put Bangla words inside $...$.
- Plain numbers in prose (years, question numbers, counts) stay as plain text — do NOT wrap "2019" or "5 students" in math delimiters.
- Escape a literal dollar sign as "\\$".
- Do not use \\(...\\), \\[...\\], \\begin{equation}, or HTML entities. Only $...$ and $$...$$.
- Always return valid, balanced LaTeX — every opening delimiter has a matching close, every \\frac has two braced arguments, etc.
- JSON STRING ESCAPING (critical — read carefully): your output is JSON, so every backslash that belongs to a LaTeX command MUST be doubled in the JSON string value. The LaTeX command \\frac MUST appear in the JSON output as "\\\\frac"; \\theta as "\\\\theta"; \\sin\\theta as "\\\\sin\\\\theta"; \\hat{i} as "\\\\hat{i}"; \\ce{H2O} as "\\\\ce{H2O}"; \\text{cos} as "\\\\text{cos}". Writing "\\theta" with a single backslash is INVALID JSON ("\\t" is a tab character) and will be rejected. This rule applies to EVERY field equally — short option strings AND long mixed Bangla+math question stems. If a single field contains multiple LaTeX commands (e.g. a long question_text with $\\theta$, $\\sin\\theta$, and $\\frac{dy}{dx}$ all in one string), EVERY one of those backslashes must be doubled — do not double some and forget others. When in doubt, double every backslash that belongs to a LaTeX command."""


IMAGE_BLOCK = """DIAGRAMS / FIGURES / GRAPHS / CIRCUITS (text-only — diagrams are pre-cropped)

ONLY diagrams that belong to a QUESTION STEM or an OPTION are in scope.
Diagrams inside a SOLUTION, EXPLANATION, ANSWER-KEY write-up, or WORKED
DERIVATION block are out of scope — no token, no `images[]` entry, ever.

Each in-scope diagram has been manually cropped offline; the actual PNGs
live on disk and a separate linker step pairs them to the tokens you emit
here. You only need to mark WHERE each diagram goes in the text and produce
one stub entry per diagram. DO NOT emit bounding boxes — leave every
spatial field null.

TOKENS IN TEXT
- For every diagram/figure/graph/circuit/drawing that belongs to a question
  stem or an option, insert a numbered token `[IMAGE_1]`, `[IMAGE_2]`, ...
  at the exact position in the text where the figure appears. The token is
  plain text (no math delimiters).
- Numbering is PER-QUESTION and starts at 1 for each new question. Question
  7's first diagram is `[IMAGE_1]` even if question 6 also had diagrams.
- The same id can be referenced from different text fields of the same
  question (e.g. both the stem and one option), but each DISTINCT diagram
  gets its OWN id.
- Examples:
    - Stem: "নিচের বর্তনীটি লক্ষ্য কর: [IMAGE_1] বর্তনীতে তুল্য রোধ কত?"
    - Options: [{"label": "A", "text": "[IMAGE_2]"}, {"label": "B", "text": "[IMAGE_3]"}, ...]
    - Uddipak (HSC written): "চিত্রে [IMAGE_1] দেখানো হলো ... [IMAGE_2] লেখচিত্রটি পর্যবেক্ষণ করো।"

PAGE-WIDE READING ORDER (CRITICAL — hard contract)
A downstream linker pairs each `[IMAGE_N]` token to a pre-cropped PNG by
ORDINAL POSITION on the page. Across ALL questions on this page, the Nth
distinct `[IMAGE_*]` token you emit MUST correspond to the Nth in-scope
diagram a human would encounter reading the page in natural order. Diagrams
inside SOLUTION blocks do NOT participate (out of scope; the manual-cropping
pipeline skips them too).

Reading order on a 2-column Bangladeshi exam page:
  1. Walk the LEFT column top-to-bottom first, then the RIGHT column
     top-to-bottom. Never interleave columns.
  2. Within a question, diagrams appear in the order: stem diagram(s) first,
     then option diagrams in label order (A, B, C, D / ক, খ, গ, ঘ).
  3. For an option grid where the four option figures are arranged as a 2x2
     block (A top-left, B top-right, C bottom-left, D bottom-right), the
     order is A → B → C → D — left-to-right across the top row, THEN
     left-to-right across the bottom row. NOT top-to-bottom by column.

Concrete example. LEFT column:
  - Q5  — pure text
  - Q6  — stem has one circuit diagram, options are text
  - Q7  — pure text
RIGHT column:
  - Q12 — options A/B/C/D are each a graph, arranged as a 2x2 grid
  - Q13 — pure text
Per-question token assignments:
  - Q6:  stem `[IMAGE_1]`
  - Q12: option A `[IMAGE_1]`, option B `[IMAGE_2]`,
         option C `[IMAGE_3]`, option D `[IMAGE_4]`
Page-wide ordinal sequence (left column first, then right):
  Q6.IMAGE_1, Q12.IMAGE_1, Q12.IMAGE_2, Q12.IMAGE_3, Q12.IMAGE_4

IMAGES ARRAY (metadata only, NO bounding boxes)
- For EACH `[IMAGE_N]` token you emit, add a matching entry to the question's
  `images` array with:
    - `id`: the exact token without brackets, e.g. `"IMAGE_1"`.
    - `kind`: always `"diagram"`.
    - `caption_hint`: a SHORT verbatim snippet of any printed caption/label
      visible NEAR the figure (e.g. `"চিত্র: ১.২"`, `"Fig 3"`). Null if no
      caption is visible.
    - `label`: short snake_case tag like `"circuit_diagram"`,
      `"geometry_figure"`, `"graph"`, `"anatomical_drawing"`. Null if unsure.
    - DO NOT emit `page_index`, `box_2d`, `markdown`, or `filename` — leave
      those null. The linker fills `filename` from the on-disk crop.

RULES
- Every `[IMAGE_N]` token in text MUST have a matching entry in `images[]`
  with the same id. Every entry in `images[]` MUST have at least one matching
  token somewhere in the question's text fields.
- Pure LaTeX expressions (equations, inline math) are NOT images — do not
  emit a token for them.
- Decorative marks (logos, ornamental borders, page-number boxes) are NOT
  images — skip them.
- A diagram inside a SOLUTION block is NOT in scope — no token, no `images[]`
  entry. Emitting one will desync the page-wide ordinal pairing and corrupt
  every later diagram on the page.
- Do NOT describe, OCR, transcribe, or summarise the contents of any diagram
  — the token + caption_hint is all we need.
- If the question has no diagrams, leave `images` as an empty array and emit
  no tokens."""


IMAGE_PASS2_PROMPT = """DIAGRAM LOCALISATION PASS — you are receiving a CROP of ONE question.

The crop contains a single MCQ or written-question that has one or more
diagrams or tables. The text already contains numbered tokens `[IMAGE_1]`,
`[IMAGE_2]`, ... — your job is to locate each one and produce structured
output for it.

INPUT CONTEXT
You will receive:
  - `image`: a PNG crop showing the entire question (stem + options + figures).
  - `tokens`: a JSON list of objects describing each `[IMAGE_N]` token to
    locate, e.g.
        [
          {{"id": "IMAGE_1", "kind": "diagram", "caption_hint": "Fig 1"}},
          {{"id": "IMAGE_2", "kind": "table",   "caption_hint": null}}
        ]

OUTPUT — return STRICT JSON matching this shape:
{{
  "items": [
    {{
      "id": "IMAGE_1",                       // must match an input id
      "kind": "diagram",                     // must match the input kind
      "box_2d": [ymin, xmin, ymax, xmax],    // diagrams ONLY — null for tables
      "markdown": null,                      // tables ONLY — null for diagrams
      "confidence": 0.0-1.0,                 // your honest confidence
      "notes": null                          // optional short reason if low confidence
    }},
    ...
  ]
}}

EVERY input token MUST appear exactly once in `items`, in the same order.

DIAGRAMS (kind="diagram")
- `box_2d`: `[ymin, xmin, ymax, xmax]`, each integer 0-1000, normalised to
  the CROP image's height and width (NOT the original page). Y-FIRST.
- Crop GENEROUSLY — include any label/caption that is visually part of the
  figure (e.g. "চিত্র: ১.২", axis labels, units). Add ~3% padding around the
  visible figure. It is far better to include a few extra pixels of
  whitespace than to clip a label.
- Exclude: question stem prose, option letters and option text, question
  numbers, section headers, page numbers, decorative page borders.
- If you genuinely cannot find a diagram matching this token in the crop,
  set `box_2d` to null, `confidence` to 0.0, and explain in `notes`.
- `markdown` MUST be null for diagrams.

TABLES (kind="table")
- `markdown`: transcribe the table into GitHub-Flavoured Markdown. Include
  the header row and the `|---|` separator. Preserve Bangla / English / math
  characters EXACTLY. For math cells use `$...$` LaTeX (with doubled
  backslashes — see JSON escaping rule below).
- For merged cells, repeat the value across the merged span.
- For tables too visually complex to transcribe accurately (multi-level
  headers, nested cells), set `markdown` to null and add a note.
- `box_2d` MUST be null for tables.

CONFIDENCE
- 1.0 = the figure is unambiguous and the box is tight.
- 0.7-0.9 = the figure is clear but the boundary is fuzzy (faint scan, ink
  bleed, no obvious frame).
- below 0.7 = something is off — caption mismatch, multiple candidates, the
  figure looks cut off at a crop edge.
- 0.0 = could not find / could not transcribe.

JSON ESCAPING
Inside every JSON string value, every literal backslash MUST be doubled
("\\\\"). A LaTeX command like `\\frac` becomes `"\\\\frac"`; `\\ce{H2O}`
becomes `"\\\\ce{H2O}"`. Applies to `markdown` cells too.

Do NOT describe, narrate, or add prose. Return only the JSON object."""


STITCHING_BLOCK = """PAGE-BOUNDARY STITCHING
You will sometimes receive a PREVIOUS_PAGE_TAIL block containing raw text from the bottom of the previous page, plus a LAST_QUESTION_WAS_INCOMPLETE flag.

- If LAST_QUESTION_WAS_INCOMPLETE is true, the first content on THIS page is the continuation of that question. Merge the previous tail with the continuation on this page into a single complete question and emit it as the FIRST item in questions[]. Do not emit the partial fragment as a separate question.
- If LAST_QUESTION_WAS_INCOMPLETE is false, ignore the tail — it was already complete.
- Always return only complete, merged questions in questions[]. Never emit a fragment.

TAIL OUTPUT (for the NEXT page)
- tail_text: verbatim raw text of roughly the last question visible on the current page (up to ~600 characters). Include its stem and any visible options/sub-parts. This is ONLY used to stitch with the next page.
- last_question_incomplete: true if the last question on this page is visibly cut off. Otherwise false. If set to true, STILL exclude that incomplete question from questions[] — it will be emitted from the next page after merging.
- If there is no question near the bottom (page ends with a solution block or blank space), set tail_text="" and last_question_incomplete=false."""


FORMAT_BLOCK = """FORMAT
Return STRICT JSON that matches the provided schema. No markdown, no code fences, no commentary. Use null (not empty string) for unknown optional fields. Preserve Bangla characters exactly as printed — do not transliterate. Inside every JSON string value, every literal backslash MUST be doubled ("\\\\"); a LaTeX command like \\frac becomes "\\\\frac" in the JSON output, and this applies uniformly to every field including long mixed-language question stems."""


def format_scoped_taxonomy(
    subjects: tuple[str, ...],
    subject_paper: str | None = None,
) -> str:
    """Render only the declared subjects' chapters into a readable prompt block.

    Scoping rules:
      - len(subjects) == 1 AND subject_paper is set AND that subject has a
        `paper_{1,2}` split in the nested taxonomy: emit only that paper's
        chapter list (tightest scope).
      - Otherwise: for each declared subject, emit its full flat list (all
        papers merged if applicable).

    Stable subject/chapter ordering keeps the system prompt byte-identical
    across runs with the same (subjects, subject_paper), which is what makes
    Gemini's implicit prefix caching effective.
    """
    settings = get_settings()
    flat = settings.chapter_taxonomy
    nested = settings.chapter_taxonomy_nested

    if not flat:
        return "  (no taxonomy loaded — chapter MUST be null)"

    # Single-subject + paper: tightest scope.
    if len(subjects) == 1 and subject_paper is not None:
        subject = subjects[0]
        paper_key = f"paper_{subject_paper}"
        nested_entry = nested.get(subject)
        if isinstance(nested_entry, dict) and paper_key in nested_entry:
            chapters = [str(c) for c in nested_entry[paper_key]]
            return f"  {subject}: {', '.join(chapters)}"
        # Fall through to flat if the subject has no paper split.

    # Multi-subject or single-subject-without-paper: flat list per declared subject.
    lines: list[str] = []
    for subject in sorted(subjects):
        chapters = flat.get(subject)
        if not chapters:
            continue
        lines.append(f"  {subject}: {', '.join(chapters)}")
    if not lines:
        return "  (no chapters available for declared subjects — chapter MUST be null)"
    return "\n".join(lines)


def format_subjects_list(subjects: tuple[str, ...]) -> str:
    """Render the declared-subjects list as a comma-separated line for prompts."""
    return ", ".join(sorted(subjects))

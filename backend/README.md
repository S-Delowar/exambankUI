# ExamBank Backend

FastAPI service that extracts MCQs from scanned PDFs (Bangladeshi public-university admission-test question banks) using Gemini.

## Setup

```bash
cd backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

cp .env.example .env
# edit .env and set GEMINI_API_KEY
```

Configuration lives in two places:

- `.env` — secrets only (`GEMINI_API_KEY`).
- `config.yaml` — non-secret runtime settings:

  | Key | Default | Purpose |
  |---|---|---|
  | `gemini_model` | `gemini-2.5-flash` | Model name. |
  | `request_pause_seconds` | `2.0` | Sleep between Gemini calls (rate limit). |
  | `output_dir` | `./output` | Where extracted JSON files are saved. |
  | `render_dpi` | `200` | DPI used when rendering PDF pages to images. |
  | `max_pages` | `15` | Reject PDFs with more pages. |
  | `tail_context_chars` | `600` | How much previous-page tail to pass to the next page. |
  | `max_upload_mb` | `50` | Upload size cap. |

## Run

```bash
uvicorn app.main:app --reload --port 8000
```

## API

### `POST /extract`

Multipart upload of a single PDF. Validates and enqueues a background extraction job.

```bash
curl -F "file=@sample.pdf" http://localhost:8000/extract
# {"job_id":"...","state":"pending","progress":{"page":0,"total":0},"result_path":null,"error":null}
```

### `GET /jobs/{job_id}`

Poll for status. `state` is one of `pending | running | done | failed`.

```bash
curl http://localhost:8000/jobs/<job_id>
```

### `GET /jobs/{job_id}/result`

Download the final JSON file once `state=done`.

```bash
curl -o result.json http://localhost:8000/jobs/<job_id>/result
```

### `GET /health`

Liveness probe.

## How extraction works

1. PDF is rendered page-by-page to PNG with PyMuPDF.
2. Each page is sent to Gemini with a structured-output schema (`PageExtraction`).
3. The model returns questions plus a `tail_text` + `last_question_incomplete` flag.
4. The next page's prompt receives the previous tail and flag; the model merges questions that span a page boundary and emits the merged question as the first item on the next page.
5. All pages' questions are concatenated and saved to `{output_dir}/{job_id}_{sanitized_filename}.json`.

## Output shape

```json
{
  "source_filename": "sample.pdf",
  "page_count": 12,
  "questions": [
    {
      "university_name": "Dhaka University",
      "exam_year": 2019,
      "exam_unit": "A",
      "question_number": "1",
      "question_text": "...",
      "options": [
        {"label": "A", "text": "..."},
        {"label": "B", "text": "..."},
        {"label": "C", "text": "..."},
        {"label": "D", "text": "..."}
      ],
      "correct_answer": "B"
    }
  ]
}
```

## Notes

- In-memory job store — jobs are lost on restart. DB persistence is planned.
- Bangla text is preserved (output is written with `ensure_ascii=False`).
- Retries once on transient Gemini failures with a 10-second backoff.

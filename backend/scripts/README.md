# Backend Scripts

Utility scripts for image cropping, processing, and data management.

## Image Cropping Scripts

### `crop_figures_batch.py`

Batch-crop figures from PDFs using rectangle annotations.

**Usage:**
```bash
# Crop all PDFs in a directory
python -m backend.scripts.crop_figures_batch ./pdfs

# Crop with custom output directory
python -m backend.scripts.crop_figures_batch ./pdfs ./output

# Crop single PDF
python -m backend.scripts.crop_figures_batch ./physics.pdf
```

**Features:**
- Detects red/green/magenta rectangle annotations
- Crops in reading order (left column → right column)
- Removes annotation colors
- Saves to `backend/data/cropped_images/{paper_name}/`

**Requirements:**
- opencv-python
- pymupdf

---

### `describe_with_gemini.py`

Generate text descriptions of cropped figures using Gemini.

**Usage:**
```bash
export GEMINI_API_KEY="your_key_here"
python -m backend.scripts.describe_with_gemini Physics_2023_Paper_1
```

**Output:**
- Creates `image{N}.txt` next to each `image{N}.png`
- Contains Gemini's description of the figure

**Use cases:**
- Generate alt text for accessibility
- Create figure captions
- OCR text from diagrams
- Verify figure content

---

### `redraw_with_gemini.py`

Redraw cropped figures as clean SVG using Gemini, then rasterize to PNG.

**Usage:**
```bash
export GEMINI_API_KEY="your_key_here"
python -m backend.scripts.redraw_with_gemini Physics_2023_Paper_1
```

**Output:**
- `image{N}.redrawn.svg` - Vector reconstruction
- `image{N}.redrawn.png` - High-DPI raster

**Best for:**
- Line drawings (circuits, graphs, geometry)
- Free-body diagrams
- Coordinate systems
- Clean vector versions of scanned figures

**Not suitable for:**
- Photographs
- Complex shaded diagrams
- Handwritten content

**Requirements:**
- google-genai
- cairosvg

---

## Other Scripts

### `reimport_papers_from_json.py`

Re-import extraction results from JSON files into the database.

**Location:** `backend/scripts/reimport_papers_from_json.py`

**Usage:**
```bash
python backend/scripts/reimport_papers_from_json.py
```

---

### `backfill_image_links.py`

Backfill image links for existing papers in the database.

**Location:** `backend/scripts/backfill_image_links.py`

**Usage:**
```bash
python backend/scripts/backfill_image_links.py
```

---

## Directory Structure

```
backend/
  scripts/
    crop_figures_batch.py       # Batch cropping CLI
    describe_with_gemini.py     # Generate descriptions
    redraw_with_gemini.py       # Redraw as SVG
    reimport_papers_from_json.py
    backfill_image_links.py
  data/
    cropped_images/             # Output from cropping
      {paper_name}/
        page_1/
          image1.png
          image1.txt            # From describe_with_gemini
          image1.redrawn.svg    # From redraw_with_gemini
          image1.redrawn.png
```

---

## Workflow Examples

### Complete Cropping Workflow

```bash
# 1. Annotate PDF with red rectangles (use PDF editor)

# 2. Crop figures
python -m backend.scripts.crop_figures_batch ./annotated.pdf

# 3. Generate descriptions (optional)
export GEMINI_API_KEY="your_key"
python -m backend.scripts.describe_with_gemini annotated

# 4. Redraw as SVG (optional)
python -m backend.scripts.redraw_with_gemini annotated

# 5. Extract questions (images auto-link)
curl -X POST "http://localhost:8000/extract?..." \
  -F "file=@annotated.pdf"
```

### Batch Processing Multiple PDFs

```bash
# Organize PDFs
mkdir pdfs
cp physics_2023.pdf chemistry_2023.pdf pdfs/

# Crop all at once
python -m backend.scripts.crop_figures_batch pdfs/

# Process each paper
for paper in backend/data/cropped_images/*/; do
    paper_name=$(basename "$paper")
    python -m backend.scripts.describe_with_gemini "$paper_name"
done
```

---

## API vs Scripts

| Feature | API (`/crop-images`) | Script (`crop_figures_batch.py`) |
|---------|---------------------|----------------------------------|
| **Access** | HTTP endpoint | Command line |
| **Authentication** | Admin token required | None |
| **Input** | Single PDF upload | Directory or single file |
| **Output** | JSON response | Console output |
| **Use case** | Web UI, automation | Batch processing, local dev |

**Recommendation:** Use API for production, scripts for development/testing.

---

## Dependencies

Install all dependencies:
```bash
cd backend
pip install -r requirements.txt
```

Additional dependencies for Gemini scripts:
```bash
pip install google-genai cairosvg
```

---

## Troubleshooting

### Import Errors

**Symptom:** `ModuleNotFoundError: No module named 'app'`

**Solution:**
```bash
# Run from project root
cd /path/to/ExamBank
python -m backend.scripts.crop_figures_batch ...

# Or add backend to PYTHONPATH
export PYTHONPATH=/path/to/ExamBank/backend:$PYTHONPATH
```

### Gemini API Errors

**Symptom:** `ERROR: set GEMINI_API_KEY environment variable`

**Solution:**
```bash
export GEMINI_API_KEY="your_key_here"
# Or add to backend/.env
echo "GEMINI_API_KEY=your_key" >> backend/.env
```

### No Figures Found

**Symptom:** `✗ No figures found`

**Solution:**
- Ensure PDF has rectangle annotations
- Use red, green, or magenta colors
- Annotations must be actual PDF annotations (not drawn with pen tool)

---

## Migration from test-cropping

If you have scripts in the old `test-cropping/` directory:

1. **Use new scripts:**
   ```bash
   # Old
   python test-cropping/crop_figures_batch.py
   
   # New
   python -m backend.scripts.crop_figures_batch ./pdfs
   ```

2. **Move existing crops:**
   ```bash
   mv test-cropping/cropped_images/* backend/data/cropped_images/
   ```

3. **Delete old directory:**
   ```bash
   rm -rf test-cropping/
   ```

See `backend/MIGRATION_CROPPED_IMAGES.md` for details.

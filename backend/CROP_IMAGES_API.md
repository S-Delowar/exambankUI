# Image Cropping API

## Overview

The `/crop-images` endpoint detects and crops figures from PDFs based on rectangle annotations. Cropped images are saved to the manual crops directory and automatically linked during question extraction.

## Endpoint

```
POST /crop-images
```

**Authentication:** Requires admin token

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `file` | File | Yes | PDF file with rectangle annotations |
| `paper_name` | Query String | Yes | Name for the cropped images folder (e.g., "Physics_2023_Dhaka_Board_Paper_1") |

## Workflow

### 1. Annotate PDF

Use a PDF editor (Adobe Acrobat, Preview, etc.) to draw **red rectangles** around figures:

- Draw rectangles around diagrams, graphs, circuits, tables
- Rectangles can be red, green, or magenta
- Ensure rectangles fully enclose the figure
- Avoid overlapping rectangles

### 2. Upload and Crop

```bash
curl -X POST "http://localhost:8000/crop-images?paper_name=Physics_2023_Dhaka_Board_Paper_1" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -F "file=@physics_paper.pdf"
```

**Response:**
```json
{
  "paper_name": "Physics_2023_Dhaka_Board_Paper_1",
  "crop_folder": "/path/to/manual_crops/Physics_2023_Dhaka_Board_Paper_1",
  "pages_with_figures": 8,
  "total_figures": 15,
  "pages_processed": 10,
  "message": "Successfully cropped 15 figure(s) from 8 page(s). Saved to: ..."
}
```

### 3. Review Crops (Optional)

Check the cropped images:
```
backend/data/cropped_images/
  Physics_2023_Dhaka_Board_Paper_1/
    page_1/
      image1.png
      image2.png
    page_2/
      image1.png
    ...
```

### 4. Extract Questions

Upload the same PDF for extraction:
```bash
curl -X POST "http://localhost:8000/extract?exam_type=hsc_board&question_type=mcq&subjects=physics&subject_paper=1" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -F "file=@physics_paper.pdf"
```

The extraction pipeline will **automatically link** cropped images if the paper name matches.

## Paper Name Matching

The `paper_name` parameter should match the paper stem used during extraction for automatic linking.

**Naming conventions:**

| Exam Type | Example paper_name |
|-----------|-------------------|
| HSC Board | `Physics_2023_Dhaka_Board_Paper_1` |
| HSC Board | `Chemistry_2022_Rajshahi_Board_Paper_2` |
| Admission | `DU_2023_2024_A_Unit` |
| Admission | `BUET_2022_2023` |

**Tips:**
- Use underscores instead of spaces
- Include year, board/university, subject, paper number
- Be consistent between cropping and extraction
- Check `manual_crops_alias` in config for custom mappings

## Output Structure

Cropped images are saved in reading order:

```
<paper_name>/
  page_1/
    image1.png  ← First figure on page 1 (left column, top)
    image2.png  ← Second figure on page 1
  page_2/
    image1.png  ← First figure on page 2
    image2.png
    image3.png
```

**Reading order:**
1. Left column, top to bottom
2. Right column, top to bottom
3. Within a row, left to right (for 2x2 option grids)

## Error Handling

### No Figures Found

```json
{
  "paper_name": "Physics_2023_Dhaka_Board_Paper_1",
  "crop_folder": "...",
  "pages_with_figures": 0,
  "total_figures": 0,
  "pages_processed": 10,
  "message": "No figures found in physics_paper.pdf. Ensure the PDF has rectangle annotations around figures."
}
```

**Solution:** Add rectangle annotations to the PDF

### Invalid PDF

```json
{
  "detail": "Could not open PDF: ..."
}
```

**Solution:** Ensure the file is a valid PDF

### File Too Large

```json
{
  "detail": "File too large (52.3 MB > 50 MB)."
}
```

**Solution:** Reduce PDF size or increase `max_upload_mb` in config

## Configuration

Edit `backend/.env` or `backend/config.yaml`:

```yaml
manual_crops_dir: "./data/cropped_images"
max_upload_mb: 50

# Optional: Map paper stems to crop folder names
manual_crops_alias:
  "Dhaka_University_2019_20_unit_A_mcq": "DU-2019-2020-A-Unit"
```

## Integration with Extraction

The extraction pipeline automatically links cropped images:

1. **During extraction**, the image linker looks for a crop folder matching the paper stem
2. **If found**, it pairs `[IMAGE_N]` tokens with `imageN.png` files in reading order
3. **If not found**, images are marked as `needs_review` (extraction still succeeds)

**Linking logic:**
```python
# Extraction generates paper_stem from filename or metadata
paper_stem = "Physics_2023_Dhaka_Board_Paper_1"

# Linker looks for matching crop folder
crop_folder = manual_crops_path / paper_stem
# OR uses alias mapping
crop_folder = manual_crops_path / manual_crops_alias.get(paper_stem, paper_stem)

# Pairs tokens with files
[IMAGE_1] → page_1/image1.png
[IMAGE_2] → page_1/image2.png
```

## Best Practices

### Annotation Guidelines

✅ **Do:**
- Draw rectangles tightly around figures
- Use consistent colors (red recommended)
- Annotate all figures on all pages
- Include figure captions if present

❌ **Don't:**
- Annotate text-only content
- Annotate solution diagrams (only question diagrams)
- Draw overlapping rectangles
- Annotate page numbers or headers

### Naming Guidelines

✅ **Do:**
- Use descriptive, consistent names
- Include year, board, subject, paper
- Use underscores for spaces
- Keep names under 200 characters

❌ **Don't:**
- Use special characters (/, \, :, *, ?, ", <, >, |)
- Use spaces (use underscores instead)
- Use ambiguous names ("paper1", "test")

### Workflow Tips

1. **Batch cropping**: Crop multiple PDFs before extraction
2. **Review crops**: Check cropped images before extraction
3. **Re-crop if needed**: Delete crop folder and re-run if annotations were wrong
4. **Consistent naming**: Use the same naming convention across all papers

## Troubleshooting

### Images Not Linking During Extraction

**Symptom:** Extraction succeeds but images are marked as `needs_review`

**Causes:**
1. Paper name mismatch between cropping and extraction
2. Crop folder doesn't exist
3. Image count mismatch (more tokens than crops)

**Solution:**
- Check crop folder name matches paper stem
- Verify crops exist: `ls manual_crops_path/paper_name/`
- Check extraction logs for linking errors

### Wrong Reading Order

**Symptom:** Images linked to wrong questions

**Causes:**
1. Annotations not in reading order
2. Mixed column layout
3. Overlapping rectangles

**Solution:**
- Re-annotate in correct reading order (left column first, then right)
- Ensure rectangles don't overlap
- Check 2x2 grids are annotated A→B→C→D (left-to-right, top-to-bottom)

### Cropped Images Have Red Borders

**Symptom:** Cropped images include red annotation lines

**Causes:**
- Border inset too small
- Thick annotation lines

**Solution:**
- Increase `BORDER_INSET_PX` in `image_cropper.py`
- Use thinner annotation lines

## API Examples

### Python

```python
import requests

url = "http://localhost:8000/crop-images"
params = {"paper_name": "Physics_2023_Dhaka_Board_Paper_1"}
headers = {"Authorization": "Bearer YOUR_ADMIN_TOKEN"}
files = {"file": open("physics_paper.pdf", "rb")}

response = requests.post(url, params=params, headers=headers, files=files)
result = response.json()

print(f"Cropped {result['total_figures']} figures")
print(f"Saved to: {result['crop_folder']}")
```

### JavaScript

```javascript
const formData = new FormData();
formData.append('file', pdfFile);

const response = await fetch(
  'http://localhost:8000/crop-images?paper_name=Physics_2023_Dhaka_Board_Paper_1',
  {
    method: 'POST',
    headers: {
      'Authorization': 'Bearer YOUR_ADMIN_TOKEN'
    },
    body: formData
  }
);

const result = await response.json();
console.log(`Cropped ${result.total_figures} figures`);
```

## Related Endpoints

- `POST /extract` - Extract questions from PDF (automatically links cropped images)
- `GET /jobs/{job_id}` - Check extraction job status
- `GET /jobs/{job_id}/result` - Download extraction result JSON

## Technical Details

### Image Processing

- **DPI:** 600 (high resolution for quality crops)
- **Format:** PNG (lossless)
- **Color correction:** Red/green/magenta annotations replaced with white
- **Border handling:** 10px inset to exclude annotation lines

### Annotation Detection

- **Supported types:** Rectangle, Ink, Polygon annotations
- **Supported colors:** Red, Green, Magenta (HSV-based detection)
- **Deduplication:** Overlapping boxes merged (IOU threshold: 0.5)
- **Minimum size:** 8000 pixels² (filters out small artifacts)

### Performance

- **Processing time:** ~2-5 seconds per page (depends on figure count)
- **Memory usage:** ~100-200 MB per PDF
- **Concurrent uploads:** Supported (each upload is independent)

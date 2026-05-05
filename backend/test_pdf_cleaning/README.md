# PDF Cleaning Tool

Remove background noise from scanned PDFs using adaptive thresholding.

## Directory Structure

```
test_pdf_cleaning/
├── input/          # Place your PDFs here
├── output/         # Cleaned PDFs will be saved here
├── clean_pdfs.py   # Main script
└── README.md       # This file
```

## Usage

### 1. Place PDFs in input directory

```bash
cp your_scanned_document.pdf backend/test_pdf_cleaning/input/
```

### 2. Run the script

```bash
cd backend/test_pdf_cleaning
python clean_pdfs.py
```

### 3. Get cleaned PDFs from output directory

```bash
ls output/
# cleaned_your_scanned_document.pdf
```

## What It Does

The script processes each PDF page by:

1. **Rendering** - Converts PDF page to image (300 DPI)
2. **Grayscale conversion** - Converts to grayscale
3. **Bilateral filtering** - Reduces noise while preserving text edges
4. **Adaptive thresholding** - Creates clean binary image (black text on white)
5. **PDF creation** - Converts cleaned images back to PDF

## Parameters

You can adjust cleaning parameters in `clean_pdfs.py`:

```python
# Bilateral filter
denoised = cv2.bilateralFilter(gray, 9, 75, 75)
#                                    ^  ^^  ^^
#                                    |  |   |
#                        diameter ---+  |   |
#                        sigmaColor ----+   |
#                        sigmaSpace --------+

# Adaptive threshold
clean_img = cv2.adaptiveThreshold(
    denoised, 255,
    cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
    cv2.THRESH_BINARY,
    21,  # block_size (must be odd) - larger = more aggressive
    15   # C constant - larger = removes more background
)
```

### Tuning Guide

**If text is too faint:**
- Decrease `C` constant (e.g., 10 instead of 15)

**If too much background remains:**
- Increase `C` constant (e.g., 20 instead of 15)
- Increase `block_size` (e.g., 25 instead of 21)

**If text edges are rough:**
- Increase bilateral filter parameters (e.g., 11, 100, 100)

**If processing is slow:**
- Decrease DPI (e.g., 200 instead of 300)

## Examples

### Before (Noisy Scan)
- Background texture visible
- Uneven lighting
- Paper grain
- Faded text

### After (Cleaned)
- Pure white background
- Sharp black text
- No noise
- Consistent contrast

## Requirements

```bash
pip install opencv-python pymupdf numpy
```

## Batch Processing

The script automatically processes all PDFs in the input directory:

```bash
# Process multiple files
cp file1.pdf file2.pdf file3.pdf backend/test_pdf_cleaning/input/
python clean_pdfs.py

# Output:
# output/cleaned_file1.pdf
# output/cleaned_file2.pdf
# output/cleaned_file3.pdf
```

## Advanced Usage

### Custom DPI

Edit `clean_pdfs.py` and change the DPI parameter:

```python
clean_pdf(pdf_path, output_path, dpi=200)  # Faster, lower quality
clean_pdf(pdf_path, output_path, dpi=400)  # Slower, higher quality
```

### Process Single File

```python
from pathlib import Path
from clean_pdfs import clean_pdf

clean_pdf(
    Path("input/my_document.pdf"),
    Path("output/cleaned_my_document.pdf"),
    dpi=300
)
```

### Custom Parameters

```python
def clean_image_custom(img_array):
    gray = cv2.cvtColor(img_array, cv2.COLOR_BGR2GRAY)
    
    # More aggressive denoising
    denoised = cv2.bilateralFilter(gray, 11, 100, 100)
    
    # Stronger thresholding
    clean_img = cv2.adaptiveThreshold(
        denoised, 255,
        cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
        cv2.THRESH_BINARY,
        25,  # Larger block
        20   # Higher constant
    )
    
    return clean_img
```

## Troubleshooting

### "No PDF files found"

**Solution:** Place PDF files in the `input/` directory

### "Module not found: cv2"

**Solution:** Install OpenCV
```bash
pip install opencv-python
```

### "Module not found: fitz"

**Solution:** Install PyMuPDF
```bash
pip install pymupdf
```

### Output is too dark/light

**Solution:** Adjust the `C` constant in adaptive thresholding

### Processing is very slow

**Solution:** Reduce DPI (e.g., 200 instead of 300)

### Text is broken/pixelated

**Solution:** Increase DPI (e.g., 400 instead of 300)

## Use Cases

- **Scanned exam papers** - Remove paper texture and shadows
- **Old documents** - Clean yellowed or stained pages
- **Photocopies** - Remove copy artifacts
- **Camera photos** - Clean documents photographed with phone
- **Faxes** - Remove fax noise and artifacts

## Limitations

- **Color documents** - Converts to black and white
- **Photos/images** - Will be binarized (not suitable for photos)
- **Complex layouts** - Works best with text documents
- **Handwriting** - May remove faint handwriting

## Integration with Extraction

After cleaning PDFs, you can extract questions:

```bash
# 1. Clean the PDF
python backend/test_pdf_cleaning/clean_pdfs.py

# 2. Extract questions from cleaned PDF
curl -X POST "http://localhost:8000/extract?exam_type=hsc_board&question_type=mcq&subjects=physics&subject_paper=1" \
  -H "Authorization: Bearer TOKEN" \
  -F "file=@backend/test_pdf_cleaning/output/cleaned_physics_2023.pdf"
```

**Benefits:**
- Better OCR accuracy
- Cleaner image crops
- Smaller file sizes
- Faster processing

## Performance

**Typical processing time:**
- 1 page: ~2-3 seconds
- 10 pages: ~20-30 seconds
- 50 pages: ~2-3 minutes

**Depends on:**
- DPI setting
- Page complexity
- CPU speed
- Image size

## Tips

1. **Test with one page first** - Adjust parameters before batch processing
2. **Keep originals** - Always keep original PDFs as backup
3. **Check output quality** - Verify text is readable before deleting originals
4. **Use high DPI for small text** - 300+ DPI for exam papers with small fonts
5. **Batch similar documents** - Use same parameters for similar scan quality

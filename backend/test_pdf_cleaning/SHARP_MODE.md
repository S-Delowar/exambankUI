# Sharp Text Enhancement

## Two Versions Available

### **1. clean_pdfs.py** (Standard)
- Balanced noise removal and text clarity
- Good for most documents

### **2. clean_pdfs_sharp.py** (Sharp) ⭐ **NEW**
- Enhanced text sharpness
- Crisper edges
- Better for small text

---

## What's Different in Sharp Mode?

### **Standard Version**
```python
# 1. Bilateral filter
denoised = cv2.bilateralFilter(gray, 9, 75, 75)

# 2. Adaptive threshold
binary = cv2.adaptiveThreshold(denoised, 255, 
    cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY, 21, 15)
```

### **Sharp Version**
```python
# 1. Sharpen FIRST (new!)
kernel_sharpen = np.array([
    [-1, -1, -1],
    [-1,  9, -1],
    [-1, -1, -1]
])
sharpened = cv2.filter2D(gray, -1, kernel_sharpen)

# 2. Less aggressive bilateral filter
denoised = cv2.bilateralFilter(sharpened, 7, 50, 50)

# 3. Smaller block size for sharper edges
binary = cv2.adaptiveThreshold(denoised, 255,
    cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY, 15, 10)

# 4. Morphological closing to fill gaps (new!)
kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (2, 2))
closed = cv2.morphologyEx(binary, cv2.MORPH_CLOSE, kernel)
```

---

## Key Enhancements

### **1. Sharpening Filter**
```python
kernel_sharpen = [
    [-1, -1, -1],
    [-1,  9, -1],
    [-1, -1, -1]
]
```

**What it does:**
- Enhances edges by amplifying differences
- Makes text boundaries crisper
- Applied BEFORE denoising to preserve detail

**Effect:**
- Blurry edges → Sharp edges
- Faded text → Darker, clearer text

---

### **2. Optimized Bilateral Filter**
```python
# Standard: (9, 75, 75) - more smoothing
# Sharp:    (7, 50, 50) - less smoothing
```

**Why less smoothing?**
- Preserves the sharpness from step 1
- Still removes noise but keeps detail

---

### **3. Smaller Threshold Block**
```python
# Standard: blockSize=21 - larger area
# Sharp:    blockSize=15 - smaller area
```

**Effect:**
- Smaller blocks = more local adaptation
- Better for small text
- Sharper character edges

---

### **4. Morphological Closing**
```python
kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (2, 2))
closed = cv2.morphologyEx(binary, cv2.MORPH_CLOSE, kernel)
```

**What it does:**
- Fills small gaps in text strokes
- Makes characters more solid
- Removes tiny holes

**Before:**
```
Text with gaps: ╔═╗  ╔═╗  ╔═╗
                ║ ║  ║ ║  ║ ║  (broken strokes)
                ╚═╝  ╚═╝  ╚═╝
```

**After:**
```
Solid text:     ███  ███  ███
                ███  ███  ███  (filled strokes)
                ███  ███  ███
```

---

## Comparison

| Aspect | Standard | Sharp |
|--------|----------|-------|
| **Text edges** | Smooth | Crisp |
| **Small text** | Good | Better |
| **Noise removal** | More aggressive | Balanced |
| **Character gaps** | May have gaps | Filled |
| **Processing time** | Faster | Slightly slower |
| **Best for** | General documents | Exam papers, small fonts |

---

## Output Files

### **Standard Version**
```
output/
├── cleaned_HM all board 2019 MCQ .pdf
└── cleaned_HM all boards 2025 cq mcq.pdf
```

### **Sharp Version**
```
output/
├── sharp_HM all board 2019 MCQ .pdf
└── sharp_HM all boards 2025 cq mcq.pdf
```

---

## Which One to Use?

### **Use Standard (clean_pdfs.py) when:**
- ✅ Document has heavy noise/artifacts
- ✅ Text is already clear
- ✅ Want maximum noise removal
- ✅ Processing speed matters

### **Use Sharp (clean_pdfs_sharp.py) when:**
- ✅ Text is small or faded
- ✅ Need maximum clarity for OCR
- ✅ Exam papers with mathematical symbols
- ✅ Want crisper, more readable output

---

## Usage

### **Standard Version**
```bash
cd backend/test_pdf_cleaning
python clean_pdfs.py
# Output: cleaned_*.pdf
```

### **Sharp Version**
```bash
cd backend/test_pdf_cleaning
python clean_pdfs_sharp.py
# Output: sharp_*.pdf
```

### **Process Both**
```bash
# Get both versions for comparison
python clean_pdfs.py
python clean_pdfs_sharp.py

# Compare results
open output/cleaned_document.pdf
open output/sharp_document.pdf
```

---

## Visual Comparison

### **Original Scan**
```
Text: Slightly blurry, gray
Background: Noisy, textured
Small text: Hard to read
```

### **Standard Clean**
```
Text: Clear, black
Background: White, clean
Small text: Readable
```

### **Sharp Clean**
```
Text: Very crisp, solid black
Background: Pure white
Small text: Very clear
Edges: Sharp and defined
```

---

## Parameter Tuning

### **For Even Sharper Text**

Edit `clean_pdfs_sharp.py`:

```python
# Stronger sharpening
kernel_sharpen = np.array([
    [-1, -1, -1],
    [-1, 11, -1],  # Increase center value (was 9)
    [-1, -1, -1]
])

# Smaller threshold block
binary = cv2.adaptiveThreshold(
    denoised, 255,
    cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
    cv2.THRESH_BINARY,
    11,  # Even smaller (was 15)
    8    # Lower constant (was 10)
)
```

### **For Less Aggressive Sharpening**

```python
# Gentler sharpening
kernel_sharpen = np.array([
    [0, -1, 0],
    [-1, 5, -1],  # Lower center value
    [0, -1, 0]
])

# Larger threshold block
binary = cv2.adaptiveThreshold(
    denoised, 255,
    cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
    cv2.THRESH_BINARY,
    19,  # Larger (was 15)
    12   # Higher constant (was 10)
)
```

---

## Recommendation

**For your exam papers:** Use **sharp version** (`clean_pdfs_sharp.py`)

**Why:**
- ✅ Better for mathematical symbols
- ✅ Clearer small text
- ✅ Crisper diagrams
- ✅ Better OCR accuracy
- ✅ More professional appearance

**Already processed:** Both versions are in `output/` folder - compare and choose!

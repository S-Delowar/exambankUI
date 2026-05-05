# Metadata Extraction & Propagation

## Overview

The extraction pipeline uses a **"latch, update, and backfill"** strategy to handle metadata (board name, exam year, university name, etc.) across multi-page PDFs. This ensures consistent metadata even when the model doesn't extract it from every page, while also supporting PDFs with multiple exams (different boards/years).

---

## How It Works

### **Three-Step Process**

```
1. LATCH & UPDATE → Extract metadata from each page, update when changes detected
2. PROPAGATE      → Pass current `known` metadata to subsequent pages via user prompt
3. BACKFILL       → Fill missing metadata on all questions at the end
```

---

## Step-by-Step Flow

### **1. Initialization**

Before processing any pages, initialize a `known` metadata dictionary:

```python
# HSC Board
_LATCH_KEYS = ("board_name", "exam_year")
known: dict[str, object | None] = {k: None for k in _LATCH_KEYS}

# Admission Test
_LATCH_KEYS = ("university_name", "exam_session", "exam_unit")
known: dict[str, object | None] = {k: None for k in _LATCH_KEYS}
```

---

### **2. Page 1 Extraction**

**User Prompt (Page 1):**
```
PAGE 1 of 10.
No previous-page context.
Extract all complete MCQs from this page per the system instructions.
```

**Gemini Response:**
```json
{
  "questions": [
    {
      "board_name": "Dhaka Board",
      "exam_year": "2023",
      "question_number": "1",
      "question_text": "...",
      ...
    },
    {
      "board_name": "Dhaka Board",  // Model repeats metadata
      "exam_year": "2023",
      "question_number": "2",
      ...
    }
  ]
}
```

**After Page 1:**
```python
# Latch metadata from first question that has it
latch_metadata(known, page.questions, _LATCH_KEYS)

# known = {"board_name": "Dhaka Board", "exam_year": "2023"}
```

---

### **3. Page 2+ Extraction**

**User Prompt (Page 2):**
```
PAGE 2 of 10.
PREVIOUS_PAGE_TAIL:
<<<
... (last ~600 chars from page 1)
>>>
LAST_QUESTION_WAS_INCOMPLETE: false

KNOWN BOARD METADATA (copy into every question on THIS page unless a new header is printed):
  board_name: 'Dhaka Board'
  exam_year: '2023'

Apply the page-boundary stitching rules and extract all complete MCQs.
```

**Key Points:**
- ✅ **Known metadata is explicitly passed** in the user prompt
- ✅ Model is instructed to **copy** these values to every question
- ✅ Model can **override** if a new header is printed (rare)

**Gemini Response (Page 2):**
```json
{
  "questions": [
    {
      "board_name": "Dhaka Board",  // Copied from KNOWN METADATA
      "exam_year": "2023",
      "question_number": "11",
      ...
    },
    {
      "board_name": null,  // Model forgot to copy
      "exam_year": "2023",
      "question_number": "12",
      ...
    }
  ]
}
```

**After Page 2:**
```python
# Latch still works (first-write-wins, won't overwrite)
latch_metadata(known, page.questions, _LATCH_KEYS)

# known = {"board_name": "Dhaka Board", "exam_year": "2023"}  # Unchanged
```

---

### **4. Final Backfill**

After all pages are processed, backfill missing metadata:

```python
backfill_metadata(all_questions, known, _LATCH_KEYS)
```

**Before Backfill:**
```json
[
  {"board_name": "Dhaka Board", "exam_year": "2023", "question_number": "1"},
  {"board_name": "Dhaka Board", "exam_year": "2023", "question_number": "2"},
  {"board_name": "Dhaka Board", "exam_year": "2023", "question_number": "11"},
  {"board_name": null, "exam_year": "2023", "question_number": "12"},  // Missing!
  {"board_name": null, "exam_year": null, "question_number": "13"}     // Missing!
]
```

**After Backfill:**
```json
[
  {"board_name": "Dhaka Board", "exam_year": "2023", "question_number": "1"},
  {"board_name": "Dhaka Board", "exam_year": "2023", "question_number": "2"},
  {"board_name": "Dhaka Board", "exam_year": "2023", "question_number": "11"},
  {"board_name": "Dhaka Board", "exam_year": "2023", "question_number": "12"},  // ✅ Fixed
  {"board_name": "Dhaka Board", "exam_year": "2023", "question_number": "13"}   // ✅ Fixed
]
```

---

## Implementation Details

### **Latch Function**

```python
def latch_metadata(
    known: dict[str, Any],
    questions: list[Any],
    keys: tuple[str, ...],
) -> None:
    """Latch and update metadata from questions.
    
    - First write: Sets the initial value
    - Subsequent writes: Updates if a different non-null value is found
    - Null values: Ignored (won't overwrite known values)
    """
    for q in questions:
        for key in keys:
            val = getattr(q, key, None)
            
            if val is None:
                continue
            
            if known.get(key) is None:
                # First write: latch the value
                known[key] = val
            elif val != known[key]:
                # Metadata changed: update and log
                logger.info(
                    f"📋 Metadata transition: {key} changed from "
                    f"{known[key]!r} to {val!r} (multi-exam PDF detected)"
                )
                known[key] = val
```

**Behavior:**
- ✅ **First-write**: Latches initial value from first question that has it
- ✅ **Dynamic update**: Updates when a different value is detected
- ✅ **Null-safe**: Only latches/updates with non-null values
- ✅ **Per-field**: Each field updates independently
- ✅ **Logged**: Metadata transitions are logged for visibility

---

### **Backfill Function**

```python
def backfill_metadata(
    questions: list[Any], known: dict[str, Any], keys: tuple[str, ...]
) -> None:
    """Fill any still-null metadata field on every question from the latched
    `known` dict."""
    for q in questions:
        for key in keys:
            val = known.get(key)
            if val and getattr(q, key, None) is None:  # Only fill if missing
                setattr(q, key, val)
```

**Behavior:**
- ✅ **Only fills missing values**: Doesn't overwrite existing values
- ✅ **Null-safe**: Only fills if `known` has a value
- ✅ **Idempotent**: Safe to call multiple times

---

### **User Prompt Builder**

```python
def build_user_prompt(
    prev_tail: str,
    prev_incomplete: bool,
    page_index: int,
    total_pages: int,
    known_metadata: dict | None = None,
) -> str:
    header = f"PAGE {page_index + 1} of {total_pages}."

    metadata_block = ""
    if known_metadata and any(known_metadata.values()):
        # Build metadata block from known values
        metadata_block = "\n\nKNOWN BOARD METADATA (copy into every question on THIS page unless a new header is printed):\n"
        for key, val in known_metadata.items():
            if val:
                metadata_block += f"  {key}: {val!r}\n"

    # ... rest of prompt
```

**Key Points:**
- ✅ **Explicit instruction**: "copy into every question"
- ✅ **Override allowed**: "unless a new header is printed"
- ✅ **Only passed if available**: `if any(known_metadata.values())`

---

## Metadata by Exam Type

### **HSC Board**

**Latched Fields:**
- `board_name` (e.g., "Dhaka Board", "Rajshahi Board")
- `exam_year` (e.g., "2023")

**Fixed Fields (Single-Subject):**
- `subject` (stamped from upload parameter)
- `subject_paper` (stamped from upload parameter)

**Example:**
```python
# Upload: subjects="physics", subject_paper="1"
# Latched: board_name="Dhaka Board", exam_year="2023"
# Result: Every question has all 4 fields
```

---

### **Admission Test**

**Latched Fields:**
- `university_name` (e.g., "Dhaka University", "DU")
- `exam_session` (e.g., "2023-2024")
- `exam_unit` (e.g., "A", "B", "Ga")

**Inferred Fields:**
- `subject` (model infers from section headers)

**Example:**
```python
# Upload: subjects="physics,chemistry,mathematics"
# Latched: university_name="DU", exam_session="2023-2024", exam_unit="A"
# Inferred: subject varies per question
```

---

## Edge Cases

### **1. Metadata Changes Mid-PDF**

**Scenario:** PDF contains questions from multiple boards/years

**Behavior:**
- ✅ **Detects changes**: When Gemini extracts a different value
- ✅ **Updates dynamically**: `known` dict is updated to new value
- ✅ **Propagates forward**: Subsequent pages use the new value
- ✅ **Backfills correctly**: Questions without metadata get filled with appropriate value

**Example:**
```
Page 1-2: Dhaka Board 2023
  → known = {"board_name": "Dhaka Board", "exam_year": "2023"}
  → Q1-Q10 labeled "Dhaka Board 2023"

Page 3: Rajshahi Board 2023 (new board starts mid-page)
  → Gemini extracts: Q11-Q15 have "Dhaka Board", Q16-Q20 have "Rajshahi Board"
  → Latch detects change: "Dhaka Board" → "Rajshahi Board"
  → known = {"board_name": "Rajshahi Board", "exam_year": "2023"}
  → Q11-Q15 keep "Dhaka Board" (already set by Gemini)
  → Q16-Q20 keep "Rajshahi Board" (already set by Gemini)

Page 4-5: (no header visible)
  → known = {"board_name": "Rajshahi Board", "exam_year": "2023"}
  → Q21-Q30 have null board_name (no header to extract)
  → Backfill fills with "Rajshahi Board 2023" ✅

Result: Questions correctly labeled with their respective boards
```

**Key Points:**
- ✅ **Handles mid-page transitions**: Gemini can detect different metadata on same page
- ✅ **Handles continuation**: Questions without headers get filled from context
- ✅ **No manual splitting needed**: Multi-exam PDFs work automatically

---

### **2. Metadata Missing from First Page**

**Scenario:** First page has no header (e.g., instructions page)

**Behavior:**
- ✅ **Latches from first question that has it**: Could be page 2, 3, etc.
- ✅ **Backfill still works**: All questions get the value

**Example:**
```
Page 1: No header, no questions
Page 2: "Dhaka Board 2023" header, questions 1-10

Result: Latches from page 2, backfills to all questions
```

---

### **3. Model Forgets Metadata**

**Scenario:** Model doesn't extract metadata from some questions

**Behavior:**
- ✅ **Backfill fixes it**: Missing values filled at the end
- ✅ **No data loss**: All questions have consistent metadata

**Example:**
```
Page 1: Q1 has board_name="Dhaka Board"
Page 2: Q11 has board_name=null  // Model forgot

After backfill: Q11 has board_name="Dhaka Board"
```

---

### **4. Conflicting Metadata**

**Scenario:** Different questions have different metadata values

**Behavior:**
- ✅ **Respects Gemini's extraction**: If Gemini returns a value, it's kept
- ✅ **Updates context**: `known` dict updates to latest value
- ✅ **Backfills with latest**: Null values filled with current `known` value

**Example:**
```
Q1: board_name="Dhaka Board"
  → known = {"board_name": "Dhaka Board"}

Q5: board_name="Rajshahi Board"  // Different!
  → Latch detects change, updates: known = {"board_name": "Rajshahi Board"}
  → Q5 keeps "Rajshahi Board" (Gemini's value)

Q10: board_name=null  // No header visible
  → Backfill fills with "Rajshahi Board" (current known value)

Result: 
  - Q1-Q4: "Dhaka Board" (as extracted)
  - Q5-Q9: "Rajshahi Board" (as extracted)
  - Q10+: "Rajshahi Board" (backfilled from latest known)
```

**Key Point:** The system trusts Gemini's extractions and uses them to update context for subsequent questions.

---

## Benefits of This Approach

### **1. Robustness**
- ✅ **Handles model inconsistency**: Backfill fixes missing values
- ✅ **Handles missing headers**: Latches from any page
- ✅ **Handles multi-page PDFs**: Propagates across all pages

### **2. Efficiency**
- ✅ **Reduces prompt size**: Don't need to repeat full instructions
- ✅ **Reduces model load**: Model doesn't need to infer every time
- ✅ **Faster extraction**: Less processing per page

### **3. Consistency**
- ✅ **Guaranteed consistency**: All questions have same metadata
- ✅ **No drift**: First value is authoritative
- ✅ **Predictable**: Same behavior every time

---

## Comparison with Alternatives

### **Alternative 1: Extract from Filename**

**Approach:** Parse metadata from filename (e.g., `Dhaka_Board_2023_Physics.pdf`)

**Pros:**
- ✅ Guaranteed consistency
- ✅ No model errors

**Cons:**
- ❌ Requires strict naming convention
- ❌ Doesn't work for user uploads
- ❌ Can't handle variations

**Verdict:** ❌ Not flexible enough

---

### **Alternative 2: Extract from Every Page**

**Approach:** Model extracts metadata from every page independently

**Pros:**
- ✅ Can handle mid-PDF changes

**Cons:**
- ❌ Inconsistent results (model errors)
- ❌ Slower (more processing)
- ❌ Larger prompts

**Verdict:** ❌ Too unreliable

---

### **Alternative 3: User Input**

**Approach:** User provides metadata as upload parameters

**Pros:**
- ✅ Guaranteed accuracy
- ✅ No model errors

**Cons:**
- ❌ Extra user burden
- ❌ Prone to user errors
- ❌ Doesn't scale

**Verdict:** ⚠️ Could be optional enhancement

---

### **Current Approach: Latch & Backfill** ✅

**Pros:**
- ✅ Automatic (no user input)
- ✅ Robust (handles model errors)
- ✅ Consistent (first-write-wins)
- ✅ Efficient (minimal processing)
- ✅ Flexible (works with any PDF)

**Cons:**
- ⚠️ Can't handle mid-PDF changes (rare)
- ⚠️ First value must be correct

**Verdict:** ✅ **Best balance of automation and reliability**

---

## Future Enhancements

### **1. User Override**

Allow users to provide metadata as optional parameters:

```python
POST /extract?board_name=Dhaka+Board&exam_year=2023
```

**Benefits:**
- ✅ Guaranteed accuracy
- ✅ Handles edge cases
- ✅ Backward compatible (optional)

---

### **2. Metadata Validation**

Validate extracted metadata against known values:

```python
VALID_BOARDS = ["Dhaka Board", "Rajshahi Board", ...]
VALID_YEARS = ["2020", "2021", "2022", "2023", "2024"]

if board_name not in VALID_BOARDS:
    logger.warning(f"Unknown board: {board_name}")
```

**Benefits:**
- ✅ Catch model errors
- ✅ Suggest corrections
- ✅ Improve data quality

---

### **3. Confidence Scores**

Track model confidence for metadata extraction:

```python
{
  "board_name": "Dhaka Board",
  "board_name_confidence": 0.95
}
```

**Benefits:**
- ✅ Flag low-confidence extractions
- ✅ Prioritize for review
- ✅ Improve over time

---

## Summary

**Current Metadata Strategy:**

1. **Latch** metadata from first page that has it
2. **Propagate** via user prompt to subsequent pages
3. **Backfill** missing values at the end

**Key Features:**
- ✅ Automatic (no user input required)
- ✅ Robust (handles model inconsistency)
- ✅ Consistent (first-write-wins)
- ✅ Efficient (minimal processing)

**Metadata Fields:**
- **HSC**: `board_name`, `exam_year` (+ fixed `subject`, `subject_paper`)
- **Admission**: `university_name`, `exam_session`, `exam_unit` (+ inferred `subject`)

**Result:** All questions in a PDF have consistent, accurate metadata even if the model doesn't extract it from every page.

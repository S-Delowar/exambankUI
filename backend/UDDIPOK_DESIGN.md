# Normalized Uddipok Design

## Overview

Uddipoks (উদ্দীপক - stimulus passages) are now stored in a **separate normalized table** that both HSC MCQ and Written questions reference. This eliminates duplication and provides a clean relational design.

**⚠️ IMPORTANT: Uddipoks are HSC-only!**
- ✅ HSC MCQ questions can have uddipoks (optional)
- ✅ HSC Written questions always have uddipoks (required)
- ❌ Admission MCQ questions do NOT have uddipoks
- ❌ Admission Written questions do NOT have uddipoks

Uddipoks are a feature specific to HSC board exams, not admission tests.

---

## Database Schema

### **Uddipoks Table**

```sql
CREATE TABLE uddipoks (
    id UUID PRIMARY KEY,
    paper_id UUID NOT NULL REFERENCES exam_papers(id) ON DELETE CASCADE,
    text TEXT NOT NULL,
    has_image BOOLEAN NOT NULL DEFAULT false,
    images JSONB,
    sequence_number INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_uddipoks_paper_id ON uddipoks(paper_id);
CREATE INDEX idx_uddipoks_has_image ON uddipoks(has_image);
```

**Fields:**
- `id`: Primary key (UUID)
- `paper_id`: Foreign key to exam_papers (CASCADE delete)
- `text`: Full uddipok text with `[IMAGE_N]` tokens
- `has_image`: True if text contains image tokens
- `images`: JSONB array of image metadata
- `sequence_number`: Order of appearance in the paper (1, 2, 3, ...)
- `created_at`: Timestamp

---

### **Question Tables**

Both MCQ and Written questions reference uddipoks:

```sql
-- HSC MCQ Questions
ALTER TABLE hsc_mcq_questions 
ADD COLUMN uddipok_id UUID REFERENCES uddipoks(id) ON DELETE SET NULL;

CREATE INDEX idx_hsc_mcq_questions_uddipok_id ON hsc_mcq_questions(uddipok_id);

-- HSC Written Questions  
ALTER TABLE hsc_written_questions
DROP COLUMN uddipak_text,
DROP COLUMN uddipak_has_image,
ADD COLUMN uddipok_id UUID NOT NULL REFERENCES uddipoks(id) ON DELETE CASCADE;

CREATE INDEX idx_hsc_written_questions_uddipok_id ON hsc_written_questions(uddipok_id);
```

**Key Differences:**
- **MCQ**: `uddipok_id` is **nullable** (not all MCQs have uddipoks), `SET NULL` on delete
- **Written**: `uddipok_id` is **NOT NULL** (all written questions have uddipoks), `CASCADE` on delete

---

## Extraction Flow

### **1. Extraction Schema (Temporary)**

During extraction, Gemini returns uddipoks with temporary IDs:

```python
# backend/app/schemas/uddipok.py
class Uddipok(BaseModel):
    uddipok_id: str  # Temporary ID like "UDDIPOK_1", "UDDIPOK_2"
    text: str
    has_image: bool
    images: list[QuestionImage]

# backend/app/schemas/hsc_mcq.py
class HscMcqPageExtraction(BaseModel):
    uddipoks: list[Uddipok] = []
    questions: list[HscMcqQuestion] = []
    ...

class HscMcqQuestion(BaseModel):
    uddipok_id: Optional[str] = None  # References temporary ID
    ...
```

---

### **2. Gemini Extraction Example**

**PDF Page:**
```
উদ্দীপক: A plant cell undergoes photosynthesis...

3. Based on the uddipok, what is the primary product?
   (A) Glucose
   (B) Oxygen
   (C) Water
   (D) CO2

4. According to the passage, which organelle is involved?
   (A) Mitochondria
   (B) Chloroplast
   (C) Nucleus
   (D) Ribosome
```

**Gemini Response:**
```json
{
  "uddipoks": [
    {
      "uddipok_id": "UDDIPOK_1",
      "text": "A plant cell undergoes photosynthesis...",
      "has_image": false,
      "images": []
    }
  ],
  "questions": [
    {
      "uddipok_id": "UDDIPOK_1",
      "question_number": "3",
      "question_text": "Based on the uddipok, what is the primary product?",
      "options": [...]
    },
    {
      "uddipok_id": "UDDIPOK_1",
      "question_number": "4",
      "question_text": "According to the passage, which organelle is involved?",
      "options": [...]
    }
  ]
}
```

---

### **3. Database Persistence**

The extraction pipeline maps temporary IDs to database IDs:

```python
async def save_extraction(
    session: AsyncSession,
    paper_id: UUID,
    extraction: HscMcqPdfExtraction,
) -> None:
    # Step 1: Collect unique uddipoks across all pages
    seen_uddipok_ids = set()
    all_uddipoks = []
    
    for page in extraction.pages:
        for uddipok in page.uddipoks:
            if uddipok.uddipok_id not in seen_uddipok_ids:
                seen_uddipok_ids.add(uddipok.uddipok_id)
                all_uddipoks.append(uddipok)
    
    # Step 2: Insert uddipoks and build ID mapping
    uddipok_map: dict[str, UUID] = {}  # temp_id -> db_id
    
    for sequence, uddipok_schema in enumerate(all_uddipoks, start=1):
        db_uddipok = Uddipok(
            paper_id=paper_id,
            text=uddipok_schema.text,
            has_image=uddipok_schema.has_image,
            images=uddipok_schema.images,
            sequence_number=sequence,
        )
        session.add(db_uddipok)
        await session.flush()  # Get the database ID
        
        uddipok_map[uddipok_schema.uddipok_id] = db_uddipok.id
    
    # Step 3: Insert questions with mapped uddipok_id
    for question_schema in extraction.questions:
        db_question = HscMcqQuestion(
            paper_id=paper_id,
            uddipok_id=uddipok_map.get(question_schema.uddipok_id),  # Map temp -> db ID
            question_number=question_schema.question_number,
            question_text=question_schema.question_text,
            ...
        )
        session.add(db_question)
    
    await session.commit()
```

**Key Steps:**
1. **Collect unique uddipoks** from all pages (deduplicate by temp ID)
2. **Insert uddipoks** into database, build mapping `temp_id -> db_id`
3. **Insert questions** with mapped `uddipok_id`

---

## Benefits

### **1. No Duplication**
✅ Each uddipok stored once, even if shared by multiple questions  
✅ Reduces storage size  
✅ Single source of truth  

### **2. Normalized Design**
✅ Proper relational structure  
✅ Easy to update uddipok (affects all questions)  
✅ Clean separation of concerns  

### **3. Reusable**
✅ Same table for MCQ and Written questions  
✅ Consistent schema across question types  
✅ Easy to add more question types later  

### **4. Efficient Queries**
✅ Join when needed: `SELECT * FROM questions JOIN uddipoks ON ...`  
✅ Index on `uddipok_id` for fast lookups  
✅ Can query all questions for an uddipok  

---

## Query Examples

### **Get Question with Uddipok**

```python
# Using SQLAlchemy relationship
question = session.query(HscMcqQuestion).options(
    joinedload(HscMcqQuestion.uddipok)
).filter_by(id=question_id).first()

print(question.uddipok.text)  # Access uddipok via relationship
```

### **Get All Questions for an Uddipok**

```python
uddipok = session.query(Uddipok).filter_by(id=uddipok_id).first()
questions = session.query(HscMcqQuestion).filter_by(uddipok_id=uddipok_id).all()

print(f"Uddipok: {uddipok.text}")
print(f"Questions: {len(questions)}")
```

### **Get All Uddipoks for a Paper**

```python
uddipoks = session.query(Uddipok).filter_by(
    paper_id=paper_id
).order_by(Uddipok.sequence_number).all()

for uddipok in uddipoks:
    print(f"{uddipok.sequence_number}. {uddipok.text[:50]}...")
```

---

## Prompt Instructions

### **HSC MCQ Prompt**

```
UDDIPOKS (উদ্দীপক)
Some questions are preceded by an UDDIPOK — a stimulus passage, scenario, or 
context paragraph. When you encounter an uddipok:
1. Extract it into the `uddipoks` array with a unique ID like "UDDIPOK_1", "UDDIPOK_2"
2. Set `uddipok_id` on each question that references this uddipok
3. If multiple questions share the same uddipok, use the SAME uddipok_id
4. Apply MATH & CHEMISTRY formatting rules to uddipok text
5. If the uddipok contains a figure/diagram, insert [IMAGE_N] token

FIELDS PER UDDIPOK
- uddipok_id: unique identifier like "UDDIPOK_1", "UDDIPOK_2"
- text: full uddipok text with [IMAGE_N] tokens
- has_image: true if text contains [IMAGE_N] tokens, else false
- images: image metadata

FIELDS PER QUESTION
- uddipok_id: reference to uddipok ID if this question has one, else null
- ...
```

### **HSC Written Prompt**

```
UDDIPOKS
Extract each uddipok into the `uddipoks` array with a unique ID like "UDDIPOK_1", 
"UDDIPOK_2", etc. Questions reference their uddipok via `uddipok_id`.

FIELDS PER UDDIPOK
- uddipok_id: unique identifier like "UDDIPOK_1", "UDDIPOK_2"
- text: full uddipok text with [IMAGE_N] tokens
- has_image: true if text contains [IMAGE_N] tokens, else false
- images: image metadata

FIELDS PER QUESTION
- uddipok_id: reference to uddipok ID (e.g., "UDDIPOK_1"). Every written question has an uddipok.
- ...
```

---

## Migration Path

### **Phase 1: Schema Changes** ✅
1. Create `uddipoks` table
2. Add `uddipok_id` to `hsc_mcq_questions` (nullable)
3. Add `uddipok_id` to `hsc_written_questions` (NOT NULL)
4. Drop `uddipak_text` and `uddipak_has_image` from `hsc_written_questions`

### **Phase 2: Data Migration** (If Existing Data)
1. Extract existing `uddipak_text` from `hsc_written_questions`
2. Create `Uddipok` records
3. Update `uddipok_id` references
4. Verify data integrity

### **Phase 3: Code Updates** ✅
1. Update extraction schemas
2. Update database models
3. Update prompts
4. Update persistence logic

---

## Edge Cases

### **1. Shared Uddipok (Multiple Questions)**

**Scenario:** Questions 3 and 4 share the same uddipok

**Extraction:**
```json
{
  "uddipoks": [
    {"uddipok_id": "UDDIPOK_1", "text": "..."}
  ],
  "questions": [
    {"uddipok_id": "UDDIPOK_1", "question_number": "3", ...},
    {"uddipok_id": "UDDIPOK_1", "question_number": "4", ...}
  ]
}
```

**Database:**
- 1 uddipok record
- 2 question records, both referencing the same `uddipok_id`

---

### **2. Uddipok Spans Multiple Pages**

**Scenario:** Uddipok starts on page 1, questions on page 2

**Extraction:**
```json
// Page 1
{
  "uddipoks": [{"uddipok_id": "UDDIPOK_1", "text": "..."}],
  "questions": [],
  "tail_text": "...",
  "last_question_incomplete": true
}

// Page 2
{
  "uddipoks": [],  // Already extracted on page 1
  "questions": [
    {"uddipok_id": "UDDIPOK_1", "question_number": "3", ...}
  ]
}
```

**Handling:**
- Deduplicate uddipoks by `uddipok_id` across pages
- Questions reference the same uddipok regardless of page

---

### **3. MCQ Without Uddipok**

**Scenario:** Regular MCQ with no stimulus passage

**Extraction:**
```json
{
  "uddipoks": [],
  "questions": [
    {"uddipok_id": null, "question_number": "1", ...}
  ]
}
```

**Database:**
- Question has `uddipok_id = NULL`

---

### **4. Written Question Always Has Uddipok**

**Scenario:** All HSC written questions have uddipoks by definition

**Extraction:**
```json
{
  "uddipoks": [{"uddipok_id": "UDDIPOK_1", "text": "..."}],
  "questions": [
    {"uddipok_id": "UDDIPOK_1", "question_number": "1", ...}
  ]
}
```

**Database:**
- `uddipok_id` is NOT NULL (enforced by schema)

---

## Comparison: Before vs After

### **Before (Duplication)**

```python
# HSC Written Question
class HscWrittenQuestion(Base):
    uddipak_text: Mapped[str]  # Duplicated for each question
    uddipak_has_image: Mapped[bool]
```

**Problems:**
- ❌ Uddipok text duplicated for every question
- ❌ Updating uddipok requires updating all questions
- ❌ Inconsistent if uddipok text differs between questions
- ❌ Larger storage size

---

### **After (Normalized)**

```python
# Uddipok Table
class Uddipok(Base):
    id: Mapped[UUID]
    text: Mapped[str]  # Stored once
    has_image: Mapped[bool]

# HSC Written Question
class HscWrittenQuestion(Base):
    uddipok_id: Mapped[UUID]  # Reference only
```

**Benefits:**
- ✅ Uddipok stored once
- ✅ Update uddipok in one place
- ✅ Guaranteed consistency
- ✅ Smaller storage size

---

## Summary

**Normalized Uddipok Design:**
- ✅ Separate `uddipoks` table
- ✅ Questions reference uddipoks via foreign key
- ✅ No duplication
- ✅ Clean relational design
- ✅ Works for both MCQ and Written questions
- ✅ Efficient queries with joins
- ✅ Easy to maintain and extend

**Status:** ✅ **IMPLEMENTED**

**Files Modified:**
- `backend/app/models/uddipok.py` (NEW)
- `backend/app/schemas/uddipok.py` (NEW)
- `backend/app/models/hsc_mcq.py`
- `backend/app/models/hsc_written.py`
- `backend/app/schemas/hsc_mcq.py`
- `backend/app/schemas/hsc_written.py`
- `backend/app/prompts/hsc_mcq.py`
- `backend/app/prompts/hsc_written.py`

**Next Step:** Database migration to apply schema changes

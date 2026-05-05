# Uddipok Scope Clarification

## ⚠️ IMPORTANT: Uddipoks are HSC-Only

### **What are Uddipoks?**

Uddipoks (উদ্দীপক) are **stimulus passages** or **context paragraphs** that appear in **HSC board examination papers only**. They provide background information for one or more questions.

---

## **Scope of Implementation**

### **✅ HSC Exams (Implemented)**

#### **HSC MCQ Questions**
- **Has uddipoks:** Optional (some MCQs have uddipoks, some don't)
- **Database:** `uddipok_id` column (nullable)
- **Schema:** `uddipok_id: Optional[str]`
- **Prompt:** Includes uddipok extraction instructions

#### **HSC Written Questions**
- **Has uddipoks:** Required (all written questions have uddipoks)
- **Database:** `uddipok_id` column (NOT NULL)
- **Schema:** `uddipok_id: str` (required)
- **Prompt:** Includes uddipok extraction instructions

---

### **❌ Admission Tests (NOT Implemented)**

#### **Admission MCQ Questions**
- **Has uddipoks:** NO
- **Database:** No uddipok_id column
- **Schema:** No uddipok fields
- **Prompt:** No uddipok instructions
- **Status:** ✅ Correctly left unchanged

#### **Admission Written Questions**
- **Has uddipoks:** NO
- **Database:** No uddipok_id column
- **Schema:** No uddipok fields
- **Prompt:** No uddipok instructions
- **Status:** ✅ Correctly left unchanged

---

## **Why This Difference?**

### **HSC Board Exams**
- Follow NCTB syllabus
- Use uddipoks extensively in both MCQ and Written questions
- Uddipoks test comprehension and application skills

### **Admission Tests**
- University-specific formats
- Do NOT use uddipoks
- Questions are standalone or grouped differently

---

## **Database Schema**

```sql
-- Uddipoks table (HSC only)
CREATE TABLE uddipoks (
    id UUID PRIMARY KEY,
    paper_id UUID REFERENCES exam_papers(id),
    text TEXT NOT NULL,
    ...
);

-- HSC MCQ (optional uddipok)
CREATE TABLE hsc_mcq_questions (
    id UUID PRIMARY KEY,
    uddipok_id UUID REFERENCES uddipoks(id) ON DELETE SET NULL,  -- Nullable
    ...
);

-- HSC Written (required uddipok)
CREATE TABLE hsc_written_questions (
    id UUID PRIMARY KEY,
    uddipok_id UUID NOT NULL REFERENCES uddipoks(id) ON DELETE CASCADE,  -- NOT NULL
    ...
);

-- Admission MCQ (no uddipok)
CREATE TABLE admission_mcq_questions (
    id UUID PRIMARY KEY,
    -- No uddipok_id column
    ...
);

-- Admission Written (no uddipok)
CREATE TABLE admission_written_questions (
    id UUID PRIMARY KEY,
    -- No uddipok_id column
    ...
);
```

---

## **Files Modified**

### **HSC Files (Modified)**
- ✅ `backend/app/models/hsc_mcq.py`
- ✅ `backend/app/models/hsc_written.py`
- ✅ `backend/app/schemas/hsc_mcq.py`
- ✅ `backend/app/schemas/hsc_written.py`
- ✅ `backend/app/prompts/hsc_mcq.py`
- ✅ `backend/app/prompts/hsc_written.py`

### **Admission Files (Unchanged)**
- ✅ `backend/app/models/admission_mcq.py` - **NO CHANGES**
- ✅ `backend/app/models/admission_written.py` - **NO CHANGES**
- ✅ `backend/app/schemas/admission_mcq.py` - **NO CHANGES**
- ✅ `backend/app/schemas/admission_written.py` - **NO CHANGES**
- ✅ `backend/app/prompts/admission_mcq.py` - **NO CHANGES**
- ✅ `backend/app/prompts/admission_written.py` - **NO CHANGES**

---

## **Migration Impact**

The migration `0010_normalized_uddipoks.py` only affects:
- ✅ Creates `uddipoks` table
- ✅ Adds `uddipok_id` to `hsc_mcq_questions`
- ✅ Adds `uddipok_id` to `hsc_written_questions`
- ✅ Drops old `uddipak_text` from `hsc_written_questions`

**Does NOT affect:**
- ❌ `admission_mcq_questions` table (unchanged)
- ❌ `admission_written_questions` table (unchanged)

---

## **Summary**

**Uddipoks are HSC-specific:**
- ✅ HSC MCQ: Optional uddipoks
- ✅ HSC Written: Required uddipoks
- ❌ Admission MCQ: No uddipoks
- ❌ Admission Written: No uddipoks

**Implementation is correct:**
- Only HSC models/schemas/prompts were modified
- Admission models/schemas/prompts remain unchanged
- Migration only affects HSC tables

**This is the expected behavior!** ✅

# Prompt Architecture

## Overview

The ExamBank extraction pipeline uses different prompt strategies for different exam types:

- **Admission Tests**: Multi-subject generic prompts (no subject-specific addendums)
- **HSC Board Exams**: Hybrid prompts (base prompt + optional subject-specific addendum)

## Prompt Structure

### Base Prompts

Four base prompts exist, one for each `(exam_type, question_type)` combination:

1. `admission_mcq.py` - Admission test MCQ extraction
2. `admission_written.py` - Admission test written question extraction
3. `hsc_mcq.py` - HSC board MCQ extraction
4. `hsc_written.py` - HSC board creative question extraction

Each base prompt includes:
- Task description and field definitions
- Chapter taxonomy (dynamically filtered by declared subjects)
- Math & chemistry formatting rules (from `shared.py`)
- Image handling instructions (from `shared.py`)
- Page-boundary stitching logic (from `shared.py`)

### Subject-Specific Addendums

Defined in `subject_addendums.py`, these provide targeted guidance for:
- Common diagram types and notation
- Subject-specific terminology (Bangla ↔ English)
- Formatting conventions
- Common extraction pitfalls

Currently available addendums:
- **Physics**: Circuit diagrams, vector notation, graphs, common terms
- **Chemistry**: Chemical formulas (`\ce{}`), reactions, molecular structures
- **Mathematics**: Geometric figures, coordinate systems, matrices, vectors
- **Biology**: Anatomical diagrams, cell structures, scientific names

## When Addendums Are Used

### HSC Board Exams

**Single-subject uploads** (e.g., `subjects="physics"`, `subject_paper="1"`):
- ✅ Subject addendum is **automatically injected**
- The subject is fixed and stamped on every question
- Addendum provides subject-specific extraction guidance

**Multi-subject uploads** (rare, e.g., `subjects="physics,chemistry"`):
- ❌ No addendum is injected
- Model infers subject per question
- Generic prompt handles all subjects equally

### Admission Tests

**All uploads** (single or multi-subject):
- ❌ Addendums are **never used**
- Admission PDFs are inherently multi-subject (mixed questions)
- Model infers subject per question from section headers
- Generic prompt avoids bias toward any specific subject

## Implementation Details

### Prompt Builder Pattern

```python
@lru_cache(maxsize=64)
def build_system_prompt(subjects: tuple[str, ...], subject_paper: str | None) -> str:
    # 1. Build base prompt with dynamic taxonomy
    prompt = _TEMPLATE.format(
        subject_header_block=...,
        taxonomy_block=format_scoped_taxonomy(subjects, subject_paper),
        math_chemistry=MATH_CHEMISTRY_BLOCK,
        image=IMAGE_BLOCK,
        stitching=STITCHING_BLOCK,
        format_block=FORMAT_BLOCK,
    )
    
    # 2. Inject subject addendum for single-subject HSC uploads
    if len(subjects) == 1 and subjects[0] in SUBJECT_ADDENDUMS:
        prompt += "\n\n" + SUBJECT_ADDENDUMS[subjects[0]]
    
    return prompt
```

### Caching Strategy

- `@lru_cache` ensures identical prompts are reused across pages
- Cache key: `(subjects, subject_paper)` tuple
- Single-subject uploads with the same subject/paper share cached prompts
- Addendum injection happens **before** caching, so it's included in the cached prompt

## Adding New Subject Addendums

To add guidance for a new subject:

1. **Edit `subject_addendums.py`**:
   ```python
   ENGLISH_ADDENDUM = """
   ENGLISH-SPECIFIC GUIDANCE:
   - Grammar questions: Preserve sentence structure exactly
   - Comprehension passages: Extract full text verbatim
   - Common terms: ব্যাকরণ (grammar), অনুচ্ছেদ (paragraph)
   """
   
   SUBJECT_ADDENDUMS = {
       "physics": PHYSICS_ADDENDUM,
       "chemistry": CHEMISTRY_ADDENDUM,
       "mathematics": MATHEMATICS_ADDENDUM,
       "biology": BIOLOGY_ADDENDUM,
       "english": ENGLISH_ADDENDUM,  # Add new entry
   }
   ```

2. **Keep addendums focused** (100-200 words):
   - Only include guidance that improves extraction quality
   - Focus on subject-specific notation, diagrams, and terminology
   - Avoid repeating generic instructions from the base prompt

3. **Test thoroughly**:
   - Upload sample PDFs for the new subject
   - Verify addendum improves extraction accuracy
   - Check for no regression on other subjects

## Testing & Validation

### Manual Testing

For each subject with an addendum:

1. Upload a sample HSC PDF (single-subject)
2. Verify the addendum is injected (check logs or prompt output)
3. Validate extraction quality:
   - Subject-specific notation (e.g., `\ce{}` for chemistry)
   - Diagram token placement
   - Chapter classification accuracy
   - Bangla terminology handling

### A/B Testing

Compare extraction quality with and without addendums:

1. Extract 5-10 PDFs per subject using current prompts (baseline)
2. Extract same PDFs with hybrid prompts (with addendums)
3. Measure improvements in:
   - LaTeX formatting accuracy
   - Image token placement
   - Chapter classification
   - Subject-specific notation

## Troubleshooting

### Addendum Not Being Injected

**Symptom**: Subject-specific guidance not appearing in extraction results

**Possible causes**:
1. Upload is multi-subject (`len(subjects) > 1`)
2. Subject key doesn't match dictionary key (check spelling)
3. Exam type is admission test (addendums not used)

**Solution**: Verify upload parameters and check `SUBJECT_ADDENDUMS` dictionary keys

### Extraction Quality Regression

**Symptom**: Extraction quality worse after adding addendum

**Possible causes**:
1. Addendum conflicts with base prompt instructions
2. Addendum is too verbose (confuses the model)
3. Addendum introduces bias for edge cases

**Solution**: 
- Review addendum for conflicts with base prompt
- Simplify addendum (remove redundant guidance)
- Test on diverse sample PDFs

### Cache Issues

**Symptom**: Changes to addendums not reflected in extraction

**Possible causes**:
1. `@lru_cache` is caching old prompt
2. Server not restarted after code changes

**Solution**:
- Restart the backend server
- Clear Python `__pycache__` directories if needed

## Future Enhancements

Potential improvements to the hybrid approach:

1. **Dynamic addendum selection**: Choose addendum based on detected content (e.g., if many circuits detected, inject physics guidance)
2. **Per-paper addendums**: Different guidance for Paper 1 vs Paper 2 of the same subject
3. **Confidence-based injection**: Only inject addendum if model confidence is low
4. **Multi-subject addendums**: Generic guidance for common multi-subject patterns in admission tests

## References

- Base prompts: `admission_mcq.py`, `admission_written.py`, `hsc_mcq.py`, `hsc_written.py`
- Shared blocks: `shared.py` (math/chemistry, images, stitching, format)
- Subject addendums: `subject_addendums.py`
- Prompt dispatcher: `__init__.py` (`get_prompt()` function)

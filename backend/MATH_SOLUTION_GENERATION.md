# Math Admission MCQ Solution Generation

## Overview
This system generates step-by-step solutions for mathematics admission MCQ questions using Google's Gemini AI, with comprehensive LaTeX support for mathematical notation.

## Status
- **Total math questions**: 194
- **Pending**: 187
- **Generated**: 7
- **Answer mismatches**: 0

## Files Created

### 1. `backend/app/solution_worker/prompts.py` (updated)
- Added `MATH_MCQ_JSON_SYSTEM_PROMPT`: Math-specific system prompt with comprehensive LaTeX notation
- Added `math_mcq_user_prompt()`: User prompt helper for math questions

### 2. `backend/generate_all_math.py`
Main script to generate solutions for all pending math questions.

**Usage:**
```bash
cd backend
source .venv/bin/activate
python3 generate_all_math.py
```

**Features:**
- Processes all 187 pending questions
- 2-second delay between requests to avoid rate limits
- Automatic image loading if questions have diagrams
- Saves solutions to database with status tracking
- Comprehensive error logging

**Estimated time**: ~6-7 minutes for all questions

### 3. `backend/verify_math_solutions.py`
Verification script to check progress and quality.

**Usage:**
```bash
cd backend
source .venv/bin/activate
python3 verify_math_solutions.py
```

**Output:**
- Solution status counts (pending/generated)
- Number of answer mismatches
- Sample solutions with previews

### 4. `backend/test_math_generation.py`
Test script for small batch testing (5 questions).

**Usage:**
```bash
cd backend
source .venv/bin/activate
python3 test_math_generation.py
```

## Math Prompt Features

### Comprehensive LaTeX Support
- **Basic**: Fractions, roots, exponents
- **Trigonometry**: sin, cos, tan, sec, csc, cot
- **Calculus**: integrals, derivatives, limits, summations
- **Algebra**: matrices, binomials, cases
- **Sets & Logic**: set operations, quantifiers, implications
- **Greek letters**: α, β, θ, π, λ, etc.

### Language Support
- Automatically matches question language (Bangla/English)
- Proper handling of Bangla text outside math delimiters
- Never puts Bangla words inside LaTeX math mode

### Solution Quality
- 3-8 step explanations
- Shows formulas, substitutions, and final answers
- Verifies book answers independently
- Notes discrepancies when found

## Example Output

**Question (Bangla):**
```
প্রদত্ত সমীকরণ x² - 5x + 6 = 0 এর মূলদ্বয়ের যোগফল কত?
```

**Generated Solution:**
```json
{
  "solution": "প্রদত্ত সমীকরণ $x^2 - 5x + 6 = 0$ কে উৎপাদকে বিশ্লেষণ করলে পাই $(x-2)(x-3) = 0$। সুতরাং $x = 2$ অথবা $x = 3$। মূলদ্বয়ের যোগফল $2 + 3 = 5$।",
  "label": "খ"
}
```

## Running Full Generation

To generate solutions for all 187 pending math questions:

```bash
cd backend
source .venv/bin/activate

# Run the generator
python3 generate_all_math.py

# Monitor progress (in another terminal)
python3 verify_math_solutions.py
```

## Error Handling

The system handles:
- **API rate limits**: 2-second delays between requests
- **Temporary unavailability**: Logs errors and continues
- **Missing images**: Gracefully handles questions with/without diagrams
- **JSON parsing**: Validates Gemini responses

## Next Steps

After generating all math solutions, you can:

1. **Verify quality**: Run `verify_math_solutions.py` to check results
2. **Review mismatches**: Investigate any questions where Gemini's answer differs from the book
3. **Test in app**: Verify LaTeX rendering in the frontend
4. **Generate other subjects**: Adapt for chemistry and biology if needed

## Notes

- The system reuses the existing `SolutionGenerator` and `get_paper_stem` from physics
- Solutions are stored in `gemini_solution` and `gemini_correct_answer` fields
- Status tracking prevents duplicate generation
- All LaTeX is KaTeX-compatible for frontend rendering

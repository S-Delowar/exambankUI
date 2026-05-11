# Mixed-Exam PDF Handling

## Overview

The extraction pipeline **now supports** PDFs containing multiple exams (different boards, years, universities, etc.) through **dynamic metadata tracking**. The system detects metadata changes and updates context automatically.

---

## How It Works

### **Dynamic Metadata Updates**

The pipeline uses a "latch, update, and backfill" strategy:

1. **Initial latch**: First metadata value is captured
2. **Change detection**: When Gemini extracts a different value, the system detects it
3. **Context update**: The `known` metadata dict is updated to the new value
4. **Forward propagation**: Subsequent pages receive the updated metadata as context
5. **Smart backfill**: Questions without metadata are filled with the appropriate value

---

## Example Scenarios

### **Scenario 1: Multiple Boards in One PDF**

```
┌─────────────────────────────────┐
│ Page 1-3: Dhaka Board 2023      │
│ Q1-Q30                          │
└─────────────────────────────────┘
┌─────────────────────────────────┐
│ Page 4: Rajshahi Board 2023     │
│ Q1-Q10                          │
└─────────────────────────────────┘
┌─────────────────────────────────┐
│ Page 5-6: (continuation)        │
│ Q11-Q30                         │
└─────────────────────────────────┘
```

**What Happens:**

**Pages 1-3:**
- Gemini extracts: `board_name="Dhaka Board"`
- System latches: `known = {"board_name": "Dhaka Board"}`
- Q1-Q30 labeled: "Dhaka Board 2023" ✅

**Page 4:**
- Gemini extracts: `board_name="Rajshahi Board"` (different!)
- System detects change and updates: `known = {"board_name": "Rajshahi Board"}`
- Logs: `📋 Metadata transition: board_name changed from 'Dhaka Board' to 'Rajshahi Board'`
- Q1-Q10 labeled: "Rajshahi Board 2023" ✅

**Pages 5-6:**
- No header visible (continuation)
- System passes: `known_metadata = {"board_name": "Rajshahi Board"}`
- Gemini uses context to label questions
- Q11-Q30 labeled: "Rajshahi Board 2023" ✅

**Result:** All questions correctly labeled with their respective boards! 🎉

---

### **Scenario 2: Board Change Mid-Page**

```
┌─────────────────────────────────┐
│ Page 5                          │
│                                 │
│ Q15. [Dhaka Board 2023]         │
│ Q16. [Dhaka Board 2023]         │
│                                 │
│ ════════════════════════════════│
│ Rajshahi Board 2023             │
│ Q1. [Rajshahi Board 2023]       │
│ Q2. [Rajshahi Board 2023]       │
└─────────────────────────────────┘
```

**What Happens:**

- Gemini extracts all questions from the page
- Q15-Q16: `board_name="Dhaka Board"`
- Q1-Q2: `board_name="Rajshahi Board"`
- System detects change when processing Q1
- Updates: `known = {"board_name": "Rajshahi Board"}`
- All questions keep their extracted values ✅
- Next page uses "Rajshahi Board" as context ✅

**Result:** Mid-page transitions handled correctly! 🎉

---

### **Scenario 3: Multiple Years**

```
┌─────────────────────────────────┐
│ Page 1-5: Dhaka Board 2023      │
└─────────────────────────────────┘
┌─────────────────────────────────┐
│ Page 6-10: Dhaka Board 2024     │
└─────────────────────────────────┘
```

**What Happens:**

**Pages 1-5:**
- `known = {"board_name": "Dhaka Board", "exam_year": "2023"}`
- All questions: "Dhaka Board 2023" ✅

**Page 6:**
- Gemini extracts: `exam_year="2024"` (different!)
- System updates: `known = {"board_name": "Dhaka Board", "exam_year": "2024"}`
- Logs: `📋 Metadata transition: exam_year changed from '2023' to '2024'`

**Pages 7-10:**
- Context: "Dhaka Board 2024"
- All questions: "Dhaka Board 2024" ✅

**Result:** Year transitions handled automatically! 🎉

---

## Technical Implementation

### **Updated `latch_metadata` Function**

```python
def latch_metadata(
    known: dict[str, Any],
    questions: list[Any],
    keys: tuple[str, ...],
) -> None:
    """Latch and update metadata from questions."""
    for q in questions:
        for key in keys:
            val = getattr(q, key, None)
            
            if val is None:
                continue  # Skip null values
            
            if known.get(key) is None:
                # First write: latch the value
                known[key] = val
            elif val != known[key]:
                # Metadata changed: update and log
                logger.info(
                    f"📋 Metadata transition: {key} changed from "
                    f"{known[key]!r} to {val!r} (multi-exam PDF detected)"
                )
                known[key] = val  # ✅ Update to new value
```

**Key Changes:**
- ✅ **Updates `known` dict** when change detected (previously only logged)
- ✅ **Logs transitions** for visibility
- ✅ **Preserves Gemini's extractions** (doesn't overwrite)

---

### **Smart Backfill (Unchanged)**

```python
def backfill_metadata(
    questions: list[Any], 
    known: dict[str, Any], 
    keys: tuple[str, ...]
) -> None:
    """Fill only null metadata fields."""
    for q in questions:
        for key in keys:
            val = known.get(key)
            if val and getattr(q, key, None) is None:
                setattr(q, key, val)  # Only fills null values
```

**Behavior:**
- ✅ **Only fills null values** (doesn't overwrite Gemini's extractions)
- ✅ **Uses latest `known` value** (updated by latch_metadata)
- ✅ **Preserves transitions** (questions keep their extracted metadata)

---

## Benefits

### **1. Automatic Handling**
- ✅ No manual PDF splitting required
- ✅ No special upload parameters needed
- ✅ Works with any PDF structure

### **2. Accurate Labeling**
- ✅ Questions labeled with correct board/year
- ✅ Transitions detected automatically
- ✅ Context maintained across pages

### **3. Robust Extraction**
- ✅ Handles mid-page transitions
- ✅ Handles continuation pages (no header)
- ✅ Handles multiple transitions in one PDF

### **4. Visibility**
- ✅ Transitions logged for monitoring
- ✅ Easy to debug extraction issues
- ✅ Clear audit trail

---

## Logging

When metadata changes are detected, the system logs:

```
INFO: 📋 Metadata transition: board_name changed from 'Dhaka Board' to 'Rajshahi Board' (multi-exam PDF detected)
INFO: 📋 Metadata transition: exam_year changed from '2023' to '2024' (multi-exam PDF detected)
```

**Use these logs to:**
- ✅ Verify multi-exam PDFs are handled correctly
- ✅ Monitor extraction quality
- ✅ Debug unexpected metadata values

---

## Edge Cases

### **1. Gemini Misses a Transition**

**Scenario:** New board starts but Gemini doesn't extract it

```
Page 5: Rajshahi Board 2023 (header visible)
Q1: board_name=null  // Gemini missed it
Q2: board_name=null
```

**Result:**
- Q1-Q2 backfilled with previous board (Dhaka Board)
- ⚠️ Incorrect labeling

**Mitigation:**
- Prompt engineering: Emphasize header detection
- Subject addendums: Provide board-specific guidance
- Manual review: Check logs for missing transitions

---

### **2. False Positive Transition**

**Scenario:** Gemini extracts wrong board name

```
Page 3: Dhaka Board 2023 (correct)
Q10: board_name="Rajshahi Board"  // Gemini error
Q11: board_name="Dhaka Board"     // Correct again
```

**Result:**
- System detects two transitions: Dhaka → Rajshahi → Dhaka
- Q10 labeled "Rajshahi Board" (incorrect)
- Q11+ labeled "Dhaka Board" (correct)

**Mitigation:**
- Prompt engineering: Emphasize accuracy
- Validation: Check for unlikely transitions (same page)
- Manual review: Check logs for frequent transitions

---

### **3. Gradual Transition**

**Scenario:** Questions gradually switch boards

```
Q1-Q5: board_name="Dhaka Board"
Q6: board_name=null
Q7: board_name=null
Q8: board_name="Rajshahi Board"
Q9-Q10: board_name="Rajshahi Board"
```

**Result:**
- Q1-Q5: "Dhaka Board" ✅
- Q6-Q7: Backfilled with "Dhaka Board" (last known) ⚠️
- Q8-Q10: "Rajshahi Board" ✅
- System updates at Q8: Dhaka → Rajshahi

**Mitigation:**
- If Q6-Q7 should be Rajshahi, they'll be mislabeled
- Prompt engineering: Encourage header detection
- Consider: Look-ahead logic (check next questions before backfilling)

---

## Best Practices

### **For Users**

1. **Upload any PDF structure** - Multi-exam PDFs work automatically
2. **Check extraction logs** - Look for metadata transition messages
3. **Review results** - Verify transitions happened at correct points
4. **Report issues** - If transitions missed or incorrect

### **For Developers**

1. **Monitor transition logs** - Track frequency and patterns
2. **Validate transitions** - Check for unlikely patterns (too frequent, same page)
3. **Improve prompts** - Emphasize header detection and accuracy
4. **Consider validation** - Add board/year validation against known values

---

## Comparison: Before vs After

### **Before (First-Write-Wins)**

```
Page 1-3: Dhaka Board 2023
Page 4-6: Rajshahi Board 2023

Result:
- All questions labeled "Dhaka Board 2023" ❌
- Warning logged but no action taken
- Manual PDF splitting required
```

### **After (Dynamic Updates)**

```
Page 1-3: Dhaka Board 2023
Page 4-6: Rajshahi Board 2023

Result:
- Pages 1-3: "Dhaka Board 2023" ✅
- Pages 4-6: "Rajshahi Board 2023" ✅
- Transition logged and handled automatically
- No manual splitting needed
```

---

## Summary

**Multi-exam PDFs are now fully supported!** 🎉

**Key Features:**
- ✅ Automatic metadata change detection
- ✅ Dynamic context updates
- ✅ Smart backfilling (preserves Gemini's extractions)
- ✅ Handles mid-page transitions
- ✅ Handles continuation pages
- ✅ Logged transitions for visibility

**No Action Required:**
- Upload PDFs as-is (no splitting needed)
- System handles transitions automatically
- Check logs to verify correct handling

**Result:** Accurate, automatic extraction from any PDF structure! 🚀

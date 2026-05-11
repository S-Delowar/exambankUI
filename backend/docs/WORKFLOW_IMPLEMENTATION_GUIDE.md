# Extraction Workflow Implementation Guide

## ✅ Completed (Tasks 1-2)

1. ✅ ExtractionWorkflow model created (`backend/app/models/workflow.py`)
2. ✅ Migration created (`backend/alembic/versions/0011_extraction_workflows.py`)

---

## 🔄 Next: Run Migration

```bash
cd backend
docker-compose exec api alembic upgrade head
```

---

## 📋 Remaining Implementation

### **Backend (Tasks 3-11)**

#### Task 3: PDF Cleaning Service
**File:** `backend/app/services/pdf_cleaner.py`

```python
import cv2
import numpy as np
import fitz  # PyMuPDF

def clean_pdf(pdf_bytes: bytes) -> bytes:
    """Clean PDF using bilateral filter + adaptive threshold."""
    doc = fitz.open(stream=pdf_bytes, filetype="pdf")
    output_doc = fitz.open()
    
    for page in doc:
        pix = page.get_pixmap(matrix=fitz.Matrix(300/72, 300/72))
        img = np.frombuffer(pix.samples, dtype=np.uint8).reshape(pix.height, pix.width, 3)
        
        # Clean
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        denoised = cv2.bilateralFilter(gray, 9, 75, 75)
        clean = cv2.adaptiveThreshold(denoised, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY, 21, 15)
        
        # Convert back to PDF
        clean_rgb = cv2.cvtColor(clean, cv2.COLOR_GRAY2RGB)
        img_pdf = fitz.open("png", cv2.imencode('.png', clean_rgb)[1].tobytes())
        new_page = output_doc.new_page(width=page.rect.width, height=page.rect.height)
        new_page.insert_image(page.rect, stream=img_pdf[0].get_pixmap().tobytes())
    
    return output_doc.tobytes()
```

#### Task 4-10: Workflow Router
**File:** `backend/app/routers/admin_workflow.py`

```python
from fastapi import APIRouter, Depends, File, HTTPException, UploadFile, Query
from sqlalchemy.ext.asyncio import AsyncSession
from pathlib import Path
import uuid

from ..deps import require_admin, get_current_user, get_db
from ..models import ExtractionWorkflow, User
from ..services.pdf_cleaner import clean_pdf
from ..services.image_cropper import crop_pdf_images
from ..extractors import run_extraction

router = APIRouter(prefix="/admin/workflow", tags=["admin-workflow"], dependencies=[Depends(require_admin)])

WORKFLOW_STORAGE = Path("./data/workflows")
WORKFLOW_STORAGE.mkdir(parents=True, exist_ok=True)

@router.post("/upload")
async def upload_pdf(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Step 1: Upload original PDF."""
    if not file.filename.endswith('.pdf'):
        raise HTTPException(400, "Only PDF files accepted")
    
    workflow_id = uuid.uuid4()
    workflow_dir = WORKFLOW_STORAGE / str(workflow_id)
    workflow_dir.mkdir()
    
    # Save original PDF
    original_path = workflow_dir / "original.pdf"
    pdf_bytes = await file.read()
    original_path.write_bytes(pdf_bytes)
    
    # Create workflow
    workflow = ExtractionWorkflow(
        id=workflow_id,
        created_by=current_user.id,
        original_filename=file.filename,
        original_pdf_path=str(original_path),
        selected_pdf_path=str(original_path),
        current_step="upload"
    )
    db.add(workflow)
    await db.commit()
    
    return {
        "workflow_id": str(workflow_id),
        "original_pdf_url": f"/admin/workflow/{workflow_id}/original.pdf",
        "next_step": "clean"
    }

@router.post("/{workflow_id}/clean")
async def clean_pdf_endpoint(
    workflow_id: uuid.UUID,
    db: AsyncSession = Depends(get_db)
):
    """Step 2: Clean PDF."""
    workflow = await db.get(ExtractionWorkflow, workflow_id)
    if not workflow:
        raise HTTPException(404, "Workflow not found")
    
    # Read original PDF
    pdf_bytes = Path(workflow.original_pdf_path).read_bytes()
    
    # Clean
    cleaned_bytes = clean_pdf(pdf_bytes)
    
    # Save cleaned PDF
    cleaned_path = Path(workflow.original_pdf_path).parent / "cleaned.pdf"
    cleaned_path.write_bytes(cleaned_bytes)
    
    workflow.cleaned_pdf_path = str(cleaned_path)
    workflow.current_step = "clean"
    await db.commit()
    
    return {
        "workflow_id": str(workflow_id),
        "original_pdf_url": f"/admin/workflow/{workflow_id}/original.pdf",
        "cleaned_pdf_url": f"/admin/workflow/{workflow_id}/cleaned.pdf",
        "next_step": "accept_or_reject"
    }

@router.post("/{workflow_id}/accept-clean")
async def accept_cleaned(workflow_id: uuid.UUID, db: AsyncSession = Depends(get_db)):
    """Step 3a: Use cleaned PDF."""
    workflow = await db.get(ExtractionWorkflow, workflow_id)
    workflow.selected_pdf_path = workflow.cleaned_pdf_path
    workflow.cleaning_applied = True
    workflow.current_step = "crop"
    await db.commit()
    return {"next_step": "crop"}

@router.post("/{workflow_id}/use-original")
async def use_original(workflow_id: uuid.UUID, db: AsyncSession = Depends(get_db)):
    """Step 3b: Use original PDF."""
    workflow = await db.get(ExtractionWorkflow, workflow_id)
    workflow.selected_pdf_path = workflow.original_pdf_path
    workflow.current_step = "crop"
    await db.commit()
    return {"next_step": "crop"}

@router.post("/{workflow_id}/crop")
async def crop_images_endpoint(
    workflow_id: uuid.UUID,
    file: UploadFile = File(...),
    db: AsyncSession = Depends(get_db)
):
    """Step 4: Crop images."""
    workflow = await db.get(ExtractionWorkflow, workflow_id)
    pdf_bytes = await file.read()
    
    result = crop_pdf_images(pdf_bytes, str(workflow_id), "./data/cropped_images")
    
    workflow.crop_folder = result["crop_folder"]
    workflow.cropping_applied = True
    workflow.current_step = "extract"
    await db.commit()
    
    return {"total_figures": result["total_figures"], "next_step": "extract"}

@router.post("/{workflow_id}/extract")
async def extract_questions_endpoint(
    workflow_id: uuid.UUID,
    exam_type: str = Query(...),
    question_type: str = Query(...),
    subjects: str = Query(...),
    subject_paper: str | None = Query(None),
    db: AsyncSession = Depends(get_db)
):
    """Step 5: Extract questions."""
    workflow = await db.get(ExtractionWorkflow, workflow_id)
    pdf_bytes = Path(workflow.selected_pdf_path).read_bytes()
    
    job = await run_extraction(
        job_id=str(uuid.uuid4()),
        pdf_bytes=pdf_bytes,
        filename=workflow.original_filename,
        exam_type=exam_type,
        question_type=question_type,
        subjects=tuple(subjects.split(',')),
        subject_paper=subject_paper
    )
    
    workflow.extraction_job_id = job.job_id
    workflow.current_step = "extract"
    await db.commit()
    
    return {"job_id": job.job_id}

@router.get("/{workflow_id}")
async def get_workflow(workflow_id: uuid.UUID, db: AsyncSession = Depends(get_db)):
    """Get workflow status."""
    workflow = await db.get(ExtractionWorkflow, workflow_id)
    if not workflow:
        raise HTTPException(404)
    
    return {
        "workflow_id": str(workflow.id),
        "current_step": workflow.current_step,
        "status": workflow.status,
        "cleaning_applied": workflow.cleaning_applied,
        "cropping_applied": workflow.cropping_applied,
        "extraction_job_id": workflow.extraction_job_id
    }

@router.get("/{workflow_id}/{pdf_type}.pdf")
async def serve_pdf(workflow_id: uuid.UUID, pdf_type: str, db: AsyncSession = Depends(get_db)):
    """Serve original or cleaned PDF."""
    from fastapi.responses import FileResponse
    
    workflow = await db.get(ExtractionWorkflow, workflow_id)
    if pdf_type == "original":
        path = workflow.original_pdf_path
    elif pdf_type == "cleaned":
        path = workflow.cleaned_pdf_path
    else:
        raise HTTPException(404)
    
    return FileResponse(path, media_type="application/pdf")
```

#### Task 11: Register Router
**File:** `backend/app/main.py`

```python
from .routers import admin_workflow

app.include_router(admin_workflow.router)
```

---

### **Frontend (Tasks 12-21)**

See `WORKFLOW_FRONTEND_GUIDE.md` for complete React implementation.

---

## 🚀 Quick Start

1. Run migration
2. Implement backend services (Tasks 3-11)
3. Implement frontend (Tasks 12-21)
4. Test end-to-end

**Estimated time:** 2-3 days for full implementation

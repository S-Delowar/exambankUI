"""Admin workflow router for PDF processing pipeline."""

import uuid
from pathlib import Path
from typing import Literal

from fastapi import APIRouter, Depends, File, HTTPException, Query, UploadFile
from fastapi.responses import FileResponse
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ...config import get_settings
from ...auth.deps import get_current_user, require_admin
from ...database import get_session
from ...extractors import run_extraction
from ...models import ExtractionWorkflow, User
from ...image_processing.manual_cropper import crop_pdf_images
from ...pdf.cleaning import clean_pdf

router = APIRouter(
    prefix="/admin/workflow",
    tags=["admin-workflow"]
)

# Workflow storage directory
WORKFLOW_STORAGE = Path("./data/workflows")
WORKFLOW_STORAGE.mkdir(parents=True, exist_ok=True)


@router.post("/upload")
async def upload_pdf(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_session),
    _: User = Depends(require_admin)
):
    """Step 1: Upload original PDF and create workflow."""
    settings = get_settings()
    
    # Validate file
    if not file.filename or not file.filename.lower().endswith('.pdf'):
        raise HTTPException(400, "Only PDF files accepted")
    
    # Read PDF
    pdf_bytes = await file.read()
    size_mb = len(pdf_bytes) / (1024 * 1024)
    if size_mb > settings.max_upload_mb:
        raise HTTPException(400, f"File too large ({size_mb:.1f} MB > {settings.max_upload_mb} MB)")
    
    # Create workflow directory
    workflow_id = uuid.uuid4()
    workflow_dir = WORKFLOW_STORAGE / str(workflow_id)
    workflow_dir.mkdir(parents=True)
    
    # Save original PDF
    original_path = workflow_dir / "original.pdf"
    original_path.write_bytes(pdf_bytes)
    
    # Create workflow record
    workflow = ExtractionWorkflow(
        id=workflow_id,
        created_by=current_user.id,
        original_filename=file.filename,
        original_pdf_path=str(original_path),
        selected_pdf_path=str(original_path),
        current_step="upload",
        status="in_progress"
    )
    db.add(workflow)
    await db.commit()
    
    return {
        "workflow_id": str(workflow_id),
        "original_pdf_url": f"/admin/workflow/{workflow_id}/original.pdf",
        "filename": file.filename,
        "size_mb": round(size_mb, 2),
        "next_step": "clean"
    }


@router.post("/{workflow_id}/clean")
async def clean_pdf_endpoint(
    workflow_id: uuid.UUID,
    db: AsyncSession = Depends(get_session),
    _: User = Depends(require_admin)
):
    """Step 2: Clean PDF and return both versions."""
    workflow = await db.get(ExtractionWorkflow, workflow_id)
    if not workflow:
        raise HTTPException(404, "Workflow not found")
    
    try:
        # Read original PDF
        original_path = Path(workflow.original_pdf_path)
        pdf_bytes = original_path.read_bytes()
        
        # Clean PDF
        cleaned_bytes = clean_pdf(pdf_bytes)
        
        # Save cleaned PDF with original filename + _cleaned suffix
        original_name = original_path.stem  # filename without extension
        cleaned_path = original_path.parent / f"{original_name}_cleaned.pdf"
        cleaned_path.write_bytes(cleaned_bytes)
        
        # Update workflow
        workflow.cleaned_pdf_path = str(cleaned_path)
        workflow.current_step = "clean"
        await db.commit()
        
        return {
            "workflow_id": str(workflow_id),
            "original_pdf_url": f"/admin/workflow/{workflow_id}/original.pdf",
            "cleaned_pdf_url": f"/admin/workflow/{workflow_id}/cleaned.pdf",
            "next_step": "accept_or_reject"
        }
    except Exception as e:
        workflow.status = "failed"
        workflow.error_message = f"Cleaning failed: {str(e)}"
        await db.commit()
        raise HTTPException(500, f"PDF cleaning failed: {str(e)}")


@router.post("/{workflow_id}/accept-clean")
async def accept_cleaned(
    workflow_id: uuid.UUID,
    db: AsyncSession = Depends(get_session),
    _: User = Depends(require_admin)
):
    """Step 3a: Accept cleaned PDF for extraction."""
    workflow = await db.get(ExtractionWorkflow, workflow_id)
    if not workflow:
        raise HTTPException(404, "Workflow not found")
    
    if not workflow.cleaned_pdf_path:
        raise HTTPException(400, "No cleaned PDF available")
    
    workflow.selected_pdf_path = workflow.cleaned_pdf_path
    workflow.cleaning_applied = True
    workflow.current_step = "crop"
    await db.commit()
    
    return {
        "workflow_id": str(workflow_id),
        "selected_pdf": "cleaned",
        "next_step": "crop"
    }


@router.post("/{workflow_id}/use-original")
async def use_original(
    workflow_id: uuid.UUID,
    db: AsyncSession = Depends(get_session),
    _: User = Depends(require_admin)
):
    """Step 3b: Use original PDF for extraction."""
    workflow = await db.get(ExtractionWorkflow, workflow_id)
    if not workflow:
        raise HTTPException(404, "Workflow not found")
    
    workflow.selected_pdf_path = workflow.original_pdf_path
    workflow.cleaning_applied = False
    workflow.current_step = "crop"
    await db.commit()
    
    return {
        "workflow_id": str(workflow_id),
        "selected_pdf": "original",
        "next_step": "crop"
    }


@router.post("/{workflow_id}/skip-clean")
async def skip_cleaning(
    workflow_id: uuid.UUID,
    db: AsyncSession = Depends(get_session),
    _: User = Depends(require_admin)
):
    """Skip cleaning step and go directly to crop."""
    return await use_original(workflow_id, db)


@router.post("/{workflow_id}/crop")
async def crop_images_endpoint(
    workflow_id: uuid.UUID,
    file: UploadFile = File(None),
    paper_name: str = Query(..., description="Name for cropped images folder"),
    db: AsyncSession = Depends(get_session),
    _: User = Depends(require_admin)
):
    """Step 4: Crop images from annotated PDF (uses selected PDF if no file uploaded)."""
    settings = get_settings()
    workflow = await db.get(ExtractionWorkflow, workflow_id)
    if not workflow:
        raise HTTPException(404, "Workflow not found")
    
    try:
        # Always crop from the original PDF — it has annotation metadata
        # (SQUARE, INK, POLYGON) intact. Each cropped image is denoised
        # before saving so the output is clean.
        if file and file.filename:
            if not file.filename.lower().endswith('.pdf'):
                raise HTTPException(400, "Only PDF files accepted")
            pdf_bytes = await file.read()
        else:
            pdf_path = Path(workflow.original_pdf_path)
            if not pdf_path.exists():
                raise HTTPException(404, "Original PDF not found")
            pdf_bytes = pdf_path.read_bytes()
        
        # Crop images
        result = crop_pdf_images(
            pdf_bytes=pdf_bytes,
            paper_name=paper_name,
            output_root=settings.manual_crops_path
        )
        
        # Update workflow
        workflow.crop_folder = result["crop_folder"]
        workflow.cropping_applied = True
        workflow.current_step = "extract"
        await db.commit()
        
        return {
            "workflow_id": str(workflow_id),
            "crop_folder": result["crop_folder"],
            "pages_with_figures": result["pages_with_figures"],
            "total_figures": result["total_figures"],
            "pages_processed": result["pages_processed"],
            "next_step": "extract"
        }
    except Exception as e:
        workflow.status = "failed"
        workflow.error_message = f"Cropping failed: {str(e)}"
        await db.commit()
        raise HTTPException(500, f"Image cropping failed: {str(e)}")


@router.post("/{workflow_id}/skip-crop")
async def skip_cropping(
    workflow_id: uuid.UUID,
    db: AsyncSession = Depends(get_session),
    _: User = Depends(require_admin)
):
    """Skip cropping step and go directly to extract."""
    workflow = await db.get(ExtractionWorkflow, workflow_id)
    if not workflow:
        raise HTTPException(404, "Workflow not found")
    
    workflow.cropping_applied = False
    workflow.current_step = "extract"
    await db.commit()
    
    return {
        "workflow_id": str(workflow_id),
        "next_step": "extract"
    }


@router.post("/{workflow_id}/extract")
async def extract_questions_endpoint(
    workflow_id: uuid.UUID,
    exam_type: Literal["admission_test", "hsc_board"] = Query(...),
    question_type: Literal["mcq", "written"] = Query(...),
    subjects: str = Query(..., description="Comma-separated subject keys"),
    subject_paper: Literal["1", "2"] | None = Query(None),
    db: AsyncSession = Depends(get_session),
    _: User = Depends(require_admin)
):
    """Step 5: Extract questions from selected PDF."""
    workflow = await db.get(ExtractionWorkflow, workflow_id)
    if not workflow:
        raise HTTPException(404, "Workflow not found")

    try:
        # Read selected PDF
        pdf_bytes = Path(workflow.selected_pdf_path).read_bytes()
        
        # Parse subjects
        subjects_tuple = tuple(s.strip() for s in subjects.split(',') if s.strip())
        
        # Start extraction
        from ...jobs import job_store
        job = await job_store.create()
        
        # Run extraction in background
        import asyncio
        asyncio.create_task(
            run_extraction(
                job_id=job.job_id,
                pdf_bytes=pdf_bytes,
                filename=workflow.original_filename,
                exam_type=exam_type,
                question_type=question_type,
                subjects=subjects_tuple,
                subject_paper=subject_paper,
                workflow_id=str(workflow_id),
            )
        )
        
        # Update workflow
        workflow.extraction_job_id = job.job_id
        workflow.current_step = "extract"
        await db.commit()
        
        return {
            "workflow_id": str(workflow_id),
            "job_id": job.job_id,
            "status_url": f"/jobs/{job.job_id}",
            "next_step": "complete"
        }
    except Exception as e:
        workflow.status = "failed"
        workflow.error_message = f"Extraction failed: {str(e)}"
        await db.commit()
        raise HTTPException(500, f"Question extraction failed: {str(e)}")


@router.get("/{workflow_id}")
async def get_workflow_status(
    workflow_id: uuid.UUID,
    db: AsyncSession = Depends(get_session),
    _: User = Depends(require_admin)
):
    """Get current workflow state and progress."""
    workflow = await db.get(ExtractionWorkflow, workflow_id)
    if not workflow:
        raise HTTPException(404, "Workflow not found")
    
    return {
        "workflow_id": str(workflow.id),
        "current_step": workflow.current_step,
        "status": workflow.status,
        "original_filename": workflow.original_filename,
        "original_pdf_url": f"/admin/workflow/{workflow.id}/original.pdf",
        "cleaned_pdf_url": f"/admin/workflow/{workflow.id}/cleaned.pdf" if workflow.cleaned_pdf_path else None,
        "selected_pdf": "cleaned" if workflow.cleaning_applied else "original",
        "cleaning_applied": workflow.cleaning_applied,
        "cropping_applied": workflow.cropping_applied,
        "crop_folder": workflow.crop_folder,
        "extraction_job_id": workflow.extraction_job_id,
        "paper_id": str(workflow.paper_id) if workflow.paper_id else None,
        "error_message": workflow.error_message,
        "created_at": workflow.created_at.isoformat(),
        "updated_at": workflow.updated_at.isoformat()
    }


@router.get("/{workflow_id}/{pdf_type}.pdf")
async def serve_pdf(
    workflow_id: uuid.UUID,
    pdf_type: Literal["original", "cleaned"],
    db: AsyncSession = Depends(get_session)
):
    """Serve original or cleaned PDF. No auth required since called from iframe."""
    workflow = await db.get(ExtractionWorkflow, workflow_id)
    if not workflow:
        raise HTTPException(404, "Workflow not found")
    
    if pdf_type == "original":
        pdf_path = workflow.original_pdf_path
    elif pdf_type == "cleaned":
        if not workflow.cleaned_pdf_path:
            raise HTTPException(404, "Cleaned PDF not available")
        pdf_path = workflow.cleaned_pdf_path
    else:
        raise HTTPException(400, "Invalid PDF type")
    
    if not Path(pdf_path).exists():
        raise HTTPException(404, "PDF file not found")
    
    return FileResponse(
        pdf_path,
        media_type="application/pdf",
        headers={"Content-Disposition": "inline"}
    )


@router.get("")
async def list_workflows(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_session),
    limit: int = Query(20, le=100),
    offset: int = Query(0, ge=0)
):
    """List workflows for current user."""
    result = await db.execute(
        select(ExtractionWorkflow)
        .where(ExtractionWorkflow.created_by == current_user.id)
        .order_by(ExtractionWorkflow.created_at.desc())
        .limit(limit)
        .offset(offset)
    )
    workflows = result.scalars().all()
    
    return {
        "workflows": [
            {
                "workflow_id": str(w.id),
                "filename": w.original_filename,
                "current_step": w.current_step,
                "status": w.status,
                "created_at": w.created_at.isoformat()
            }
            for w in workflows
        ],
        "total": len(workflows),
        "limit": limit,
        "offset": offset
    }

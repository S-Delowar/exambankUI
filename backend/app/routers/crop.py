"""Image cropping API.

Endpoint for detecting and cropping figures from PDFs based on rectangle
annotations. Cropped images are saved to the manual crops directory and
can be linked during extraction.
"""

import re
from pathlib import Path

from fastapi import APIRouter, Depends, File, HTTPException, Query, UploadFile
from pydantic import BaseModel

from ..config import get_settings
from ..deps import require_admin
from ..services.image_cropper import crop_pdf_images

router = APIRouter(tags=["crop"], dependencies=[Depends(require_admin)])


class CropResult(BaseModel):
    """Response model for crop-images endpoint."""
    paper_name: str
    crop_folder: str
    pages_with_figures: int
    total_figures: int
    pages_processed: int
    message: str


def _sanitize_paper_name(name: str) -> str:
    """Sanitize paper name for use as folder name."""
    # Replace spaces and special chars with underscores
    sanitized = re.sub(r"[^\w\-.]", "_", name)
    # Remove leading/trailing underscores
    sanitized = sanitized.strip("_")
    # Collapse multiple underscores
    sanitized = re.sub(r"_+", "_", sanitized)
    return sanitized or "unnamed_paper"


@router.post("/crop-images", response_model=CropResult)
async def crop_images(
    file: UploadFile = File(...),
    paper_name: str = Query(
        ...,
        description=(
            "Name for the cropped images folder (e.g., 'Physics_2023_Dhaka_Board_Paper_1'). "
            "This should match the paper stem that will be used during extraction for automatic linking."
        ),
        min_length=1,
        max_length=200,
    ),
) -> CropResult:
    """
    Detect and crop figures from a PDF based on rectangle annotations.
    
    **Workflow:**
    1. Upload a PDF with red rectangle annotations around figures
    2. System detects rectangles and crops each figure
    3. Crops are saved to: `manual_crops_path/{paper_name}/page_N/imageM.png`
    4. During extraction, images are automatically linked if paper names match
    
    **Requirements:**
    - PDF must have rectangle annotations (red, green, or magenta)
    - Annotations should be drawn around figures/diagrams/graphs
    - Use consistent `paper_name` for extraction linking
    
    **Returns:**
    - Summary of cropped images
    - Location of crop folder
    - Count of figures per page
    """
    settings = get_settings()
    
    # Validate file type
    if not file.filename or not file.filename.lower().endswith(".pdf"):
        raise HTTPException(status_code=400, detail="Only .pdf files are accepted.")
    
    # Sanitize paper name
    paper_name_clean = _sanitize_paper_name(paper_name)
    if not paper_name_clean:
        raise HTTPException(
            status_code=400,
            detail="paper_name must contain at least one alphanumeric character."
        )
    
    # Read PDF
    try:
        pdf_bytes = await file.read()
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Could not read file: {e}")
    
    # Validate PDF size
    size_mb = len(pdf_bytes) / (1024 * 1024)
    if size_mb > settings.max_upload_mb:
        raise HTTPException(
            status_code=400,
            detail=f"File too large ({size_mb:.1f} MB > {settings.max_upload_mb} MB)."
        )
    
    # Crop images
    try:
        result = crop_pdf_images(
            pdf_bytes=pdf_bytes,
            paper_name=paper_name_clean,
            output_root=settings.manual_crops_path,
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Image cropping failed: {e}"
        )
    
    # Build response message
    if result["total_figures"] == 0:
        message = (
            f"No figures found in {file.filename}. "
            "Ensure the PDF has rectangle annotations around figures."
        )
    else:
        message = (
            f"Successfully cropped {result['total_figures']} figure(s) "
            f"from {result['pages_with_figures']} page(s). "
            f"Saved to: {result['crop_folder']}"
        )
    
    return CropResult(
        paper_name=result["paper_name"],
        crop_folder=result["crop_folder"],
        pages_with_figures=result["pages_with_figures"],
        total_figures=result["total_figures"],
        pages_processed=result["pages_processed"],
        message=message,
    )

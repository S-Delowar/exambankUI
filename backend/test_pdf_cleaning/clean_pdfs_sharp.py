#!/usr/bin/env python3
"""
Enhanced PDF cleaning with sharper text output.

Improvements over clean_pdfs.py:
- Morphological closing to fill text gaps
- Sharpening filter for crisper edges
- Optimized threshold parameters

Usage:
    python clean_pdfs_sharp.py
"""

import sys
from pathlib import Path

import cv2
import fitz  # PyMuPDF
import numpy as np


def clean_image_sharp(img_array: np.ndarray) -> np.ndarray:
    """
    Clean image with enhanced sharpness.
    
    Args:
        img_array: Input image as numpy array
    
    Returns:
        Cleaned binary image with sharp text
    """
    # Convert to grayscale
    if len(img_array.shape) == 3:
        gray = cv2.cvtColor(img_array, cv2.COLOR_BGR2GRAY)
    else:
        gray = img_array
    
    # Step 1: Sharpen the image BEFORE denoising
    # This enhances text edges
    kernel_sharpen = np.array([
        [-1, -1, -1],
        [-1,  9, -1],
        [-1, -1, -1]
    ])
    sharpened = cv2.filter2D(gray, -1, kernel_sharpen)
    
    # Step 2: Bilateral filter (less aggressive to preserve sharpness)
    denoised = cv2.bilateralFilter(sharpened, 7, 50, 50)
    
    # Step 3: Adaptive thresholding with optimized parameters
    binary = cv2.adaptiveThreshold(
        denoised,
        255,
        cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
        cv2.THRESH_BINARY,
        15,  # Smaller block = sharper edges
        10   # Lower C = keeps more detail
    )
    
    # Step 4: Morphological closing to fill small gaps in text
    # This makes text more solid and readable
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (2, 2))
    closed = cv2.morphologyEx(binary, cv2.MORPH_CLOSE, kernel)
    
    return closed


def clean_pdf(input_path: Path, output_path: Path, dpi: int = 300) -> None:
    """
    Clean a PDF with enhanced sharpness.
    
    Args:
        input_path: Path to input PDF
        output_path: Path to output PDF
        dpi: Resolution for rendering
    """
    print(f"Processing: {input_path.name}")
    
    doc = fitz.open(input_path)
    output_doc = fitz.open()
    
    for page_num in range(len(doc)):
        print(f"  Page {page_num + 1}/{len(doc)}...", end=" ")
        
        # Render page
        page = doc[page_num]
        mat = fitz.Matrix(dpi / 72, dpi / 72)
        pix = page.get_pixmap(matrix=mat, alpha=False)
        
        # Convert to numpy
        img = np.frombuffer(pix.samples, dtype=np.uint8).reshape(
            pix.height, pix.width, 3
        )
        
        # Clean with sharp filter
        clean_img = clean_image_sharp(img)
        
        # Convert to RGB
        clean_img_rgb = cv2.cvtColor(clean_img, cv2.COLOR_GRAY2RGB)
        
        # Create new page
        img_pdf = fitz.open("png", cv2.imencode('.png', clean_img_rgb)[1].tobytes())
        rect = page.rect
        new_page = output_doc.new_page(width=rect.width, height=rect.height)
        new_page.insert_image(rect, stream=img_pdf[0].get_pixmap().tobytes())
        img_pdf.close()
        
        print("✓")
    
    output_doc.save(output_path)
    output_doc.close()
    doc.close()
    
    print(f"  Saved: {output_path.name}\n")


def main():
    script_dir = Path(__file__).parent
    input_dir = script_dir / "input"
    output_dir = script_dir / "output"
    
    input_dir.mkdir(exist_ok=True)
    output_dir.mkdir(exist_ok=True)
    
    pdf_files = sorted(input_dir.glob("*.pdf"))
    
    if not pdf_files:
        print(f"No PDF files found in {input_dir}")
        return
    
    print(f"Found {len(pdf_files)} PDF(s) to process\n")
    print("Using SHARP mode for enhanced text clarity\n")
    
    for pdf_path in pdf_files:
        output_path = output_dir / f"sharp_{pdf_path.name}"
        
        try:
            clean_pdf(pdf_path, output_path)
        except Exception as e:
            print(f"  ✗ Error: {e}\n")
            continue
    
    print(f"Done! Sharp PDFs saved to: {output_dir.absolute()}")


if __name__ == "__main__":
    main()

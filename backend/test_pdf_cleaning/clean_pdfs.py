#!/usr/bin/env python3
"""
Clean PDFs by removing background noise using adaptive thresholding.

Usage:
    python clean_pdfs.py

Input:  backend/test_pdf_cleaning/input/*.pdf
Output: backend/test_pdf_cleaning/output/*.pdf
"""

import sys
from pathlib import Path

import cv2
import fitz  # PyMuPDF
import numpy as np


def clean_image(img_array: np.ndarray) -> np.ndarray:
    """
    Clean a single image using bilateral filter and adaptive thresholding.
    
    Args:
        img_array: Input image as numpy array (BGR or grayscale)
    
    Returns:
        Cleaned binary image
    """
    # Convert to grayscale if needed
    if len(img_array.shape) == 3:
        gray = cv2.cvtColor(img_array, cv2.COLOR_BGR2GRAY)
    else:
        gray = img_array
    
    # Bilateral filter: reduces noise while preserving edges
    denoised = cv2.bilateralFilter(gray, 9, 75, 75)
    
    # Adaptive thresholding: handles varying lighting conditions
    clean_img = cv2.adaptiveThreshold(
        denoised,
        255,
        cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
        cv2.THRESH_BINARY,
        21,  # block_size (must be odd)
        15   # C constant (increase to remove more noise)
    )
    
    return clean_img


def clean_pdf(input_path: Path, output_path: Path, dpi: int = 300) -> None:
    """
    Clean a PDF by processing each page.
    
    Args:
        input_path: Path to input PDF
        output_path: Path to output PDF
        dpi: Resolution for rendering (higher = better quality, slower)
    """
    print(f"Processing: {input_path.name}")
    
    # Open input PDF
    doc = fitz.open(input_path)
    
    # Create new PDF for output
    output_doc = fitz.open()
    
    for page_num in range(len(doc)):
        print(f"  Page {page_num + 1}/{len(doc)}...", end=" ")
        
        # Render page to image
        page = doc[page_num]
        mat = fitz.Matrix(dpi / 72, dpi / 72)
        pix = page.get_pixmap(matrix=mat, alpha=False)
        
        # Convert to numpy array
        img = np.frombuffer(pix.samples, dtype=np.uint8).reshape(
            pix.height, pix.width, 3
        )
        
        # Clean the image
        clean_img = clean_image(img)
        
        # Convert back to RGB for PDF (binary image needs to be 3-channel)
        clean_img_rgb = cv2.cvtColor(clean_img, cv2.COLOR_GRAY2RGB)
        
        # Create new page with cleaned image
        img_pdf = fitz.open("png", cv2.imencode('.png', clean_img_rgb)[1].tobytes())
        rect = page.rect
        new_page = output_doc.new_page(width=rect.width, height=rect.height)
        new_page.insert_image(rect, stream=img_pdf[0].get_pixmap().tobytes())
        img_pdf.close()
        
        print("✓")
    
    # Save output PDF
    output_doc.save(output_path)
    output_doc.close()
    doc.close()
    
    print(f"  Saved: {output_path.name}\n")


def main():
    # Paths
    script_dir = Path(__file__).parent
    input_dir = script_dir / "input"
    output_dir = script_dir / "output"
    
    # Ensure directories exist
    input_dir.mkdir(exist_ok=True)
    output_dir.mkdir(exist_ok=True)
    
    # Find all PDFs in input directory
    pdf_files = sorted(input_dir.glob("*.pdf"))
    
    if not pdf_files:
        print(f"No PDF files found in {input_dir}")
        print(f"Place PDF files in: {input_dir.absolute()}")
        return
    
    print(f"Found {len(pdf_files)} PDF(s) to process\n")
    
    # Process each PDF
    for pdf_path in pdf_files:
        output_path = output_dir / f"cleaned_{pdf_path.name}"
        
        try:
            clean_pdf(pdf_path, output_path)
        except Exception as e:
            print(f"  ✗ Error: {e}\n")
            continue
    
    print(f"Done! Cleaned PDFs saved to: {output_dir.absolute()}")


if __name__ == "__main__":
    main()

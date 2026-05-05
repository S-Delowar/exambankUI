#!/usr/bin/env python3
"""
Change background color to white only - no other processing.

Preserves original text quality, only cleans background.

Usage:
    python clean_pdfs_bg_only.py
"""

import sys
from pathlib import Path

import cv2
import fitz  # PyMuPDF
import numpy as np


def clean_background_only(img_array: np.ndarray) -> np.ndarray:
    """
    Change background to white, preserve text as-is.
    """
    # Convert to grayscale
    if len(img_array.shape) == 3:
        gray = cv2.cvtColor(img_array, cv2.COLOR_BGR2GRAY)
    else:
        gray = img_array
    
    # Simple adaptive threshold - just separate text from background
    binary = cv2.adaptiveThreshold(
        gray,
        255,
        cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
        cv2.THRESH_BINARY,
        21,  # Standard block size
        15   # Standard constant
    )
    
    return binary


def clean_pdf(input_path: Path, output_path: Path, dpi: int = 300) -> None:
    """Clean PDF background only."""
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
        
        # Clean background only
        clean_img = clean_background_only(img)
        
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
    print("Background cleaning only - preserving original text\n")
    
    for pdf_path in pdf_files:
        output_path = output_dir / f"bgclean_{pdf_path.name}"
        
        try:
            clean_pdf(pdf_path, output_path)
        except Exception as e:
            print(f"  ✗ Error: {e}\n")
            continue
    
    print(f"Done! Background-cleaned PDFs saved to: {output_dir.absolute()}")


if __name__ == "__main__":
    main()

"""PDF cleaning service for removing noise and improving text clarity."""

import cv2
import fitz  # PyMuPDF
import numpy as np


def clean_pdf(pdf_bytes: bytes) -> bytes:
    """Clean PDF using bilateral filter + adaptive threshold while preserving red annotations.
    
    Args:
        pdf_bytes: Original PDF as bytes
        
    Returns:
        Cleaned PDF as bytes with red bounding boxes preserved
    """
    doc = fitz.open(stream=pdf_bytes, filetype="pdf")
    output_doc = fitz.open()
    
    for page in doc:
        # Render at 300 DPI
        mat = fitz.Matrix(300 / 72, 300 / 72)
        pix = page.get_pixmap(matrix=mat, alpha=False)
        
        # Convert to numpy array (PyMuPDF gives RGB format)
        img = np.frombuffer(pix.samples, dtype=np.uint8).reshape(
            pix.height, pix.width, 3
        )
        
        # Convert RGB to HSV for better red detection
        hsv = cv2.cvtColor(img, cv2.COLOR_RGB2HSV)
        
        # Red color range in HSV (red wraps around at 0/180)
        # Lower red range (0-10)
        lower_red1 = np.array([0, 100, 100])
        upper_red1 = np.array([10, 255, 255])
        mask1 = cv2.inRange(hsv, lower_red1, upper_red1)
        
        # Upper red range (170-180)
        lower_red2 = np.array([170, 100, 100])
        upper_red2 = np.array([180, 255, 255])
        mask2 = cv2.inRange(hsv, lower_red2, upper_red2)
        
        # Combine masks
        red_mask = cv2.bitwise_or(mask1, mask2)
        
        # Convert to grayscale for cleaning
        gray = cv2.cvtColor(img, cv2.COLOR_RGB2GRAY)
        
        # Denoise with bilateral filter
        denoised = cv2.bilateralFilter(gray, 9, 75, 75)
        
        # Adaptive threshold for binarization
        clean = cv2.adaptiveThreshold(
            denoised,
            255,
            cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
            cv2.THRESH_BINARY,
            21,
            15
        )
        
        # Convert back to RGB
        clean_rgb = cv2.cvtColor(clean, cv2.COLOR_GRAY2RGB)
        
        # Restore red bounding boxes (RGB format: [R, G, B])
        clean_rgb[red_mask > 0] = [255, 0, 0]
        
        # Convert RGB to BGR for cv2.imencode (it expects BGR)
        clean_bgr = cv2.cvtColor(clean_rgb, cv2.COLOR_RGB2BGR)
        
        # Create new page with cleaned image
        img_pdf = fitz.open("png", cv2.imencode('.png', clean_bgr)[1].tobytes())
        rect = page.rect
        new_page = output_doc.new_page(width=rect.width, height=rect.height)
        new_page.insert_image(rect, stream=img_pdf[0].get_pixmap().tobytes())
        img_pdf.close()
    
    # Return as bytes
    cleaned_bytes = output_doc.tobytes()
    output_doc.close()
    doc.close()
    
    return cleaned_bytes

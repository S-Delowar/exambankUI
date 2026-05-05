#!/usr/bin/env python3
"""
Quick test to verify the PDF cleaning setup.
Creates a sample noisy image and cleans it.
"""

import cv2
import numpy as np
from pathlib import Path

def create_test_image():
    """Create a test image with text and noise."""
    # Create white background
    img = np.ones((800, 600), dtype=np.uint8) * 255
    
    # Add some text
    font = cv2.FONT_HERSHEY_SIMPLEX
    cv2.putText(img, 'Test Document', (50, 100), font, 2, 0, 3)
    cv2.putText(img, 'This is a sample text', (50, 200), font, 1, 0, 2)
    cv2.putText(img, 'with background noise', (50, 250), font, 1, 0, 2)
    
    # Add noise (simulate paper texture)
    noise = np.random.normal(0, 25, img.shape).astype(np.uint8)
    noisy_img = cv2.add(img, noise)
    
    # Add some spots (simulate stains)
    for _ in range(50):
        x, y = np.random.randint(0, 600), np.random.randint(0, 800)
        cv2.circle(noisy_img, (x, y), 3, 200, -1)
    
    return noisy_img

def clean_image(img):
    """Clean image using the same method as clean_pdfs.py"""
    denoised = cv2.bilateralFilter(img, 9, 75, 75)
    clean = cv2.adaptiveThreshold(
        denoised, 255,
        cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
        cv2.THRESH_BINARY,
        21, 15
    )
    return clean

def main():
    script_dir = Path(__file__).parent
    
    print("Creating test image with noise...")
    noisy = create_test_image()
    
    print("Cleaning image...")
    clean = clean_image(noisy)
    
    # Save results
    cv2.imwrite(str(script_dir / "test_noisy.png"), noisy)
    cv2.imwrite(str(script_dir / "test_cleaned.png"), clean)
    
    print(f"✓ Test images saved:")
    print(f"  - {script_dir / 'test_noisy.png'}")
    print(f"  - {script_dir / 'test_cleaned.png'}")
    print("\nCompare the images to see the cleaning effect!")

if __name__ == "__main__":
    main()

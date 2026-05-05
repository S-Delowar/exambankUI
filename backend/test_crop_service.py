"""Quick test for image cropping service.

Run: python -m backend.test_crop_service
"""

from pathlib import Path

# Mock test - just verify imports work
try:
    from backend.app.services.image_cropper import crop_pdf_images
    from backend.app.routers.crop import _sanitize_paper_name
    print("✅ Imports successful")
    
    # Test sanitization
    test_cases = [
        ("Physics 2023 Dhaka Board Paper 1", "Physics_2023_Dhaka_Board_Paper_1"),
        ("DU-2023-2024-A-Unit", "DU-2023-2024-A-Unit"),
        ("Test@#$%Paper", "Test_Paper"),
        ("___Multiple___Underscores___", "Multiple_Underscores"),
    ]
    
    for input_name, expected in test_cases:
        result = _sanitize_paper_name(input_name)
        assert result == expected, f"Expected {expected}, got {result}"
        print(f"✅ Sanitize: '{input_name}' → '{result}'")
    
    print("\n✅ All tests passed!")
    print("\nTo test the full API:")
    print("1. Start the server: uvicorn app.main:app --reload")
    print("2. Upload a PDF with annotations:")
    print("   curl -X POST 'http://localhost:8000/crop-images?paper_name=Test_Paper' \\")
    print("     -H 'Authorization: Bearer YOUR_TOKEN' \\")
    print("     -F 'file=@path/to/annotated.pdf'")
    
except ImportError as e:
    print(f"❌ Import error: {e}")
    print("\nInstall missing dependencies:")
    print("  pip install opencv-python pymupdf")
except Exception as e:
    print(f"❌ Test failed: {e}")

#!/usr/bin/env python3
"""
Batch-crop figures from PDFs using the image_cropper service.

Usage:
    python -m backend.scripts.crop_figures_batch <pdf_dir> [output_dir]

Examples:
    # Crop all PDFs in a directory
    python -m backend.scripts.crop_figures_batch ./pdfs

    # Crop with custom output directory
    python -m backend.scripts.crop_figures_batch ./pdfs ./output

    # Crop single PDF
    python -m backend.scripts.crop_figures_batch ./physics.pdf
"""

import sys
from pathlib import Path

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))

from app.services.image_cropper import crop_pdf_images


def process_directory(pdf_dir: Path, output_root: Path) -> None:
    """Process all PDFs in a directory."""
    pdfs = sorted(pdf_dir.glob("*.pdf"))
    if not pdfs:
        print(f"No PDFs found in {pdf_dir}")
        return

    print(f"Found {len(pdfs)} PDF(s) in {pdf_dir}")
    print(f"Output directory: {output_root}\n")

    grand_total = 0
    for pdf_path in pdfs:
        print(f"Processing {pdf_path.name}...", end=" ")
        try:
            with open(pdf_path, "rb") as f:
                pdf_bytes = f.read()

            result = crop_pdf_images(
                pdf_bytes=pdf_bytes,
                paper_name=pdf_path.stem,
                output_root=output_root,
            )

            if result["total_figures"] > 0:
                print(
                    f"✓ {result['total_figures']} figure(s) "
                    f"from {result['pages_with_figures']} page(s)"
                )
                grand_total += result["total_figures"]
            else:
                print("✗ No figures found")

        except Exception as e:
            print(f"✗ Error: {e}")

    print(f"\nDone. {grand_total} figure(s) saved to {output_root}")


def process_single_pdf(pdf_path: Path, output_root: Path) -> None:
    """Process a single PDF."""
    print(f"Processing {pdf_path.name}...")
    print(f"Output directory: {output_root}\n")

    try:
        with open(pdf_path, "rb") as f:
            pdf_bytes = f.read()

        result = crop_pdf_images(
            pdf_bytes=pdf_bytes,
            paper_name=pdf_path.stem,
            output_root=output_root,
        )

        if result["total_figures"] > 0:
            print(
                f"✓ Cropped {result['total_figures']} figure(s) "
                f"from {result['pages_with_figures']} page(s)"
            )
            print(f"✓ Saved to: {result['crop_folder']}")
        else:
            print("✗ No figures found")
            print("  Ensure the PDF has rectangle annotations around figures")

    except Exception as e:
        print(f"✗ Error: {e}")
        sys.exit(1)


def main() -> None:
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    input_path = Path(sys.argv[1])
    if not input_path.exists():
        print(f"Error: {input_path} does not exist")
        sys.exit(1)

    # Determine output directory
    if len(sys.argv) >= 3:
        output_root = Path(sys.argv[2])
    else:
        # Default to backend/data/cropped_images
        backend_dir = Path(__file__).parent.parent
        output_root = backend_dir / "data" / "cropped_images"

    output_root.mkdir(parents=True, exist_ok=True)

    # Process directory or single file
    if input_path.is_dir():
        process_directory(input_path, output_root)
    elif input_path.suffix.lower() == ".pdf":
        process_single_pdf(input_path, output_root)
    else:
        print(f"Error: {input_path} is not a PDF file or directory")
        sys.exit(1)


if __name__ == "__main__":
    main()

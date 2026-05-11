import fitz


class PdfTooLargeError(ValueError):
    pass


def render_pdf_to_images(pdf_bytes: bytes, dpi: int, max_pages: int) -> list[bytes]:
    """Render each page of a PDF to a PNG byte-string. Returns one PNG per page in order."""
    images: list[bytes] = []
    with fitz.open(stream=pdf_bytes, filetype="pdf") as doc:
        if doc.page_count > max_pages:
            raise PdfTooLargeError(
                f"PDF has {doc.page_count} pages; maximum allowed is {max_pages}."
            )
        for page in doc:
            pix = page.get_pixmap(dpi=dpi, alpha=False)
            images.append(pix.tobytes("png"))
    return images

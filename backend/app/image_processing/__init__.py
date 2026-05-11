"""Image processing package: extraction, linking, cropping, diagram localization."""

from .linker import link_questions_to_cropped_images, resolve_crop_folder  # noqa: F401
from .manual_cropper import crop_pdf_images  # noqa: F401

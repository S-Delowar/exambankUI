#!/usr/bin/env python3
"""Upload local images to Cloudinary for production deployment."""
import os
from pathlib import Path
from dotenv import load_dotenv
import cloudinary
import cloudinary.uploader

# Load .env file
load_dotenv()

# Get Cloudinary URL from environment
CLOUDINARY_URL = os.getenv("CLOUDINARY_URL")
if not CLOUDINARY_URL:
    print("❌ Error: CLOUDINARY_URL not found in .env file")
    exit(1)

# Parse and configure Cloudinary
# URL format: cloudinary://api_key:api_secret@cloud_name
import re
match = re.match(r'cloudinary://(\d+):([^@]+)@(.+)', CLOUDINARY_URL)
if not match:
    print("❌ Error: Invalid CLOUDINARY_URL format")
    exit(1)

api_key, api_secret, cloud_name = match.groups()
cloudinary.config(
    cloud_name=cloud_name,
    api_key=api_key,
    api_secret=api_secret,
    secure=True
)

images_dir = Path("data/images")

for img_path in images_dir.rglob("*.png"):
    # Preserve folder structure: data/images/paper_name/image.png -> exambank/paper_name/image
    relative_path = img_path.relative_to(images_dir)
    folder = f"exambank/{relative_path.parent}"
    public_id = relative_path.stem
    
    print(f"Uploading {img_path} to {folder}/{public_id}...")
    result = cloudinary.uploader.upload(
        str(img_path),
        folder=folder,
        public_id=public_id,
        overwrite=True,
    )
    print(f"  ✓ {result['secure_url']}")

print("\n✅ All images uploaded!")
print("Now update your database image URLs to use Cloudinary URLs.")

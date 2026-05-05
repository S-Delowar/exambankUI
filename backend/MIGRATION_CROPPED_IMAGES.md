# Migration Guide: test-cropping → data/cropped_images

## Overview

The cropped images directory has been moved from `test-cropping/cropped_images/` to `backend/data/cropped_images/` to better reflect its role as production data rather than test data.

## Changes

| Old Path | New Path |
|----------|----------|
| `test-cropping/cropped_images/` | `backend/data/cropped_images/` |
| `test-cropping/crop_figures_batch.py` | Replaced by `/crop-images` API |

## Migration Steps

### Option 1: Move Existing Crops (Recommended)

If you have existing cropped images you want to keep:

```bash
# Create new directory
mkdir -p backend/data/cropped_images

# Move existing crops
mv test-cropping/cropped_images/* backend/data/cropped_images/

# Verify
ls backend/data/cropped_images/
```

### Option 2: Start Fresh

If you want to re-crop everything using the new API:

```bash
# Create new directory
mkdir -p backend/data/cropped_images

# Keep test-cropping for reference (optional)
# Or delete it: rm -rf test-cropping
```

## Configuration Updates

The configuration has been automatically updated:

**backend/config.yaml:**
```yaml
# Old
manual_crops_dir: "../test-cropping/cropped_images"

# New
manual_crops_dir: "./data/cropped_images"
```

**backend/app/config.py:**
```python
# Old
manual_crops_dir: str = "../test-cropping/cropped_images"

# New
manual_crops_dir: str = "./data/cropped_images"
```

## Workflow Changes

### Old Workflow (Manual Script)

```bash
# 1. Copy PDF to test-cropping/pdf_files/
cp physics.pdf test-cropping/pdf_files/

# 2. Run manual script
python test-cropping/crop_figures_batch.py

# 3. Check results
ls test-cropping/cropped_images/physics/
```

### New Workflow (API)

```bash
# 1. Upload via API
curl -X POST "http://localhost:8000/crop-images?paper_name=Physics_2023_Paper_1" \
  -H "Authorization: Bearer TOKEN" \
  -F "file=@physics.pdf"

# 2. Check results
ls backend/data/cropped_images/Physics_2023_Paper_1/
```

## Directory Structure

### Before
```
ExamBank/
  backend/
    data/
      images/          # Served images
      results/         # Extraction results
  test-cropping/       # Separate directory
    cropped_images/    # Manual crops
    pdf_files/
    crop_figures_batch.py
```

### After
```
ExamBank/
  backend/
    data/
      images/          # Served images
      results/         # Extraction results
      cropped_images/  # Manual crops (NEW)
  test-cropping/       # Can be deleted or kept for reference
```

## Backward Compatibility

### If You Keep test-cropping

The old `test-cropping/` directory can coexist with the new structure:

1. **Old crops** in `test-cropping/cropped_images/` will still work if you update config:
   ```yaml
   manual_crops_dir: "../test-cropping/cropped_images"
   ```

2. **New crops** via API will go to `backend/data/cropped_images/`

3. **Not recommended** - Better to migrate everything to the new location

### Updating Existing Scripts

If you have scripts that reference the old path:

```python
# Old
CROPS_DIR = Path("test-cropping/cropped_images")

# New
CROPS_DIR = Path("backend/data/cropped_images")
```

## Verification

After migration, verify everything works:

```bash
# 1. Check directory exists
ls backend/data/cropped_images/

# 2. Test API
curl -X POST "http://localhost:8000/crop-images?paper_name=Test" \
  -H "Authorization: Bearer TOKEN" \
  -F "file=@test.pdf"

# 3. Verify crops saved
ls backend/data/cropped_images/Test/

# 4. Test extraction with linking
curl -X POST "http://localhost:8000/extract?exam_type=hsc_board&question_type=mcq&subjects=physics&subject_paper=1" \
  -H "Authorization: Bearer TOKEN" \
  -F "file=@test.pdf"

# 5. Check extraction logs for image linking
# Should see: "linked X manual crop(s) from ..."
```

## Cleanup (Optional)

Once you've verified everything works, you can remove the old directory:

```bash
# Backup first (optional)
tar -czf test-cropping-backup.tar.gz test-cropping/

# Remove old directory
rm -rf test-cropping/
```

## Troubleshooting

### Images Not Linking After Migration

**Symptom:** Extraction succeeds but images marked as `needs_review`

**Solution:**
1. Check config points to new path: `manual_crops_dir: "./data/cropped_images"`
2. Verify crops exist: `ls backend/data/cropped_images/paper_name/`
3. Restart server to reload config

### Permission Errors

**Symptom:** Cannot create `backend/data/cropped_images/`

**Solution:**
```bash
# Ensure data directory exists and is writable
mkdir -p backend/data/cropped_images
chmod 755 backend/data/cropped_images
```

### Old Crops Not Found

**Symptom:** Extraction can't find crops that existed in test-cropping

**Solution:**
1. Move crops to new location (see Option 1 above)
2. Or update config to point to old location temporarily
3. Or re-crop using the new API

## Benefits of New Structure

✅ **Consistent** - All data in `backend/data/`  
✅ **Clear naming** - `cropped_images` vs `test-cropping`  
✅ **Production-ready** - No "test" in production paths  
✅ **API-driven** - No manual script needed  
✅ **Better organized** - Data separate from code  

## Questions?

See `backend/CROP_IMAGES_API.md` for full API documentation.

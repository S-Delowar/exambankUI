#!/bin/bash
# Update all image URLs to Cloudinary

CLOUDINARY_BASE="https://res.cloudinary.com/dtairwxkx/image/upload/exambank"

# List of paper folders
FOLDERS=(
  "Dhaka_University_2015-16_unit_A_mcq"
  "Dhaka_University_2016-17_unit_A_mcq"
  "Dhaka_University_2017-18_unit_A_mcq"
  "Dhaka_University_2018-19_unit_A_mcq"
  "Dhaka_University_2019-20_unit_A_mcq"
  "Dhaka_University_2020-21_unit_A_mcq"
  "Dhaka_University_2021-22_unit_A_mcq"
)

for folder in "${FOLDERS[@]}"; do
  echo "Updating $folder..."
  docker exec exambank-postgres psql -U exambank -d exambank -c "
    UPDATE admission_mcq_questions
    SET images = (
      SELECT jsonb_agg(
        jsonb_set(
          img,
          '{filename}',
          to_jsonb('$CLOUDINARY_BASE/$folder/' || (img->>'filename'))
        )
      )
      FROM jsonb_array_elements(images) AS img
    )
    WHERE images IS NOT NULL
    AND images::text NOT LIKE '%cloudinary%'
    AND images::text LIKE '%' || (SELECT img->>'filename' FROM jsonb_array_elements(images) AS img LIMIT 1) || '%';
  " 2>&1 | grep "UPDATE"
done

echo "✅ All images updated!"

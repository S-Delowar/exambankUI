// Chapter display: Bangla label + 1-based serial number from the syllabus
// (chapter order in `backend/chapters.yaml`). The serial gives users an
// anchor that matches their NCTB textbook table of contents; the Bangla
// label keeps the UI native-language. The English snake_case `key`
// remains the canonical id stored in the DB and exchanged with Gemini.
//
// All helpers tolerate a missing taxonomy or missing label by falling
// back to a prettified version of the English key — adding a new chapter
// to `chapters.yaml` won't crash the UI.

import type { PublicTaxonomy } from "./api";

function prettifyKey(key: string): string {
  return key
    .split("_")
    .map((s) => s.charAt(0).toUpperCase() + s.slice(1))
    .join(" ");
}

// 1-based syllabus position of `chapter` within its `subject`. Returns
// `null` when the chapter isn't in the taxonomy (legacy / typo data).
export function chapterPosition(
  taxonomy: PublicTaxonomy | undefined,
  subject: string,
  chapter: string,
): number | null {
  if (!taxonomy) return null;
  const list = taxonomy.flat?.[subject];
  if (!list) return null;
  const idx = list.indexOf(chapter);
  return idx >= 0 ? idx + 1 : null;
}

// Bangla label for a chapter, with English fallback when no translation
// exists. Falls back further to the prettified key when the subject
// itself isn't mapped.
export function chapterDisplayName(
  taxonomy: PublicTaxonomy | undefined,
  subject: string,
  chapter: string,
): string {
  const bn = taxonomy?.labels_bn?.[subject]?.[chapter];
  if (bn) return bn;
  return prettifyKey(chapter);
}

// "1. ভেক্টর" — what most chapter rows in the UI render. When we don't
// know the syllabus position, omit the prefix rather than printing "—. ".
export function chapterSerialLabel(
  taxonomy: PublicTaxonomy | undefined,
  subject: string,
  chapter: string,
): string {
  const name = chapterDisplayName(taxonomy, subject, chapter);
  const pos = chapterPosition(taxonomy, subject, chapter);
  return pos !== null ? `${pos}. ${name}` : name;
}

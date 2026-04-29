// Mirror of the top-level subject keys in `backend/chapters.yaml`. Keep in
// sync by hand — the backend validates submitted subjects against the same
// list, so an out-of-date entry here will surface as a 400 from /extract.

export const ALL_SUBJECTS = [
  "physics",
  "chemistry",
  "mathematics",
  "biology",
  "bangla",
  "english",
] as const;

export type SubjectKey = (typeof ALL_SUBJECTS)[number];

// Subjects that have a paper_1 / paper_2 split. For HSC single-subject
// uploads in one of these, `subject_paper` is required.
export const PAPER_SPLIT_SUBJECTS = new Set<SubjectKey>([
  "physics",
  "chemistry",
  "mathematics",
  "biology",
]);

export function prettySubject(s: string): string {
  return s.charAt(0).toUpperCase() + s.slice(1);
}

import type { ExamPaperSummary } from "@/types/exam";

/** Compact, human-readable subtitle for a paper, shaped to its exam_type. */
export function paperTitle(p: ExamPaperSummary): string {
  if (p.exam_type === "admission_test") {
    const u = p.university_name || "Unknown University";
    const s = p.exam_session || "—";
    const unit = p.exam_unit ? ` • Unit ${p.exam_unit}` : "";
    return `${u} • ${s}${unit}`;
  }
  const b = p.board_name || "Unknown Board";
  const y = p.exam_year || "—";
  const subj = p.subject ? ` • ${p.subject}` : "";
  const paper = p.subject_paper ? ` (P${p.subject_paper})` : "";
  return `${b} • ${y}${subj}${paper}`;
}

/** "MCQ" / "Written" badge text. */
export function questionTypeLabel(t: string): string {
  return t === "mcq" ? "MCQ" : "Written";
}

export function examTypeLabel(t: string): string {
  return t === "admission_test" ? "Admission" : "HSC Board";
}

/** Remove `[IMAGE]` and `[IMAGE_N]` tokens from a string. Used when an option
 * has both an `image_filename` (rendered as a standalone <img>) and image
 * tokens in its `text` — without stripping, the image renders twice. */
export function stripImageTokens(s: string): string {
  return s.replace(/\[IMAGE(?:_\d+)?\]/g, "").trim();
}

/** "Q01 · Dhaka University · 2015–2016 · Unit A" — compact provenance line
 * shown above each question on the quiz / review screens so students (and
 * debuggers) can trace a question back to its source paper. */
export function questionSourceLine(q: {
  question_number: string;
  university_name?: string | null;
  exam_session?: string | null;
  exam_unit?: string | null;
}): string {
  const parts: string[] = [`Q${q.question_number}`];
  if (q.university_name) parts.push(q.university_name);
  if (q.exam_session) parts.push(q.exam_session);
  if (q.exam_unit) parts.push(`Unit ${q.exam_unit}`);
  return parts.join(" · ");
}

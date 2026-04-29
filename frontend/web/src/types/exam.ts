// Wire types mirroring the backend's `api_schemas.py` response models.
// Keep these in sync by hand — they're the contract between the two sides.

export type ExamType = "admission_test" | "hsc_board";
export type QuestionType = "mcq" | "written";

export interface Option {
  id?: string;
  label: string;
  text: string;
}

export interface OptionFull extends Option {
  id: string;
  question_id: string;
  display_order: number;
}

// Image cropped from the source PDF and served by
// GET /exams/{paper_id}/images/{filename}. Ids scope PER QUESTION — the same
// `IMAGE_1` id can exist under two different questions and refer to two
// different files. Text fields reference an image by embedding the literal
// token `[IMAGE_N]` where N matches the trailing digits of `id`.
export interface QuestionImage {
  id: string;
  page_index: number;
  box_2d: [number, number, number, number];
  label?: string | null;
  kind: "diagram" | "table";
  filename?: string | null;
}

// --- question variants ----------------------------------------------------

export interface AdmissionMcqQuestion {
  id: string;
  paper_id: string;
  question_number: string;
  question_text: string;
  university_name: string | null;
  exam_session: string | null;
  exam_unit: string | null;
  subject: string | null;
  chapter: string | null;
  correct_answer: string | null;
  solution: string | null;
  solution_status: string;
  has_image: boolean;
  images?: QuestionImage[];
  options: Option[];
  gemini_solution?: string | null;
  gemini_correct_answer?: string | null;
}

export interface AdmissionWrittenQuestion {
  id: string;
  paper_id: string;
  question_number: string;
  question_text: string;
  university_name: string | null;
  exam_session: string | null;
  exam_unit: string | null;
  subject: string | null;
  chapter: string | null;
  solution: string | null;
  solution_status: string;
  has_image: boolean;
  images?: QuestionImage[];
  gemini_solution?: string | null;
  gemini_correct_answer?: string | null;
}

export interface HscMcqQuestion {
  id: string;
  paper_id: string;
  question_number: string;
  question_text: string;
  board_name: string | null;
  exam_year: string | null;
  subject: string | null;
  subject_paper: string | null;
  chapter: string | null;
  correct_answer: string | null;
  solution: string | null;
  solution_status: string;
  has_image: boolean;
  images?: QuestionImage[];
  options: Option[];
  gemini_solution?: string | null;
  gemini_correct_answer?: string | null;
}

export interface HscWrittenSubpart {
  id: string;
  label: string;
  marks: number;
  text: string;
  solution: string | null;
  solution_status: string;
  has_image: boolean;
  gemini_solution?: string | null;
  gemini_correct_answer?: string | null;
}

export interface HscWrittenQuestion {
  id: string;
  paper_id: string;
  question_number: string;
  board_name: string | null;
  exam_year: string | null;
  subject: string | null;
  subject_paper: string | null;
  uddipak_text: string;
  uddipak_has_image: boolean;
  images?: QuestionImage[];
  sub_parts: HscWrittenSubpart[];
}

export type AnyQuestion =
  | AdmissionMcqQuestion
  | AdmissionWrittenQuestion
  | HscMcqQuestion
  | HscWrittenQuestion;

// --- paper summaries ------------------------------------------------------

export interface ExamPaperSummary {
  id: string;
  source_filename: string;
  exam_type: ExamType;
  question_type: QuestionType;
  university_name: string | null;
  exam_session: string | null;
  exam_unit: string | null;
  board_name: string | null;
  exam_year: string | null;
  subject: string | null;
  subject_paper: string | null;
  page_count: number;
  question_count: number;
  has_source_pdf: boolean;
  created_at: string | null;
  answer_mismatch_count: number;
}

export interface ExamPaperDetail extends ExamPaperSummary {
  chapter_counts: Record<string, number>;
}

export interface ExamListResponse {
  total: number;
  items: ExamPaperSummary[];
}

export interface QuestionListResponse<Q = AnyQuestion> {
  total: number;
  items: Q[];
}

// --- jobs -----------------------------------------------------------------

export type JobState = "pending" | "running" | "done" | "failed";

export interface JobStatus {
  job_id: string;
  state: JobState;
  progress: { page: number; total: number };
  result_path: string | null;
  paper_id: string | null;
  error: string | null;
}

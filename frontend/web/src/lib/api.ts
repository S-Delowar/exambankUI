// Thin fetch wrapper around the FastAPI backend. Keeps the base URL in one
// place and turns non-2xx responses into thrown Errors with the server's
// `detail` field surfaced so UI code can show meaningful messages.

import type {
  AnyQuestion,
  ExamListResponse,
  ExamPaperDetail,
  ExamType,
  JobStatus,
  QuestionImage,
  QuestionListResponse,
  QuestionType,
} from "@/types/exam";

export const API_BASE_URL =
  process.env.NEXT_PUBLIC_API_BASE_URL || "http://localhost:8000";

class ApiError extends Error {
  status: number;
  constructor(status: number, message: string) {
    super(message);
    this.status = status;
  }
}

async function doFetch(
  path: string,
  init: RequestInit,
  token: string | null,
): Promise<Response> {
  const headers: Record<string, string> = {
    ...(init.body && !(init.body instanceof FormData)
      ? { "Content-Type": "application/json" }
      : {}),
    ...((init.headers as Record<string, string>) || {}),
  };
  if (token) headers["Authorization"] = `Bearer ${token}`;
  return fetch(`${API_BASE_URL}${path}`, {
    ...init,
    headers,
    cache: "no-store",
  });
}

async function request<T>(
  path: string,
  init: RequestInit = {},
): Promise<T> {
  // Lazy import to avoid pulling auth.ts into modules that don't need it.
  const { getSession, refresh, setSession } = await import("./auth");
  const session = getSession();
  let token = session?.access_token ?? null;

  let res = await doFetch(path, init, token);

  // Single retry path: if access token is rejected, try a refresh once.
  if (res.status === 401 && session) {
    const next = await refresh();
    if (next) {
      token = next;
      res = await doFetch(path, init, token);
    } else {
      // refresh failed → session was already cleared by refresh(); fall through.
      setSession(null);
    }
  }

  if (!res.ok) {
    let detail = `HTTP ${res.status}`;
    try {
      const body = (await res.json()) as { detail?: string };
      if (body.detail) detail = body.detail;
    } catch {
      // ignore JSON parse errors, fall through with the HTTP message
    }
    throw new ApiError(res.status, detail);
  }
  if (res.status === 204) return undefined as T;
  const ct = res.headers.get("content-type") || "";
  if (ct.includes("application/json")) return (await res.json()) as T;
  return (await res.text()) as unknown as T;
}

// ---------------------------------------------------------------------------
// Extraction
// ---------------------------------------------------------------------------

export interface ExtractParams {
  file: File;
  exam_type: ExamType;
  question_type: QuestionType;
  subjects: string[];
  subject_paper?: "1" | "2";
}

export async function extractUpload(p: ExtractParams): Promise<JobStatus> {
  const qs = new URLSearchParams({
    exam_type: p.exam_type,
    question_type: p.question_type,
    subjects: p.subjects.join(","),
  });
  if (p.subject_paper) qs.set("subject_paper", p.subject_paper);

  const fd = new FormData();
  fd.append("file", p.file);

  return request<JobStatus>(`/extract?${qs.toString()}`, {
    method: "POST",
    body: fd,
  });
}

export function getJobStatus(jobId: string): Promise<JobStatus> {
  return request<JobStatus>(`/jobs/${jobId}`);
}

// ---------------------------------------------------------------------------
// Papers (history + detail)
// ---------------------------------------------------------------------------

export interface ListPapersParams {
  exam_type?: ExamType;
  question_type?: QuestionType;
  limit?: number;
  offset?: number;
}

export function listPapers(p: ListPapersParams = {}): Promise<ExamListResponse> {
  const qs = new URLSearchParams();
  if (p.exam_type) qs.set("exam_type", p.exam_type);
  if (p.question_type) qs.set("question_type", p.question_type);
  qs.set("limit", String(p.limit ?? 50));
  qs.set("offset", String(p.offset ?? 0));
  return request<ExamListResponse>(`/exams?${qs.toString()}`);
}

export function getPaper(paperId: string): Promise<ExamPaperDetail> {
  return request<ExamPaperDetail>(`/exams/${paperId}`);
}

export function sourcePdfUrl(paperId: string): string {
  return `${API_BASE_URL}/exams/${paperId}/source.pdf`;
}

// Resolves to the cropped PNG served by the backend. `filename` comes from
// `QuestionImage.filename` (bare basename like `p03_q07_01.png`); the helper
// URL-encodes it defensively even though the backend blocks traversal too.
// Pass `version` after a successful re-crop / replace so the browser doesn't
// serve the old PNG from cache (the file is overwritten in place under the
// same URL).
export function questionImageUrl(
  paperId: string,
  filename: string,
  version?: number,
): string {
  const base = `${API_BASE_URL}/exams/${paperId}/images/${encodeURIComponent(filename)}`;
  return version ? `${base}?v=${version}` : base;
}

// ---------------------------------------------------------------------------
// Questions
// ---------------------------------------------------------------------------

export interface ListQuestionsParams {
  // Either paper_id OR (exam_type + question_type) is required by the
  // backend — supplying just (subject) without the discriminators would 400.
  paper_id?: string;
  exam_type?: ExamType;
  question_type?: QuestionType;
  subject?: string;
  chapter?: string;
  limit?: number;
  offset?: number;
}

export function listQuestions(
  p: ListQuestionsParams,
): Promise<QuestionListResponse> {
  const qs = new URLSearchParams();
  if (p.paper_id) qs.set("paper_id", p.paper_id);
  if (p.exam_type) qs.set("exam_type", p.exam_type);
  if (p.question_type) qs.set("question_type", p.question_type);
  if (p.subject) qs.set("subject", p.subject);
  if (p.chapter) qs.set("chapter", p.chapter);
  qs.set("limit", String(p.limit ?? 500));
  qs.set("offset", String(p.offset ?? 0));
  return request<QuestionListResponse>(`/questions?${qs.toString()}`);
}

// ---------------------------------------------------------------------------
// Review (PATCH / DELETE)
// ---------------------------------------------------------------------------

export function patchQuestion(params: {
  question_id: string;
  exam_type: ExamType;
  question_type: QuestionType;
  patch: Record<string, unknown>;
}): Promise<AnyQuestion> {
  const qs = new URLSearchParams({
    exam_type: params.exam_type,
    question_type: params.question_type,
  });
  return request<AnyQuestion>(
    `/review/questions/${params.question_id}?${qs.toString()}`,
    { method: "PATCH", body: JSON.stringify(params.patch) },
  );
}

export function deleteQuestion(params: {
  question_id: string;
  exam_type: ExamType;
  question_type: QuestionType;
}): Promise<void> {
  const qs = new URLSearchParams({
    exam_type: params.exam_type,
    question_type: params.question_type,
  });
  return request<void>(
    `/review/questions/${params.question_id}?${qs.toString()}`,
    { method: "DELETE" },
  );
}

export function patchOption(params: {
  option_id: string;
  exam_type: ExamType;
  patch: Record<string, unknown>;
}) {
  const qs = new URLSearchParams({ exam_type: params.exam_type });
  return request<Record<string, unknown>>(
    `/review/options/${params.option_id}?${qs.toString()}`,
    { method: "PATCH", body: JSON.stringify(params.patch) },
  );
}

export function deleteOption(params: {
  option_id: string;
  exam_type: ExamType;
}): Promise<void> {
  const qs = new URLSearchParams({ exam_type: params.exam_type });
  return request<void>(
    `/review/options/${params.option_id}?${qs.toString()}`,
    { method: "DELETE" },
  );
}

export function createOption(params: {
  question_id: string;
  exam_type: ExamType;
  label: string;
  text: string;
}) {
  const qs = new URLSearchParams({ exam_type: params.exam_type });
  return request<Record<string, unknown>>(
    `/review/questions/${params.question_id}/options?${qs.toString()}`,
    {
      method: "POST",
      body: JSON.stringify({ label: params.label, text: params.text }),
    },
  );
}

export function patchSubpart(params: {
  subpart_id: string;
  patch: Record<string, unknown>;
}) {
  return request<Record<string, unknown>>(
    `/review/subparts/${params.subpart_id}`,
    { method: "PATCH", body: JSON.stringify(params.patch) },
  );
}

export function replaceQuestionImage(params: {
  question_id: string;
  image_id: string;
  exam_type: ExamType;
  question_type: QuestionType;
  blob: Blob;
}): Promise<QuestionImage> {
  const qs = new URLSearchParams({
    exam_type: params.exam_type,
    question_type: params.question_type,
  });
  const fd = new FormData();
  fd.append("file", params.blob, "image.png");
  return request<QuestionImage>(
    `/review/questions/${params.question_id}/images/${encodeURIComponent(params.image_id)}?${qs.toString()}`,
    { method: "PUT", body: fd },
  );
}

export function deleteQuestionImage(params: {
  question_id: string;
  image_id: string;
  exam_type: ExamType;
  question_type: QuestionType;
}): Promise<void> {
  const qs = new URLSearchParams({
    exam_type: params.exam_type,
    question_type: params.question_type,
  });
  return request<void>(
    `/review/questions/${params.question_id}/images/${encodeURIComponent(params.image_id)}?${qs.toString()}`,
    { method: "DELETE" },
  );
}

// ---------------------------------------------------------------------------
// Taxonomy
// ---------------------------------------------------------------------------

// Admin-only — used by the reviewer's chapter picker. Returns flat
// {subject: [chapter,...]}. Kept distinct from the public endpoint below so
// non-admin pages don't 403.
export function getChapterTaxonomy(): Promise<Record<string, string[]>> {
  return request<Record<string, string[]>>("/review/taxonomy/chapters");
}

// Public taxonomy for the student subject browser. `flat` merges paper_1/2 and
// is the convenient default; `nested` preserves HSC's paper-grouped shape so
// the UI can render paper_1 / paper_2 sections when present.
export interface PublicTaxonomy {
  flat: Record<string, string[]>;
  nested: Record<string, string[] | Record<string, string[]>>;
  // Bangla display labels keyed by (subject, chapter_key). Missing entries
  // are intentionally allowed — caller falls back to a prettified English
  // key. See backend/chapters_bn.yaml.
  labels_bn: Record<string, Record<string, string>>;
}

export function getPublicTaxonomy(): Promise<PublicTaxonomy> {
  return request<PublicTaxonomy>("/taxonomy/chapters");
}

// ---------------------------------------------------------------------------
// Stats / Quizzes (public — student listing)
// ---------------------------------------------------------------------------

// One entry per (subject, exam_type) quiz. Students only see entries with
// status='published' (the backend filters automatically based on caller's
// is_admin flag). Admins see every quiz with current status.
export interface QuizStat {
  subject: string;
  exam_type: ExamType;
  total: number;
  by_chapter: Record<string, number>;
  status: "draft" | "published" | "archived";
}

export interface QuizStatsResponse {
  quizzes: QuizStat[];
}

export function getQuizStats(): Promise<QuizStatsResponse> {
  return request<QuizStatsResponse>("/stats/subjects");
}

// ---------------------------------------------------------------------------
// Progress
// ---------------------------------------------------------------------------

export interface SubjectProgress {
  subject: string;
  attempted: number;
  correct: number;
  accuracy: number;
}

export interface ChapterProgress {
  subject: string;
  chapter: string;
  attempted: number;
  correct: number;
  accuracy: number;
}

export interface ProgressSummary {
  streak_days: number;
  total_attempts: number;
  total_questions: number;
  total_correct: number;
  weekly_accuracy: number;
  by_subject: SubjectProgress[];
  by_chapter: ChapterProgress[];
}

export function getProgressSummary(): Promise<ProgressSummary> {
  return request<ProgressSummary>("/progress/summary");
}

// ---------------------------------------------------------------------------
// Quiz / attempts (student-facing)
// ---------------------------------------------------------------------------

export type AttemptKind = "exam" | "drill" | "subject_quiz";
export type AttemptStatus = "in_progress" | "submitted" | "abandoned";

export interface AttemptSummary {
  id: string;
  kind: AttemptKind;
  mode: "timed" | "untimed";
  paper_id: string | null;
  drill_subject: string | null;
  drill_chapter: string | null;
  exam_type: string | null;
  status: AttemptStatus;
  started_at: string;
  submitted_at: string | null;
  score_correct: number | null;
  score_total: number | null;
}

export interface AttemptListResponse {
  total: number;
  items: AttemptSummary[];
}

export interface AttemptStartResponse {
  id: string;
  question_ids: string[];
  started_at: string;
}

export interface QuizPublicOption {
  id?: string;
  label: string;
  text: string;
  image_filename?: string | null;
}

export interface QuizPublicQuestion {
  id: string;
  paper_id: string;
  question_number: string;
  question_text: string;
  subject: string | null;
  chapter: string | null;
  has_image: boolean;
  images?: import("@/types/exam").QuestionImage[];
  options: QuizPublicOption[];
  university_name?: string | null;
  exam_session?: string | null;
  exam_unit?: string | null;
}

export interface QuizQuestionsPage {
  total: number;
  page: number;
  page_size: number;
  items: QuizPublicQuestion[];
}

export interface QuizReviewQuestion extends QuizPublicQuestion {
  correct_answer: string | null;
  solution: string | null;
  gemini_solution: string | null;
  selected_label: string | null;
  is_correct: boolean | null;
}

export interface QuizReviewPage {
  total: number;
  page: number;
  page_size: number;
  items: QuizReviewQuestion[];
}

export interface AttemptResult {
  id: string;
  score_correct: number;
  score_total: number;
  elapsed_sec: number;
  breakdown: {
    by_subject: Array<{
      subject: string;
      attempted: number;
      correct: number;
      accuracy: number;
    }>;
    by_chapter: Array<{
      subject: string;
      chapter: string;
      attempted: number;
      correct: number;
      accuracy: number;
    }>;
  };
}

export interface AttemptDetail extends AttemptSummary {
  question_ids: string[];
  answers: Array<{
    question_id: string;
    selected_label: string;
    is_correct: boolean;
    answered_at: string;
  }>;
}

export function listAttempts(
  limit = 50,
  offset = 0,
): Promise<AttemptListResponse> {
  const qs = new URLSearchParams({
    limit: String(limit),
    offset: String(offset),
  });
  return request<AttemptListResponse>(`/attempts?${qs.toString()}`);
}

// `exam_type` defaults to admission_test on the backend if omitted; we send
// it explicitly so a future HSC quiz UI doesn't need a second function.
export function startSubjectQuiz(params: {
  subject: string;
  exam_type?: ExamType;
}): Promise<AttemptStartResponse> {
  return request<AttemptStartResponse>("/attempts", {
    method: "POST",
    body: JSON.stringify({
      kind: "subject_quiz",
      mode: "untimed",
      subject: params.subject,
      exam_type: params.exam_type ?? "admission_test",
    }),
  });
}

// Chapter drill — admission-test MCQs only (HSC drill via /attempts is not
// yet supported by the backend; the read-only /drill endpoint still works
// but doesn't create a scorable attempt). `count` is bounded 5..100 by the
// backend schema.
export function startChapterDrill(params: {
  subject: string;
  chapter: string;
  count?: number;
}): Promise<AttemptStartResponse> {
  return request<AttemptStartResponse>("/attempts", {
    method: "POST",
    body: JSON.stringify({
      kind: "drill",
      mode: "untimed",
      drill: {
        exam_type: "admission_test",
        subject: params.subject,
        chapter: params.chapter,
        count: params.count ?? 20,
      },
    }),
  });
}

export function getAttempt(attemptId: string): Promise<AttemptDetail> {
  return request<AttemptDetail>(`/attempts/${attemptId}`);
}

export function getAttemptQuestions(
  attemptId: string,
  page: number,
  page_size = 50,
): Promise<QuizQuestionsPage> {
  const qs = new URLSearchParams({
    page: String(page),
    page_size: String(page_size),
  });
  return request<QuizQuestionsPage>(
    `/attempts/${attemptId}/questions?${qs.toString()}`,
  );
}

export function getAttemptReview(
  attemptId: string,
  page: number,
  page_size = 50,
): Promise<QuizReviewPage> {
  const qs = new URLSearchParams({
    page: String(page),
    page_size: String(page_size),
  });
  return request<QuizReviewPage>(
    `/attempts/${attemptId}/review?${qs.toString()}`,
  );
}

export function recordAttemptAnswer(
  attemptId: string,
  question_id: string,
  selected_label: string,
): Promise<{ is_correct: boolean; correct_answer: string | null }> {
  return request(`/attempts/${attemptId}/answer`, {
    method: "POST",
    body: JSON.stringify({ question_id, selected_label }),
  });
}

export function submitAttempt(attemptId: string): Promise<AttemptResult> {
  return request<AttemptResult>(`/attempts/${attemptId}/submit`, {
    method: "POST",
  });
}

// ---------------------------------------------------------------------------
// Admin: quizzes (status + roster)
// ---------------------------------------------------------------------------

export type QuizStatus = "draft" | "published" | "archived";

export interface AdminQuizListEntry {
  subject: string;
  exam_type: ExamType;
  total_questions: number;
  status: QuizStatus;
  attempts_in_progress: number;
  attempts_submitted: number;
  attempts_total: number;
}

export interface AdminQuizListResponse {
  quizzes: AdminQuizListEntry[];
}

export function adminListQuizzes(): Promise<AdminQuizListResponse> {
  return request<AdminQuizListResponse>("/admin/quizzes");
}

export interface AdminQuizStatusOut {
  subject: string;
  exam_type: ExamType;
  status: QuizStatus;
  updated_at: string;
  updated_by_id: string | null;
}

export function adminSetQuizStatus(params: {
  subject: string;
  exam_type: ExamType;
  status: QuizStatus;
}): Promise<AdminQuizStatusOut> {
  return request<AdminQuizStatusOut>(
    `/admin/quizzes/${encodeURIComponent(params.subject)}/${encodeURIComponent(params.exam_type)}/status`,
    {
      method: "PUT",
      body: JSON.stringify({ status: params.status }),
    },
  );
}

export interface AdminRosterEntry extends AttemptSummary {
  user_email: string;
  user_display_name: string;
}

// Returned by GET /admin/attempts/{id} — student identity is included so
// the admin drill-down header can show *whose* attempt this is.
export interface AdminAttemptDetail extends AttemptDetail {
  user_id: string;
  user_email: string;
  user_display_name: string;
}

export interface AdminRosterResponse {
  total: number;
  items: AdminRosterEntry[];
}

export function adminListQuizAttempts(params: {
  subject: string;
  exam_type: ExamType;
  status?: "all" | "in_progress" | "submitted" | "abandoned";
  limit?: number;
  offset?: number;
}): Promise<AdminRosterResponse> {
  const qs = new URLSearchParams({
    status: params.status ?? "all",
    limit: String(params.limit ?? 100),
    offset: String(params.offset ?? 0),
  });
  return request<AdminRosterResponse>(
    `/admin/quizzes/${encodeURIComponent(params.subject)}/${encodeURIComponent(params.exam_type)}/attempts?${qs.toString()}`,
  );
}

// ---------------------------------------------------------------------------
// Admin: attempt drill-down (read any user's attempt + per-question review)
// ---------------------------------------------------------------------------

export function adminGetAttempt(
  attemptId: string,
): Promise<AdminAttemptDetail> {
  return request<AdminAttemptDetail>(`/admin/attempts/${attemptId}`);
}

export function adminGetAttemptReview(
  attemptId: string,
  page: number,
  page_size = 50,
): Promise<QuizReviewPage> {
  const qs = new URLSearchParams({
    page: String(page),
    page_size: String(page_size),
  });
  return request<QuizReviewPage>(
    `/admin/attempts/${attemptId}/review?${qs.toString()}`,
  );
}

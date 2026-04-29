"use client";

import { useEffect, useRef, useState } from "react";
import { useRouter } from "next/navigation";
import { extractUpload, getJobStatus } from "@/lib/api";
import { ALL_SUBJECTS, PAPER_SPLIT_SUBJECTS, prettySubject } from "@/lib/subjects";
import type { ExamType, JobStatus, QuestionType } from "@/types/exam";
import RequireAuth from "@/components/RequireAuth";

export default function UploadPage() {
  return (
    <RequireAuth adminOnly>
      <UploadPageInner />
    </RequireAuth>
  );
}

function UploadPageInner() {
  const router = useRouter();
  const fileInputRef = useRef<HTMLInputElement>(null);

  const [file, setFile] = useState<File | null>(null);
  const [examType, setExamType] = useState<ExamType>("admission_test");
  const [questionType, setQuestionType] = useState<QuestionType>("mcq");
  const [subjects, setSubjects] = useState<Set<string>>(new Set());
  const [subjectPaper, setSubjectPaper] = useState<"1" | "2" | "">("");

  const [submitting, setSubmitting] = useState(false);
  const [job, setJob] = useState<JobStatus | null>(null);
  const [error, setError] = useState<string | null>(null);

  // When HSC + exactly one subject that has a paper split is selected, the
  // backend requires `subject_paper`. For every other combination it must
  // be omitted — wipe it here so the UI reflects the rule.
  const selectedSubjects = Array.from(subjects);
  const singleSubject =
    selectedSubjects.length === 1 ? (selectedSubjects[0] as string) : null;
  const needsPaper =
    examType === "hsc_board" &&
    singleSubject !== null &&
    PAPER_SPLIT_SUBJECTS.has(singleSubject as never);
  useEffect(() => {
    if (!needsPaper) setSubjectPaper("");
  }, [needsPaper]);

  const toggleSubject = (s: string) => {
    setSubjects((prev) => {
      const next = new Set(prev);
      if (next.has(s)) next.delete(s);
      else next.add(s);
      return next;
    });
  };

  const canSubmit =
    file !== null &&
    subjects.size > 0 &&
    !submitting &&
    (!needsPaper || subjectPaper !== "");

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!file) return;
    setError(null);
    setSubmitting(true);
    try {
      const started = await extractUpload({
        file,
        exam_type: examType,
        question_type: questionType,
        subjects: selectedSubjects,
        subject_paper: needsPaper ? (subjectPaper as "1" | "2") : undefined,
      });
      setJob(started);
    } catch (e) {
      setError(e instanceof Error ? e.message : "Upload failed");
    } finally {
      setSubmitting(false);
    }
  }

  // Poll job status every 2s until done/failed.
  useEffect(() => {
    if (!job || job.state === "done" || job.state === "failed") return;
    const id = setInterval(async () => {
      try {
        const next = await getJobStatus(job.job_id);
        setJob(next);
      } catch (e) {
        setError(e instanceof Error ? e.message : "Job status fetch failed");
      }
    }, 2000);
    return () => clearInterval(id);
  }, [job]);

  const doneBanner =
    job && job.state === "done" ? (
      <div className="rounded-md bg-green-50 border border-green-200 p-4 space-y-3">
        <p className="text-green-800 font-medium">Extraction complete.</p>
        <div className="flex flex-wrap gap-2">
          {job.paper_id ? (
            <button
              onClick={() => router.push(`/admin/papers/${job.paper_id}/review`)}
              className="px-4 py-2 rounded-md bg-blue-600 text-white text-sm font-medium hover:bg-blue-700"
            >
              View result
            </button>
          ) : null}
          <button
            onClick={() => router.push("/admin/jobs")}
            className="px-4 py-2 rounded-md border border-slate-300 bg-white text-sm font-medium hover:bg-slate-50"
          >
            Open History
          </button>
        </div>
      </div>
    ) : null;

  return (
    <div className="max-w-3xl mx-auto px-4 py-6 sm:py-10">
      <h1 className="text-xl sm:text-2xl font-semibold mb-6">Upload a PDF for extraction</h1>

      <form onSubmit={onSubmit} className="space-y-6">
        <fieldset className="space-y-2">
          <label className="text-sm font-medium">PDF file</label>
          <input
            ref={fileInputRef}
            type="file"
            accept="application/pdf"
            onChange={(e) => setFile(e.target.files?.[0] || null)}
            className="block w-full text-sm border border-slate-300 rounded-md p-2"
          />
        </fieldset>

        <fieldset className="space-y-2">
          <label className="text-sm font-medium">Exam type</label>
          <div className="flex gap-4">
            {(["admission_test", "hsc_board"] as ExamType[]).map((t) => (
              <label key={t} className="flex items-center gap-2 text-sm">
                <input
                  type="radio"
                  name="exam_type"
                  checked={examType === t}
                  onChange={() => setExamType(t)}
                />
                {t === "admission_test" ? "Admission Test" : "HSC Board"}
              </label>
            ))}
          </div>
        </fieldset>

        <fieldset className="space-y-2">
          <label className="text-sm font-medium">Question type</label>
          <div className="flex gap-4">
            {(["mcq", "written"] as QuestionType[]).map((t) => (
              <label key={t} className="flex items-center gap-2 text-sm">
                <input
                  type="radio"
                  name="question_type"
                  checked={questionType === t}
                  onChange={() => setQuestionType(t)}
                />
                {t === "mcq" ? "MCQ" : "Written"}
              </label>
            ))}
          </div>
        </fieldset>

        <fieldset className="space-y-2">
          <label className="text-sm font-medium">
            Subjects in this PDF (check all that apply)
          </label>
          <div className="grid grid-cols-2 sm:grid-cols-3 gap-2">
            {ALL_SUBJECTS.map((s) => (
              <label
                key={s}
                className="flex items-center gap-2 text-sm border border-slate-200 rounded-md p-2 hover:border-slate-400"
              >
                <input
                  type="checkbox"
                  checked={subjects.has(s)}
                  onChange={() => toggleSubject(s)}
                />
                {prettySubject(s)}
              </label>
            ))}
          </div>
        </fieldset>

        {needsPaper && (
          <fieldset className="space-y-2">
            <label className="text-sm font-medium">
              Paper (required for HSC {singleSubject})
            </label>
            <div className="flex gap-4">
              {(["1", "2"] as const).map((p) => (
                <label key={p} className="flex items-center gap-2 text-sm">
                  <input
                    type="radio"
                    name="subject_paper"
                    checked={subjectPaper === p}
                    onChange={() => setSubjectPaper(p)}
                  />
                  {p === "1" ? "1st Paper" : "2nd Paper"}
                </label>
              ))}
            </div>
          </fieldset>
        )}

        {error && (
          <div className="rounded-md bg-red-50 border border-red-200 p-3 text-sm text-red-700">
            {error}
          </div>
        )}

        <button
          type="submit"
          disabled={!canSubmit}
          className="px-4 py-2 rounded-md bg-blue-600 text-white disabled:bg-slate-400"
        >
          {submitting ? "Uploading…" : "Start extraction"}
        </button>
      </form>

      {job && (
        <section className="mt-8 space-y-3">
          <h2 className="text-lg font-medium">Job {job.job_id.slice(0, 8)}</h2>
          <div className="text-sm text-slate-600">
            State: <span className="font-medium">{job.state}</span>
          </div>
          {job.progress.total > 0 && (
            <div className="space-y-1">
              <div className="flex justify-between text-sm text-slate-600">
                <span>Processing pages</span>
                <span>
                  Page {job.progress.page} / {job.progress.total}
                </span>
              </div>
              <div className="h-2 w-full rounded-full bg-slate-100 overflow-hidden">
                <div
                  className="h-full bg-blue-600 transition-all duration-300"
                  style={{
                    width: `${Math.min(100, (job.progress.page / job.progress.total) * 100)}%`,
                  }}
                />
              </div>
            </div>
          )}
          {job.state === "failed" && (
            <div className="rounded-md bg-red-50 border border-red-200 p-3 text-sm text-red-700">
              {job.error || "Job failed"}
            </div>
          )}
          {doneBanner}
        </section>
      )}
    </div>
  );
}

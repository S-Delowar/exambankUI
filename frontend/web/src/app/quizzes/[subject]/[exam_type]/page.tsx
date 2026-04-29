"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { use, useState } from "react";
import useSWR from "swr";
import RequireAuth from "@/components/RequireAuth";
import {
  AttemptSummary,
  getProgressSummary,
  getPublicTaxonomy,
  getQuizStats,
  listAttempts,
  startSubjectQuiz,
} from "@/lib/api";
import { chapterSerialLabel } from "@/lib/chapterLabel";
import type { ExamType } from "@/types/exam";

const SUBJECT_LABELS: Record<string, string> = {
  physics: "Physics",
  chemistry: "Chemistry",
  biology: "Biology",
  mathematics: "Mathematics",
  higher_math: "Higher Math",
  bangla: "Bangla",
  english: "English",
  ict: "ICT",
  general_knowledge: "General Knowledge",
};

// Time budget per question, in seconds. Surfaced both as a label on the
// summary card and used to compute the total quiz time. Server-side timing
// (auto-submit on expiry) is a separate follow-up — for now the number is
// guidance only.
const SECONDS_PER_QUESTION = 50;

function subjectLabel(subject: string): string {
  return (
    SUBJECT_LABELS[subject] ??
    subject
      .split("_")
      .map((s) => s.charAt(0).toUpperCase() + s.slice(1))
      .join(" ")
  );
}

function formatDuration(totalSeconds: number): string {
  const hours = Math.floor(totalSeconds / 3600);
  const mins = Math.floor((totalSeconds % 3600) / 60);
  const secs = totalSeconds % 60;
  // Skip zero leading segments. e.g. 90s → "1m 30s", 3725s → "1h 2m 5s",
  // 3600s → "1h", 45s → "45s".
  const parts: string[] = [];
  if (hours > 0) parts.push(`${hours}h`);
  if (mins > 0) parts.push(`${mins}m`);
  if (secs > 0 || parts.length === 0) parts.push(`${secs}s`);
  return parts.join(" ");
}

export default function QuizPage({
  params,
}: {
  params: Promise<{ subject: string; exam_type: string }>;
}) {
  const { subject, exam_type } = use(params);
  if (exam_type !== "admission_test" && exam_type !== "hsc_board") {
    return (
      <div className="max-w-3xl mx-auto px-4 py-10">
        <p className="text-red-700">Unknown quiz: {exam_type}</p>
      </div>
    );
  }
  return (
    <RequireAuth>
      <QuizPageInner subject={subject} examType={exam_type as ExamType} />
    </RequireAuth>
  );
}

function QuizPageInner({
  subject,
  examType,
}: {
  subject: string;
  examType: ExamType;
}) {
  const router = useRouter();
  const stats = useSWR("stats:quizzes", getQuizStats);
  const progress = useSWR("progress:summary", getProgressSummary);
  const taxonomy = useSWR("taxonomy:public", getPublicTaxonomy);
  const attempts = useSWR(`attempts:list:${subject}:${examType}`, () =>
    listAttempts(50, 0),
  );
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function onStartQuiz() {
    setBusy(true);
    setError(null);
    try {
      const att = await startSubjectQuiz({ subject, exam_type: examType });
      router.push(`/quiz/attempt/${att.id}?page=1`);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to start quiz");
      setBusy(false);
    }
  }

  if (stats.error) {
    return (
      <div className="max-w-3xl mx-auto px-4 py-10">
        <p className="text-red-700">
          Failed to load quiz: {stats.error.message}
        </p>
      </div>
    );
  }

  if (!stats.data) {
    return (
      <div className="max-w-3xl mx-auto px-4 py-10">
        <p className="text-slate-500">Loading…</p>
      </div>
    );
  }

  const quiz = stats.data.quizzes.find(
    (q) => q.subject === subject && q.exam_type === examType,
  );

  if (!quiz) {
    return (
      <div className="max-w-3xl mx-auto px-4 py-10">
        <h1 className="text-2xl font-semibold mb-2">{subjectLabel(subject)}</h1>
        <p className="text-slate-600">
          This quiz isn't available right now.
        </p>
        <Link
          href="/quizzes"
          className="text-blue-600 text-sm mt-4 inline-block"
        >
          ← Back to quizzes
        </Link>
      </div>
    );
  }

  const subjectAccuracy = (progress.data?.by_subject ?? []).find(
    (s) => s.subject === subject,
  );

  // In-progress + recent attempts for this exact (subject, exam_type) quiz.
  const quizAttempts = (attempts.data?.items ?? []).filter(
    (a: AttemptSummary) =>
      a.kind === "subject_quiz" &&
      a.drill_subject === subject &&
      a.exam_type === examType,
  );
  const inProgress = quizAttempts.find((a) => a.status === "in_progress");
  const recent = quizAttempts
    .filter((a) => a.status === "submitted")
    .slice(0, 5);

  // Per-chapter accuracy keyed by chapter name (within this subject).
  const chapterAccuracy = new Map(
    (progress.data?.by_chapter ?? [])
      .filter((c) => c.subject === subject)
      .map((c) => [c.chapter, c]),
  );

  // Sort chapters by syllabus position so the on-screen list matches the
  // order students see in the quiz runner and in their NCTB textbook.
  // Chapters not in the taxonomy (legacy / typo) sort to the end.
  // Drop the empty-string bucket (questions without a chapter set) since
  // it's not actionable for students.
  const syllabus = taxonomy.data?.flat?.[subject] ?? [];
  const positionMap = new Map(syllabus.map((c, i) => [c, i]));
  const chapters = Object.entries(quiz.by_chapter)
    .filter(([name]) => name !== "")
    .sort(([a], [b]) => {
      const pa = positionMap.get(a) ?? Infinity;
      const pb = positionMap.get(b) ?? Infinity;
      return pa - pb;
    });

  const totalSeconds = quiz.total * SECONDS_PER_QUESTION;

  return (
    <div className="max-w-3xl mx-auto px-4 py-6 sm:py-10">
      <Link
        href="/quizzes"
        className="text-blue-600 text-sm mb-4 inline-block"
      >
        ← Back to quizzes
      </Link>

      {/* Summary card */}
      <div className="rounded-lg border border-slate-200 bg-white p-4 sm:p-6 mb-6">
        <h1 className="text-xl sm:text-2xl font-semibold mb-4">{subjectLabel(subject)}</h1>

        <dl className="grid grid-cols-2 sm:grid-cols-3 gap-4 text-sm mb-6">
          <div>
            <dt className="text-xs uppercase tracking-wide text-slate-500">
              Subject
            </dt>
            <dd className="font-medium text-slate-900">
              {subjectLabel(subject)}
            </dd>
          </div>
          <div>
            <dt className="text-xs uppercase tracking-wide text-slate-500">
              Questions
            </dt>
            <dd className="font-medium text-slate-900">{quiz.total}</dd>
          </div>
          <div>
            <dt className="text-xs uppercase tracking-wide text-slate-500">
              Total time
            </dt>
            <dd className="font-medium text-slate-900">
              {formatDuration(totalSeconds)}
            </dd>
            <dd className="text-xs text-slate-500 mt-0.5">
              {SECONDS_PER_QUESTION} sec per question
            </dd>
          </div>
        </dl>

        {error && (
          <div className="rounded-md bg-red-50 border border-red-200 p-3 text-sm text-red-700 mb-4">
            {error}
          </div>
        )}

        {inProgress ? (
          <div className="rounded-md border border-amber-200 bg-amber-50 p-4">
            <div className="font-medium mb-1">You have a quiz in progress</div>
            <div className="text-sm text-slate-600 mb-3">
              Started {new Date(inProgress.started_at).toLocaleString()}.
            </div>
            <Link
              href={`/quiz/attempt/${inProgress.id}?page=1`}
              className="inline-block px-4 py-2 rounded-md bg-amber-600 text-white text-sm"
            >
              Resume quiz
            </Link>
          </div>
        ) : (
          <button
            onClick={onStartQuiz}
            disabled={busy}
            className="px-5 py-2.5 rounded-md bg-blue-600 text-white text-sm font-medium hover:bg-blue-700 disabled:opacity-50"
          >
            {busy ? "Starting…" : "Start quiz"}
          </button>
        )}

        {subjectAccuracy && subjectAccuracy.attempted > 0 ? (
          <p className="text-xs text-slate-500 mt-4">
            Your overall accuracy on {subjectLabel(subject)}:{" "}
            {Math.round(subjectAccuracy.accuracy * 100)}% (
            {subjectAccuracy.correct}/{subjectAccuracy.attempted})
          </p>
        ) : null}
      </div>

      {/* Per-chapter question counts */}
      {chapters.length > 0 && (
        <div className="mb-6">
          <h2 className="text-lg font-semibold mb-3">Chapters in this quiz</h2>
          <ul className="divide-y divide-slate-200 border border-slate-200 rounded-md">
            {chapters.map(([name, count]) => {
              const acc = chapterAccuracy.get(name);
              return (
                <li
                  key={name}
                  className="flex items-center justify-between px-4 py-3 text-sm"
                >
                  <div className="min-w-0 truncate font-medium text-slate-900">
                    {chapterSerialLabel(taxonomy.data, subject, name)}
                  </div>
                  <div className="shrink-0 text-slate-600 ml-3 text-right">
                    <div>
                      {count} {count === 1 ? "question" : "questions"}
                    </div>
                    {acc && acc.attempted > 0 ? (
                      <div className="text-xs text-slate-500">
                        {Math.round(acc.accuracy * 100)}% accuracy
                      </div>
                    ) : null}
                  </div>
                </li>
              );
            })}
          </ul>
        </div>
      )}

      {recent.length > 0 && (
        <div>
          <h2 className="text-lg font-semibold mb-3">Past attempts</h2>
          <ul className="divide-y divide-slate-200 border border-slate-200 rounded-md">
            {recent.map((a) => (
              <li key={a.id}>
                <Link
                  href={`/quiz/result/${a.id}`}
                  className="flex items-center justify-between px-4 py-3 hover:bg-slate-50 text-sm"
                >
                  <div>
                    {a.submitted_at
                      ? new Date(a.submitted_at).toLocaleString()
                      : "—"}
                  </div>
                  <div className="text-slate-600">
                    {a.score_correct ?? "—"} / {a.score_total ?? "—"}
                  </div>
                </Link>
              </li>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
}

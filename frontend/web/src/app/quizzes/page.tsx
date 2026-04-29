"use client";

import Link from "next/link";
import useSWR from "swr";
import RequireAuth from "@/components/RequireAuth";
import { getProgressSummary, getQuizStats } from "@/lib/api";

// Per product spec: students don't see admission_test / hsc_board wording.
// They see one card per subject. If multiple exam_types are published for
// the same subject (e.g. physics admission + physics hsc), counts are
// merged on the card; clicking the card sends them to the first available
// exam_type's quiz page (admission_test wins by sort order in the API).
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

function subjectLabel(subject: string): string {
  return (
    SUBJECT_LABELS[subject] ??
    subject
      .split("_")
      .map((s) => s.charAt(0).toUpperCase() + s.slice(1))
      .join(" ")
  );
}

export default function QuizzesPage() {
  return (
    <RequireAuth>
      <QuizzesPageInner />
    </RequireAuth>
  );
}

function QuizzesPageInner() {
  const stats = useSWR("stats:quizzes", getQuizStats);
  const progress = useSWR("progress:summary", getProgressSummary);

  if (stats.error) {
    return (
      <div className="max-w-4xl mx-auto px-4 py-10">
        <p className="text-red-700">
          Failed to load quizzes: {stats.error.message}
        </p>
      </div>
    );
  }

  if (!stats.data) {
    return (
      <div className="max-w-4xl mx-auto px-4 py-10">
        <p className="text-slate-500">Loading quizzes…</p>
      </div>
    );
  }

  const accuracyBySubject = new Map(
    (progress.data?.by_subject ?? []).map((s) => [s.subject, s]),
  );

  return (
    <div className="max-w-4xl mx-auto px-4 py-6 sm:py-10">
      <h1 className="text-xl sm:text-2xl font-semibold mb-2">Quizzes</h1>
      <p className="text-slate-600 text-sm mb-6 sm:mb-8">
        Pick a quiz to start practicing.
      </p>

      {stats.data.quizzes.length === 0 ? (
        <p className="text-slate-500">
          No quizzes published yet. Check back later.
        </p>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          {stats.data.quizzes.map((q) => {
            const acc = accuracyBySubject.get(q.subject);
            return (
              <Link
                key={`${q.subject}::${q.exam_type}`}
                href={`/quizzes/${q.subject}/${q.exam_type}`}
                className="block rounded-lg border border-slate-200 hover:border-blue-500 p-5 transition"
              >
                <div className="text-lg font-medium mb-1">
                  {subjectLabel(q.subject)}
                </div>
                <div className="text-sm text-slate-600">
                  {q.total} questions · {Object.keys(q.by_chapter).length}{" "}
                  chapters
                </div>
                {acc && acc.attempted > 0 ? (
                  <div className="text-xs text-slate-500 mt-2">
                    Your accuracy: {Math.round(acc.accuracy * 100)}% (
                    {acc.correct}/{acc.attempted})
                  </div>
                ) : null}
              </Link>
            );
          })}
        </div>
      )}
    </div>
  );
}

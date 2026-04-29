"use client";

import Link from "next/link";
import { useState } from "react";
import useSWR from "swr";
import {
  AdminQuizListEntry,
  QuizStatus,
  adminListQuizzes,
  adminSetQuizStatus,
} from "@/lib/api";

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

const EXAM_TYPE_LABELS: Record<string, string> = {
  admission_test: "Admission",
  hsc_board: "HSC Board",
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

const STATUS_BADGE: Record<QuizStatus, string> = {
  draft: "bg-slate-100 text-slate-700",
  published: "bg-green-100 text-green-800",
  archived: "bg-amber-100 text-amber-900",
};

export default function AdminQuizzesPage() {
  const list = useSWR("admin:quizzes", adminListQuizzes);
  const [busyKey, setBusyKey] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  async function onSetStatus(
    q: AdminQuizListEntry,
    nextStatus: QuizStatus,
  ) {
    if (q.status === nextStatus) return;
    const key = `${q.subject}::${q.exam_type}`;
    setBusyKey(key);
    setError(null);
    try {
      await adminSetQuizStatus({
        subject: q.subject,
        exam_type: q.exam_type,
        status: nextStatus,
      });
      await list.mutate();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to set status");
    } finally {
      setBusyKey(null);
    }
  }

  if (list.error) {
    return (
      <div className="max-w-5xl mx-auto px-4 py-10">
        <p className="text-red-700">
          Failed to load quizzes: {list.error.message}
        </p>
      </div>
    );
  }

  if (!list.data) {
    return (
      <div className="max-w-5xl mx-auto px-4 py-10">
        <p className="text-slate-500">Loading quizzes…</p>
      </div>
    );
  }

  return (
    <div className="max-w-5xl mx-auto px-4 py-6 sm:py-10">
      <h1 className="text-xl sm:text-2xl font-semibold mb-2">Quizzes</h1>
      <p className="text-slate-600 text-sm mb-6">
        Each row is a `(subject, exam_type)` pair. Publish to make a quiz
        visible to students; archive to hide it from the listing without
        affecting in-progress attempts.
      </p>

      {error && (
        <div className="rounded-md bg-red-50 border border-red-200 p-3 text-sm text-red-700 mb-4">
          {error}
        </div>
      )}

      {list.data.quizzes.length === 0 ? (
        <p className="text-slate-500">
          No questions in the bank yet. Upload a paper first to populate
          quizzes.
        </p>
      ) : (
        <div className="overflow-x-auto border border-slate-200 rounded-md">
          <table className="w-full text-sm">
            <thead className="bg-slate-50 text-left text-xs uppercase tracking-wide text-slate-500">
              <tr>
                <th className="px-3 sm:px-4 py-3">Quiz</th>
                <th className="px-3 sm:px-4 py-3 text-right">Questions</th>
                <th className="px-3 sm:px-4 py-3 text-right">Attempts</th>
                <th className="px-3 sm:px-4 py-3">Status</th>
                <th className="px-3 sm:px-4 py-3 w-1"></th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {list.data.quizzes.map((q) => {
                const key = `${q.subject}::${q.exam_type}`;
                const busy = busyKey === key;
                const canPublish = q.total_questions > 0;
                return (
                  <tr key={key} className="hover:bg-slate-50">
                    <td className="px-3 sm:px-4 py-3">
                      <Link
                        href={`/admin/quizzes/${q.subject}/${q.exam_type}`}
                        className="font-medium text-slate-900 hover:text-blue-600"
                      >
                        {subjectLabel(q.subject)}{" "}
                        <span className="text-slate-500 font-normal">
                          — {EXAM_TYPE_LABELS[q.exam_type] ?? q.exam_type}
                        </span>
                      </Link>
                    </td>
                    <td className="px-3 sm:px-4 py-3 text-right text-slate-700">
                      {q.total_questions}
                    </td>
                    <td className="px-3 sm:px-4 py-3 text-right text-slate-700">
                      {q.attempts_total}
                      {q.attempts_in_progress > 0 ? (
                        <span className="text-xs text-amber-700 ml-2">
                          ({q.attempts_in_progress} live)
                        </span>
                      ) : null}
                    </td>
                    <td className="px-3 sm:px-4 py-3">
                      <span
                        className={`inline-block px-2 py-0.5 rounded-full text-xs ${STATUS_BADGE[q.status]}`}
                      >
                        {q.status}
                      </span>
                    </td>
                    <td className="px-3 sm:px-4 py-3">
                      <select
                        value={q.status}
                        disabled={busy}
                        onChange={(e) =>
                          onSetStatus(q, e.target.value as QuizStatus)
                        }
                        className="text-xs border border-slate-300 rounded px-2 py-1 disabled:opacity-50"
                        title={
                          !canPublish
                            ? "Add questions before publishing"
                            : undefined
                        }
                      >
                        <option value="draft">draft</option>
                        <option value="published" disabled={!canPublish}>
                          published
                        </option>
                        <option value="archived">archived</option>
                      </select>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

"use client";

import Link from "next/link";
import useSWR from "swr";
import RequireAuth from "@/components/RequireAuth";
import {
  AttemptSummary,
  getProgressSummary,
  getPublicTaxonomy,
  listAttempts,
} from "@/lib/api";
import { chapterSerialLabel } from "@/lib/chapterLabel";

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

function labelFor(subject: string | null | undefined): string {
  if (!subject) return "Quiz";
  return (
    SUBJECT_LABELS[subject] ??
    subject
      .split("_")
      .map((s) => s.charAt(0).toUpperCase() + s.slice(1))
      .join(" ")
  );
}

function attemptDescription(a: AttemptSummary): string {
  if (a.kind === "subject_quiz") {
    return `${labelFor(a.drill_subject)} quiz`;
  }
  if (a.kind === "drill")
    return `${labelFor(a.drill_subject)} drill · ${a.drill_chapter ?? ""}`;
  if (a.kind === "exam") return "Practice exam";
  return a.kind;
}

export default function DashboardPage() {
  return (
    <RequireAuth>
      <DashboardInner />
    </RequireAuth>
  );
}

function DashboardInner() {
  const attempts = useSWR("attempts:list:dashboard", () => listAttempts(20, 0));
  const progress = useSWR("progress:summary", getProgressSummary);
  const taxonomy = useSWR("taxonomy:public", getPublicTaxonomy);

  if (attempts.error) {
    return (
      <div className="max-w-4xl mx-auto px-4 py-10">
        <p className="text-red-700">
          Failed to load dashboard: {attempts.error.message}
        </p>
      </div>
    );
  }

  if (!attempts.data) {
    return (
      <div className="max-w-4xl mx-auto px-4 py-10">
        <p className="text-slate-500">Loading…</p>
      </div>
    );
  }

  const inProgress = attempts.data.items.filter(
    (a) => a.status === "in_progress",
  );
  const recent = attempts.data.items
    .filter((a) => a.status === "submitted")
    .slice(0, 5);

  // Weakest chapters (lowest accuracy, only those with ≥5 attempts so the
  // signal isn't noise from a single wrong answer).
  const weakChapters = (progress.data?.by_chapter ?? [])
    .filter((c) => c.attempted >= 5)
    .sort((a, b) => a.accuracy - b.accuracy)
    .slice(0, 3);

  return (
    <div className="max-w-4xl mx-auto px-4 py-6 sm:py-10">
      <h1 className="text-xl sm:text-2xl font-semibold mb-2">Dashboard</h1>
      <p className="text-slate-600 text-sm mb-6 sm:mb-8">
        Pick up where you left off, or start something new.
      </p>

      {inProgress.length > 0 && (
        <div className="mb-8">
          <h2 className="text-lg font-semibold mb-3">In progress</h2>
          <ul className="space-y-2">
            {inProgress.map((a) => (
              <li
                key={a.id}
                className="rounded-md border border-amber-200 bg-amber-50 p-4 flex items-center justify-between gap-3"
              >
                <div className="min-w-0">
                  <div className="font-medium truncate">
                    {attemptDescription(a)}
                  </div>
                  <div className="text-xs text-slate-600">
                    Started {new Date(a.started_at).toLocaleString()}
                  </div>
                </div>
                <Link
                  href={`/quiz/attempt/${a.id}?page=1`}
                  className="shrink-0 px-4 py-2 rounded-md bg-amber-600 text-white text-sm"
                >
                  Resume
                </Link>
              </li>
            ))}
          </ul>
        </div>
      )}

      <div className="mb-8">
        <h2 className="text-lg font-semibold mb-3">Practice</h2>
        <Link
          href="/subjects"
          className="inline-block px-5 py-2.5 rounded-md bg-blue-600 text-white text-sm"
        >
          Browse subjects
        </Link>
      </div>

      {weakChapters.length > 0 && (
        <div className="mb-8">
          <h2 className="text-lg font-semibold mb-3">Worth reviewing</h2>
          <p className="text-xs text-slate-500 mb-3">
            Chapters where your accuracy is lowest (5+ attempts).
          </p>
          <ul className="divide-y divide-slate-200 border border-slate-200 rounded-md">
            {weakChapters.map((c) => (
              <li
                key={`${c.subject}::${c.chapter}`}
                className="flex items-center justify-between px-4 py-3 text-sm"
              >
                <Link
                  href={`/quizzes/${c.subject}/admission_test`}
                  className="hover:text-blue-600 truncate"
                >
                  <span className="text-slate-500">
                    {labelFor(c.subject)}
                  </span>{" "}
                  · {chapterSerialLabel(taxonomy.data, c.subject, c.chapter)}
                </Link>
                <span className="text-slate-600 shrink-0 ml-3">
                  {Math.round(c.accuracy * 100)}% ({c.correct}/{c.attempted})
                </span>
              </li>
            ))}
          </ul>
        </div>
      )}

      {recent.length > 0 && (
        <div>
          <h2 className="text-lg font-semibold mb-3">Recent results</h2>
          <ul className="divide-y divide-slate-200 border border-slate-200 rounded-md">
            {recent.map((a) => (
              <li key={a.id}>
                <Link
                  href={`/quiz/result/${a.id}`}
                  className="flex items-center justify-between px-4 py-3 hover:bg-slate-50 text-sm"
                >
                  <div className="min-w-0">
                    <div className="font-medium truncate">
                      {attemptDescription(a)}
                    </div>
                    <div className="text-xs text-slate-500">
                      {a.submitted_at
                        ? new Date(a.submitted_at).toLocaleString()
                        : "—"}
                    </div>
                  </div>
                  <div className="text-slate-600 shrink-0 ml-3">
                    {a.score_correct ?? "—"} / {a.score_total ?? "—"}
                  </div>
                </Link>
              </li>
            ))}
          </ul>
        </div>
      )}

      {inProgress.length === 0 &&
        recent.length === 0 &&
        weakChapters.length === 0 && (
          <p className="text-slate-500 text-sm">
            Nothing here yet. Pick a subject above to get started.
          </p>
        )}
    </div>
  );
}

"use client";

import Link from "next/link";
import { use, useMemo } from "react";
import useSWR from "swr";
import RequireAuth from "@/components/RequireAuth";
import {
  AttemptDetail,
  PublicTaxonomy,
  getAttempt,
  getAttemptReview,
  getPublicTaxonomy,
} from "@/lib/api";
import { chapterSerialLabel } from "@/lib/chapterLabel";

export default function ResultPage(props: {
  params: Promise<{ attemptId: string }>;
}) {
  return (
    <RequireAuth>
      <ResultPageInner {...props} />
    </RequireAuth>
  );
}

// Server caps page_size at 200; quizzes bigger than that need paging.
const REVIEW_PAGE_SIZE = 200;

// Walk every page of the review payload so the chapter breakdown reflects
// the full attempt, not just the first 200 questions. Returns a flat list
// of (chapter, is_correct, was_answered) tuples — that's all the breakdown
// computation needs, and it lets the caller drop the heavy fields (text,
// solution, options) from memory.
async function fetchAllReviewSlim(attemptId: string): Promise<
  Array<{ chapter: string | null; correct: boolean; answered: boolean }>
> {
  const out: Array<{
    chapter: string | null;
    correct: boolean;
    answered: boolean;
  }> = [];
  let page = 1;
  while (true) {
    const r = await getAttemptReview(attemptId, page, REVIEW_PAGE_SIZE);
    for (const q of r.items) {
      out.push({
        chapter: q.chapter,
        correct: q.is_correct === true,
        answered: q.selected_label != null,
      });
    }
    if (page * r.page_size >= r.total) break;
    page += 1;
  }
  return out;
}

function ResultPageInner({
  params,
}: {
  params: Promise<{ attemptId: string }>;
}) {
  const { attemptId } = use(params);
  const { data, error } = useSWR<AttemptDetail>(
    `attempt:${attemptId}`,
    () => getAttempt(attemptId),
    { revalidateOnFocus: false },
  );
  const reviewSwr = useSWR(
    `attempt:${attemptId}:review:slim`,
    () => fetchAllReviewSlim(attemptId),
    { revalidateOnFocus: false },
  );
  const taxonomySwr = useSWR("taxonomy:public", getPublicTaxonomy);

  if (error) {
    return (
      <div className="max-w-3xl mx-auto px-4 py-10">
        <div className="rounded-md bg-red-50 border border-red-200 p-3 text-sm text-red-700">
          {(error as Error).message || "Failed to load result"}
        </div>
      </div>
    );
  }
  if (!data) {
    return (
      <div className="max-w-3xl mx-auto px-4 py-10 text-slate-500">
        Loading…
      </div>
    );
  }

  if (data.status !== "submitted") {
    return (
      <div className="max-w-3xl mx-auto px-4 py-10">
        <p className="text-slate-600 mb-4">
          This quiz hasn't been submitted yet.
        </p>
        <Link
          href={`/quiz/attempt/${attemptId}?page=1`}
          className="px-4 py-2 rounded-md bg-blue-600 text-white text-sm"
        >
          Back to quiz
        </Link>
      </div>
    );
  }

  const correct = data.score_correct ?? 0;
  const total = data.score_total ?? data.question_ids.length;
  const answered = data.answers.length;
  // Incorrect = answered minus correct; skipped = total minus answered.
  // Both derived rather than fetched, since the existing payload already
  // carries enough information.
  const incorrect = Math.max(0, answered - correct);
  const skipped = Math.max(0, total - answered);
  const pct = total > 0 ? Math.round((correct / total) * 100) : 0;

  // Send the user back to the quiz they came from. We have drill_subject
  // and exam_type on the attempt; fall back to the quiz index if either
  // is missing (legacy attempts created before exam_type existed).
  const backHref =
    data.drill_subject && data.exam_type
      ? `/quizzes/${data.drill_subject}/${data.exam_type}`
      : "/quizzes";

  const handleDownloadPDF = () => {
    window.open(`/quiz/result/${attemptId}/print`, '_blank');
  };

  return (
    <div className="max-w-3xl mx-auto px-4 py-6 sm:py-12">
      <h1 className="text-xl sm:text-2xl font-semibold mb-2">Quiz result</h1>
      <p className="text-slate-600 text-sm mb-6 sm:mb-8">
        Submitted{" "}
        {data.submitted_at
          ? new Date(data.submitted_at).toLocaleString()
          : "—"}
      </p>

      <div className="rounded-lg border border-slate-200 bg-white p-5 sm:p-8 text-center mb-4">
        <div className="text-sm uppercase tracking-wide text-slate-500 mb-3">
          Your score
        </div>
        <div className="text-4xl sm:text-5xl lg:text-6xl font-semibold text-slate-900">
          {correct}
          <span className="text-slate-400"> / {total}</span>
        </div>
        <div className="mt-2 text-base sm:text-lg text-slate-600">{pct}%</div>
        <p className="mt-3 text-sm text-slate-600">
          You answered total {answered} {answered === 1 ? "question" : "questions"}{" "}
          out of {total}.
        </p>
      </div>

      <div className="grid grid-cols-3 gap-2 sm:gap-3 mb-6">
        <StatCard
          label="Correct"
          value={correct}
          tone="emerald"
        />
        <StatCard
          label="Incorrect"
          value={incorrect}
          tone="rose"
        />
        <StatCard
          label="Skipped"
          value={skipped}
          tone="slate"
        />
      </div>

      <ChapterBreakdown
        rows={reviewSwr.data}
        loading={!reviewSwr.data && !reviewSwr.error}
        error={reviewSwr.error as Error | undefined}
        subject={data.drill_subject}
        taxonomy={taxonomySwr.data}
      />

      <div className="flex flex-wrap gap-3">
        <Link
          href={`/quiz/review/${attemptId}?page=1`}
          className="px-5 py-2 rounded-md bg-blue-600 text-white text-sm"
        >
          Review answers
        </Link>
        <Link
          href={backHref}
          className="px-5 py-2 rounded-md border border-slate-300 text-sm text-slate-700"
        >
          Back to quiz
        </Link>
        <button
          onClick={handleDownloadPDF}
          className="px-5 py-2 rounded-md border border-slate-300 text-sm text-slate-700 hover:bg-slate-50"
        >
          Download PDF
        </button>
      </div>
    </div>
  );
}

interface ChapterRow {
  chapter: string;
  total: number;
  correct: number;
  incorrect: number;
  skipped: number;
}

function ChapterBreakdown({
  rows,
  loading,
  error,
  subject,
  taxonomy,
}: {
  rows: Array<{ chapter: string | null; correct: boolean; answered: boolean }> | undefined;
  loading: boolean;
  error: Error | undefined;
  subject: string | null;
  taxonomy: PublicTaxonomy | undefined;
}) {
  // Group + syllabus-sort the rows. Skip questions whose chapter is NULL
  // (legacy data); they don't belong to any chapter and would just show as
  // "Other" with no useful label.
  const breakdown: ChapterRow[] = useMemo(() => {
    if (!rows) return [];
    const byChapter = new Map<string, ChapterRow>();
    for (const r of rows) {
      if (!r.chapter) continue;
      let entry = byChapter.get(r.chapter);
      if (!entry) {
        entry = {
          chapter: r.chapter,
          total: 0,
          correct: 0,
          incorrect: 0,
          skipped: 0,
        };
        byChapter.set(r.chapter, entry);
      }
      entry.total += 1;
      if (!r.answered) entry.skipped += 1;
      else if (r.correct) entry.correct += 1;
      else entry.incorrect += 1;
    }
    const arr = Array.from(byChapter.values());
    // Sort by syllabus position so the breakdown matches the runner and
    // landing-page chapter orderings. Unknown chapters fall to the end.
    const syllabus = subject ? taxonomy?.flat?.[subject] ?? [] : [];
    const positionMap = new Map(syllabus.map((c, i) => [c, i]));
    arr.sort((a, b) => {
      const pa = positionMap.get(a.chapter) ?? Infinity;
      const pb = positionMap.get(b.chapter) ?? Infinity;
      return pa - pb;
    });
    return arr;
  }, [rows, subject, taxonomy]);

  if (loading) {
    return (
      <div className="rounded-lg border border-slate-200 bg-white p-4 mb-6 text-sm text-slate-500">
        Loading chapter breakdown…
      </div>
    );
  }
  if (error) {
    return (
      <div className="rounded-md bg-red-50 border border-red-200 p-3 text-sm text-red-700 mb-6">
        Couldn't load chapter breakdown: {error.message}
      </div>
    );
  }
  if (breakdown.length === 0) return null;

  return (
    <div className="rounded-lg border border-slate-200 bg-white mb-6 overflow-hidden">
      <div className="px-4 py-3 border-b border-slate-200">
        <h2 className="text-sm font-semibold text-slate-900">
          Chapter breakdown
        </h2>
        <p className="text-xs text-slate-500 mt-0.5">
          Only chapters that appeared in this attempt are listed.
        </p>
      </div>
      <ul className="divide-y divide-slate-100">
        {breakdown.map((row) => (
          <li
            key={row.chapter}
            className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-2 sm:gap-4 px-4 py-3 text-sm"
          >
            <div className="min-w-0 truncate font-medium text-slate-900">
              {subject
                ? chapterSerialLabel(taxonomy, subject, row.chapter)
                : row.chapter}
            </div>
            <div className="shrink-0 flex items-center flex-wrap gap-x-3 gap-y-1 text-xs">
              <span className="text-emerald-700">{row.correct} correct</span>
              <span className="text-rose-700">{row.incorrect} incorrect</span>
              {row.skipped > 0 && (
                <span className="text-slate-500">{row.skipped} skipped</span>
              )}
              <span className="text-slate-400 tabular-nums">
                {row.correct} / {row.total}
              </span>
            </div>
          </li>
        ))}
      </ul>
    </div>
  );
}

function StatCard({
  label,
  value,
  tone,
}: {
  label: string;
  value: number;
  tone: "emerald" | "rose" | "slate";
}) {
  const palette: Record<typeof tone, string> = {
    emerald: "border-emerald-200 bg-emerald-50 text-emerald-900",
    rose: "border-rose-200 bg-rose-50 text-rose-900",
    slate: "border-slate-200 bg-slate-50 text-slate-700",
  };
  return (
    <div className={`rounded-lg border ${palette[tone]} p-4 text-center`}>
      <div className="text-2xl font-semibold">{value}</div>
      <div className="text-xs uppercase tracking-wide mt-0.5 opacity-80">
        {label}
      </div>
    </div>
  );
}

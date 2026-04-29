"use client";

import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { use } from "react";
import useSWR from "swr";
import { MathText } from "@/components/MathText";
import {
  QuizReviewQuestion,
  adminGetAttempt,
  adminGetAttemptReview,
} from "@/lib/api";
import { questionSourceLine, stripImageTokens } from "@/lib/paperDisplay";

const PAGE_SIZE = 50;

export default function AdminAttemptReviewPage({
  params,
}: {
  params: Promise<{
    subject: string;
    exam_type: string;
    attemptId: string;
  }>;
}) {
  const { subject, exam_type, attemptId } = use(params);
  const router = useRouter();
  const search = useSearchParams();
  const page = Math.max(1, Number(search.get("page") || "1"));

  // Two reads: attempt summary (for the student identity strip) and a paged
  // slice of the review questions.
  const summary = useSWR(`admin:attempt:${attemptId}`, () =>
    adminGetAttempt(attemptId),
  );
  const review = useSWR(
    `admin:attempt:${attemptId}:review:${page}`,
    () => adminGetAttemptReview(attemptId, page, PAGE_SIZE),
    { revalidateOnFocus: false },
  );

  function goToPage(p: number) {
    router.push(
      `/admin/quizzes/${subject}/${exam_type}/attempts/${attemptId}?page=${p}`,
    );
  }

  if (review.error || summary.error) {
    return (
      <div className="max-w-3xl mx-auto px-4 py-10">
        <div className="rounded-md bg-red-50 border border-red-200 p-3 text-sm text-red-700">
          {(review.error ?? summary.error)?.message ||
            "Failed to load attempt"}
        </div>
      </div>
    );
  }
  if (!review.data || !summary.data) {
    return (
      <div className="max-w-3xl mx-auto px-4 py-10 text-slate-500">
        Loading…
      </div>
    );
  }

  const reviewData = review.data;
  const totalPages = Math.max(
    1,
    Math.ceil(reviewData.total / reviewData.page_size),
  );
  const att = summary.data;
  const score =
    att.score_correct != null && att.score_total != null
      ? `${att.score_correct} / ${att.score_total}`
      : att.status === "in_progress"
        ? "in progress"
        : "—";

  return (
    <div className="max-w-3xl mx-auto px-4 py-8">
      <Link
        href={`/admin/quizzes/${subject}/${exam_type}`}
        className="text-blue-600 text-sm mb-4 inline-block"
      >
        ← Back to quiz
      </Link>

      <div className="rounded-md border border-slate-200 bg-slate-50 p-4 mb-6 text-sm">
        <div className="font-medium text-slate-900">
          {att.user_display_name}
          <span className="text-slate-500 font-normal ml-2">
            ({att.user_email})
          </span>
        </div>
        <div className="text-xs text-slate-500 mt-0.5 font-mono">
          attempt {att.id.slice(0, 8)}
        </div>
        <div className="text-slate-600 mt-3 grid grid-cols-1 sm:grid-cols-3 gap-2">
          <div>
            <span className="text-slate-500">Started:</span>{" "}
            {new Date(att.started_at).toLocaleString()}
          </div>
          <div>
            <span className="text-slate-500">Submitted:</span>{" "}
            {att.submitted_at
              ? new Date(att.submitted_at).toLocaleString()
              : "—"}
          </div>
          <div>
            <span className="text-slate-500">Score:</span> {score}
          </div>
        </div>
      </div>

      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-xl font-semibold">Per-question review</h1>
          <p className="text-xs text-slate-500 mt-0.5">
            Page {page} of {totalPages} · {reviewData.total} questions total
          </p>
        </div>
      </div>

      <ol
        className="space-y-6"
        start={(page - 1) * reviewData.page_size + 1}
      >
        {reviewData.items.map((q, idx) => (
          <ReviewCard
            key={q.id}
            displayNumber={(page - 1) * reviewData.page_size + idx + 1}
            q={q}
          />
        ))}
      </ol>

      <div className="mt-8 flex items-center justify-between">
        <button
          disabled={page <= 1}
          onClick={() => goToPage(page - 1)}
          className="px-3 py-1.5 rounded-md border border-slate-300 text-sm disabled:opacity-40"
        >
          ← Previous
        </button>
        <button
          disabled={page >= totalPages}
          onClick={() => goToPage(page + 1)}
          className="px-3 py-1.5 rounded-md border border-slate-300 text-sm disabled:opacity-40"
        >
          Next →
        </button>
      </div>
    </div>
  );
}

// Same render as the student review card. Kept inline rather than
// factored out — it's small, and the two pages have slightly different
// surrounding context that argues against a shared component for now.
function ReviewCard({
  displayNumber,
  q,
}: {
  displayNumber: number;
  q: QuizReviewQuestion;
}) {
  const correct = q.correct_answer;
  const skipped = q.selected_label == null;
  return (
    <li
      className={`rounded-lg border p-4 ${
        skipped
          ? "border-slate-200 bg-slate-50"
          : q.is_correct
            ? "border-emerald-200 bg-emerald-50/40"
            : "border-rose-200 bg-rose-50/40"
      }`}
    >
      <div className="flex items-baseline justify-between gap-2 mb-1">
        <div className="text-sm font-medium text-slate-700">
          {displayNumber}.
        </div>
        <div className="text-[11px] uppercase tracking-wide">
          {skipped ? (
            <span className="text-slate-500">Skipped</span>
          ) : q.is_correct ? (
            <span className="text-emerald-700">Correct</span>
          ) : (
            <span className="text-rose-700">Incorrect</span>
          )}
        </div>
      </div>
      <div className="text-[11px] text-slate-500 mb-2 break-anywhere">
        {questionSourceLine(q)}
      </div>
      <div className="prose prose-sm max-w-none mb-3">
        <MathText
          text={q.question_text}
          images={q.images}
          paperId={q.paper_id}
        />
      </div>
      <div className="space-y-1.5">
        {q.options.map((o) => {
          const isCorrect = correct != null && o.label === correct;
          const isPicked =
            q.selected_label != null && o.label === q.selected_label;
          let cls = "border-slate-200 bg-white";
          if (isCorrect) {
            cls = "border-emerald-400 bg-emerald-50";
          } else if (isPicked && !isCorrect) {
            cls = "border-rose-400 bg-rose-50";
          }
          return (
            <div
              key={o.label}
              className={`flex gap-3 items-start rounded-md px-3 py-2 border ${cls}`}
            >
              <span className="text-sm font-medium w-5 shrink-0">
                {o.label}.
              </span>
              <span className="text-sm flex-1">
                <MathText
                  text={o.image_filename ? stripImageTokens(o.text) : o.text}
                  images={q.images}
                  paperId={q.paper_id}
                  imageClassName="inline-block h-24 w-auto max-w-full object-contain my-1 border border-slate-200 rounded"
                />
                {o.image_filename ? (
                  <img
                    src={`${process.env.NEXT_PUBLIC_API_BASE_URL || "http://localhost:8000"}/exams/${q.paper_id}/images/${o.image_filename}`}
                    alt=""
                    className="mt-2 h-24 w-auto max-w-full object-contain"
                  />
                ) : null}
              </span>
              <span className="text-[11px] uppercase tracking-wide shrink-0 mt-0.5">
                {isCorrect ? (
                  <span className="text-emerald-700">Correct</span>
                ) : isPicked ? (
                  <span className="text-rose-700">Student answer</span>
                ) : null}
              </span>
            </div>
          );
        })}
      </div>
      {(q.solution || q.gemini_solution) && (
        <>
          {q.solution && (
            <details className="mt-3 group" open={!q.is_correct && !skipped}>
              <summary className="cursor-pointer text-xs uppercase tracking-wide text-slate-500 group-hover:text-slate-700">
                Solution
              </summary>
              <div className="prose prose-sm max-w-none mt-2 text-slate-700">
                <MathText
                  text={q.solution}
                  images={q.images}
                  paperId={q.paper_id}
                />
              </div>
            </details>
          )}
          {q.gemini_solution && (
            <details className="mt-3 group" open={!q.is_correct && !skipped}>
              <summary className="cursor-pointer text-xs uppercase tracking-wide text-blue-600 group-hover:text-blue-700 flex items-center gap-1">
                <span>Gemini Solution</span>
                <span className="text-[9px] px-1 py-0.5 rounded bg-blue-100 text-blue-700">AI</span>
              </summary>
              <div className="prose prose-sm max-w-none mt-2 text-slate-700 bg-blue-50/30 border border-blue-100 rounded-lg p-3">
                <MathText
                  text={q.gemini_solution}
                  images={q.images}
                  paperId={q.paper_id}
                />
              </div>
            </details>
          )}
        </>
      )}
    </li>
  );
}

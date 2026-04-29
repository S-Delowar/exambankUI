"use client";

import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { use } from "react";
import useSWR from "swr";
import RequireAuth from "@/components/RequireAuth";
import { MathText } from "@/components/MathText";
import {
  AttemptDetail,
  PublicTaxonomy,
  QuizReviewQuestion,
  getAttempt,
  getAttemptReview,
  getPublicTaxonomy,
} from "@/lib/api";
import { chapterDisplayName } from "@/lib/chapterLabel";
import { questionSourceLine, stripImageTokens } from "@/lib/paperDisplay";

const PAGE_SIZE = 50;

export default function ReviewPage(props: {
  params: Promise<{ attemptId: string }>;
}) {
  return (
    <RequireAuth>
      <ReviewPageInner {...props} />
    </RequireAuth>
  );
}

function ReviewPageInner({
  params,
}: {
  params: Promise<{ attemptId: string }>;
}) {
  const { attemptId } = use(params);
  const router = useRouter();
  const search = useSearchParams();
  const page = Math.max(1, Number(search.get("page") || "1"));

  const { data, error } = useSWR(
    `attempt:${attemptId}:review:${page}`,
    () => getAttemptReview(attemptId, page, PAGE_SIZE),
    { revalidateOnFocus: false },
  );
  // Need the attempt to know which subject to look chapter labels up under,
  // and the taxonomy to translate keys to Bangla.
  const detailSwr = useSWR<AttemptDetail>(
    `attempt:${attemptId}`,
    () => getAttempt(attemptId),
    { revalidateOnFocus: false },
  );
  const taxonomySwr = useSWR("taxonomy:public", getPublicTaxonomy);

  function goToPage(p: number) {
    router.push(`/quiz/review/${attemptId}?page=${p}`);
  }

  if (error) {
    return (
      <div className="max-w-3xl mx-auto px-4 py-10">
        <div className="rounded-md bg-red-50 border border-red-200 p-3 text-sm text-red-700">
          {(error as Error).message || "Failed to load review"}
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

  const totalPages = Math.max(1, Math.ceil(data.total / data.page_size));

  return (
    <div className="max-w-3xl mx-auto px-4 py-4 sm:py-8">
      <div className="flex items-center justify-between gap-3 mb-6">
        <div className="min-w-0">
          <h1 className="text-lg sm:text-xl font-semibold truncate">Review answers</h1>
          <p className="text-xs text-slate-500 mt-0.5">
            Page {page} of {totalPages} · {data.total} questions total
          </p>
        </div>
        <Link
          href={`/quiz/result/${attemptId}`}
          className="text-sm text-slate-500 hover:text-slate-700"
        >
          ← Back to result
        </Link>
      </div>

      <ReviewList
        items={data.items}
        pageOffset={(page - 1) * data.page_size}
        subject={detailSwr.data?.drill_subject ?? null}
        taxonomy={taxonomySwr.data}
      />

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

function ReviewList({
  items,
  pageOffset,
  subject,
  taxonomy,
}: {
  items: QuizReviewQuestion[];
  pageOffset: number;
  subject: string | null;
  taxonomy: PublicTaxonomy | undefined;
}) {
  // Walk the page's items, inserting a chapter chip whenever the chapter
  // changes. displayNumber is global across the whole quiz (pageOffset +
  // local idx + 1), independent of chapter sectioning.
  let prev: string | null | undefined = undefined;
  const elements: React.ReactNode[] = [];
  items.forEach((q, idx) => {
    if (q.chapter !== prev) {
      elements.push(
        <ChapterHeader
          key={`chapter-${pageOffset + idx}`}
          chapter={q.chapter}
          subject={subject}
          taxonomy={taxonomy}
        />,
      );
      prev = q.chapter;
    }
    elements.push(
      <ReviewCard key={q.id} displayNumber={pageOffset + idx + 1} q={q} />,
    );
  });
  return <ul className="space-y-4">{elements}</ul>;
}

function ChapterHeader({
  chapter,
  subject,
  taxonomy,
}: {
  chapter: string | null;
  subject: string | null;
  taxonomy: PublicTaxonomy | undefined;
}) {
  // Same chip styling as the quiz runner so the two pages feel coherent.
  const name =
    chapter && subject ? chapterDisplayName(taxonomy, subject, chapter) : null;
  return (
    <li className="pt-6 pb-2 first:pt-0 flex justify-center">
      <span className="inline-flex items-center rounded-full bg-blue-100 text-blue-900 px-4 py-1.5 text-base font-semibold">
        {name ? `অধ্যায়: ${name}` : "Other"}
      </span>
    </li>
  );
}

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
          const isPicked = q.selected_label != null && o.label === q.selected_label;
          let cls =
            "border-slate-200 bg-white";
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
                  <span className="text-rose-700">Your answer</span>
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

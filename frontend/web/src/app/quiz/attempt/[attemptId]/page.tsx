"use client";

import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { use, useCallback, useEffect, useMemo, useState } from "react";
import useSWR from "swr";
import RequireAuth from "@/components/RequireAuth";
import { MathText } from "@/components/MathText";
import {
  AttemptDetail,
  PublicTaxonomy,
  QuizPublicQuestion,
  getAttempt,
  getAttemptQuestions,
  getPublicTaxonomy,
  recordAttemptAnswer,
  submitAttempt,
} from "@/lib/api";
import { chapterDisplayName } from "@/lib/chapterLabel";
import { questionSourceLine, stripImageTokens } from "@/lib/paperDisplay";

const PAGE_SIZE = 50;

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

function subjectLabel(subject: string | null | undefined): string {
  if (!subject) return "Quiz";
  return (
    SUBJECT_LABELS[subject] ??
    subject
      .split("_")
      .map((s) => s.charAt(0).toUpperCase() + s.slice(1))
      .join(" ")
  );
}

export default function AttemptPage(props: {
  params: Promise<{ attemptId: string }>;
}) {
  return (
    <RequireAuth>
      <AttemptPageInner {...props} />
    </RequireAuth>
  );
}

function AttemptPageInner({
  params,
}: {
  params: Promise<{ attemptId: string }>;
}) {
  const { attemptId } = use(params);
  const router = useRouter();
  const search = useSearchParams();
  const page = Math.max(1, Number(search.get("page") || "1"));

  // Attempt detail tells us total + which questions are already answered.
  const detailSwr = useSWR<AttemptDetail>(
    attemptId && `attempt:${attemptId}`,
    () => getAttempt(attemptId),
    { revalidateOnFocus: false },
  );

  const questionsSwr = useSWR(
    attemptId && `attempt:${attemptId}:questions:${page}`,
    () => getAttemptQuestions(attemptId, page, PAGE_SIZE),
    { revalidateOnFocus: false },
  );

  // Taxonomy is small and cacheable across pages — used by ChapterHeader to
  // render Bangla label + 1-based syllabus serial. SWR's default dedup
  // window keeps this to one request per session.
  const taxonomySwr = useSWR("taxonomy:public", getPublicTaxonomy);

  const detail = detailSwr.data;
  const data = questionsSwr.data;
  const taxonomy = taxonomySwr.data;

  // If the attempt is already submitted, jump to the result page.
  useEffect(() => {
    if (detail && detail.status === "submitted") {
      router.replace(`/quiz/result/${attemptId}`);
    }
  }, [detail, attemptId, router]);

  const totalPages = useMemo(() => {
    if (!data) return 1;
    return Math.max(1, Math.ceil(data.total / data.page_size));
  }, [data]);

  // Map of question_id -> currently-selected label, hydrated from server-side
  // attempt detail and updated optimistically when the user clicks.
  const [selected, setSelected] = useState<Record<string, string>>({});
  useEffect(() => {
    if (!detail) return;
    const m: Record<string, string> = {};
    for (const a of detail.answers) m[a.question_id] = a.selected_label;
    setSelected(m);
  }, [detail]);

  const [savingId, setSavingId] = useState<string | null>(null);
  const [submitError, setSubmitError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [confirmOpen, setConfirmOpen] = useState(false);

  const onSelect = useCallback(
    async (questionId: string, label: string) => {
      setSelected((s) => ({ ...s, [questionId]: label }));
      setSavingId(questionId);
      try {
        await recordAttemptAnswer(attemptId, questionId, label);
      } catch (err) {
        console.error("save answer failed", err);
      } finally {
        setSavingId((cur) => (cur === questionId ? null : cur));
      }
    },
    [attemptId],
  );

  function goToPage(p: number) {
    router.push(`/quiz/attempt/${attemptId}?page=${p}`);
  }

  async function doSubmit() {
    setSubmitting(true);
    setSubmitError(null);
    try {
      await submitAttempt(attemptId);
      router.replace(`/quiz/result/${attemptId}`);
    } catch (err) {
      setSubmitError(err instanceof Error ? err.message : "Submit failed");
      setSubmitting(false);
      setConfirmOpen(false);
    }
  }

  if (questionsSwr.error || detailSwr.error) {
    const err =
      (questionsSwr.error || detailSwr.error) as Error | undefined;
    return (
      <div className="max-w-3xl mx-auto px-4 py-10">
        <div className="rounded-md bg-red-50 border border-red-200 p-3 text-sm text-red-700">
          {err?.message || "Failed to load"}
        </div>
      </div>
    );
  }

  if (!data || !detail) {
    return (
      <div className="max-w-3xl mx-auto px-4 py-10 text-slate-500">
        Loading…
      </div>
    );
  }

  const isLastPage = page >= totalPages;
  const answeredCount = Object.keys(selected).length;
  const unansweredCount = data.total - answeredCount;
  const exitHref =
    detail.drill_subject && detail.exam_type
      ? `/quizzes/${detail.drill_subject}/${detail.exam_type}`
      : "/quizzes";

  // Walk the page's items, inserting a chapter header whenever the chapter
  // changes. Each question's `displayNumber` is the global serial (page
  // offset + index + 1), independent of chapters — chapters only affect
  // visual grouping.
  const pageOffset = (page - 1) * data.page_size;
  let prevChapter: string | null | undefined = undefined;
  const renderItems: React.ReactNode[] = [];
  data.items.forEach((q, idx) => {
    if (q.chapter !== prevChapter) {
      renderItems.push(
        <ChapterHeader
          key={`chapter-${pageOffset + idx}`}
          chapter={q.chapter}
          subject={detail.drill_subject}
          taxonomy={taxonomy}
        />,
      );
      prevChapter = q.chapter;
    }
    renderItems.push(
      <QuestionCard
        key={q.id}
        displayNumber={pageOffset + idx + 1}
        question={q}
        selected={selected[q.id]}
        saving={savingId === q.id}
        onSelect={(label) => onSelect(q.id, label)}
      />,
    );
  });

  return (
    <div className="max-w-3xl mx-auto px-4 py-4 sm:py-8">
      <div className="flex items-center justify-between gap-3 mb-6">
        <div className="min-w-0">
          <h1 className="text-lg sm:text-xl font-semibold truncate">
            {subjectLabel(detail.drill_subject)} quiz
          </h1>
          <p className="text-xs text-slate-500 mt-0.5">
            Page {page} of {totalPages} · {answeredCount} / {data.total}{" "}
            answered
          </p>
        </div>
        <Link
          href={exitHref}
          className="text-sm text-slate-500 hover:text-slate-700"
        >
          ← Exit
        </Link>
      </div>

      <ul className="space-y-4">{renderItems}</ul>

      {submitError && (
        <div className="mt-6 rounded-md bg-red-50 border border-red-200 p-3 text-sm text-red-700">
          {submitError}
        </div>
      )}

      <div className="mt-8 flex flex-wrap items-center justify-between gap-3">
        <div className="flex items-center gap-2">
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

        {isLastPage ? (
          <button
            onClick={() => setConfirmOpen(true)}
            disabled={submitting}
            className="px-5 py-2 rounded-md bg-green-600 text-white text-sm font-medium hover:bg-green-700 disabled:opacity-50"
          >
            {submitting ? "Submitting…" : "Submit quiz"}
          </button>
        ) : (
          <div className="text-xs text-slate-500">
            Submit appears on the last page.
          </div>
        )}
      </div>

      <PageStrip totalPages={totalPages} page={page} onGo={goToPage} />

      <SubmitModal
        open={confirmOpen}
        onClose={() => !submitting && setConfirmOpen(false)}
        onConfirm={doSubmit}
        submitting={submitting}
        answeredCount={answeredCount}
        totalCount={data.total}
        unansweredCount={unansweredCount}
      />
    </div>
  );
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
  // Centered chapter "chip" with `অধ্যায়:` prefix. No serial number — the
  // serial belongs on the landing page's chapter list, not on the runner
  // section header where it adds visual noise. Background wraps just the
  // text by virtue of `inline-flex` + `px/py`, not the full row.
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

function QuestionCard({
  displayNumber,
  question,
  selected,
  saving,
  onSelect,
}: {
  displayNumber: number;
  question: QuizPublicQuestion;
  selected: string | undefined;
  saving: boolean;
  onSelect: (label: string) => void;
}) {
  return (
    <li className="rounded-lg border border-slate-200 bg-white p-4">
      <div className="flex items-baseline justify-between gap-2 mb-1">
        <div className="text-sm font-medium text-slate-700">
          {displayNumber}.
        </div>
        {saving ? (
          <div className="text-[10px] uppercase text-slate-400">Saving…</div>
        ) : selected ? (
          <div className="text-[10px] uppercase text-emerald-600">Saved</div>
        ) : null}
      </div>
      <div className="prose prose-sm max-w-none mb-3">
        <MathText
          text={question.question_text}
          images={question.images}
          paperId={question.paper_id}
        />
      </div>
      <div className="space-y-1.5">
        {question.options.map((o) => {
          const checked = selected === o.label;
          return (
            <label
              key={o.label}
              className={`flex gap-3 items-start cursor-pointer rounded-md px-3 py-2 border ${
                checked
                  ? "border-blue-500 bg-blue-50"
                  : "border-slate-200 hover:border-slate-300"
              }`}
            >
              <input
                type="radio"
                name={`q-${question.id}`}
                checked={checked}
                onChange={() => onSelect(o.label)}
                className="mt-1"
              />
              <span className="text-sm font-medium w-5 shrink-0">
                {o.label}.
              </span>
              <span className="text-sm flex-1">
                <MathText
                  text={o.image_filename ? stripImageTokens(o.text) : o.text}
                  images={question.images}
                  paperId={question.paper_id}
                  imageClassName="inline-block h-24 w-auto max-w-full object-contain my-1 border border-slate-200 rounded"
                />
                {o.image_filename ? (
                  <img
                    src={`${process.env.NEXT_PUBLIC_API_BASE_URL || "http://localhost:8000"}/exams/${question.paper_id}/images/${o.image_filename}`}
                    alt=""
                    className="mt-2 h-24 w-auto max-w-full object-contain"
                  />
                ) : null}
              </span>
            </label>
          );
        })}
      </div>
    </li>
  );
}

function PageStrip({
  totalPages,
  page,
  onGo,
}: {
  totalPages: number;
  page: number;
  onGo: (p: number) => void;
}) {
  if (totalPages <= 1) return null;
  return (
    <div className="mt-4 flex flex-wrap gap-1 text-xs">
      {Array.from({ length: totalPages }, (_, i) => i + 1).map((p) => (
        <button
          key={p}
          onClick={() => onGo(p)}
          className={`min-w-7 px-2 py-1 rounded border ${
            p === page
              ? "border-blue-500 bg-blue-500 text-white"
              : "border-slate-200 text-slate-700 hover:border-slate-300"
          }`}
        >
          {p}
        </button>
      ))}
    </div>
  );
}

function SubmitModal({
  open,
  onClose,
  onConfirm,
  submitting,
  answeredCount,
  totalCount,
  unansweredCount,
}: {
  open: boolean;
  onClose: () => void;
  onConfirm: () => void;
  submitting: boolean;
  answeredCount: number;
  totalCount: number;
  unansweredCount: number;
}) {
  // Lock background scroll while the modal is open and close on Escape.
  useEffect(() => {
    if (!open) return;
    const prev = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape" && !submitting) onClose();
    };
    document.addEventListener("keydown", onKey);
    return () => {
      document.body.style.overflow = prev;
      document.removeEventListener("keydown", onKey);
    };
  }, [open, submitting, onClose]);

  if (!open) return null;

  const pct = totalCount > 0 ? Math.round((answeredCount / totalCount) * 100) : 0;
  const allAnswered = unansweredCount === 0;

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center px-4"
      role="dialog"
      aria-modal="true"
      aria-labelledby="submit-modal-title"
    >
      {/* Backdrop */}
      <div
        className="absolute inset-0 bg-slate-900/50 backdrop-blur-sm"
        onClick={() => !submitting && onClose()}
      />

      {/* Card */}
      <div className="relative w-full max-w-md rounded-xl bg-white shadow-xl border border-slate-200 overflow-hidden">
        <div className="px-6 pt-6 pb-4">
          <h2
            id="submit-modal-title"
            className="text-lg font-semibold text-slate-900 mb-1"
          >
            Submit your quiz?
          </h2>
          <p className="text-sm text-slate-600">
            Once submitted, you won't be able to change any answers.
          </p>
        </div>

        <div className="px-6 pb-5 space-y-3">
          <div>
            <div className="flex items-baseline justify-between text-sm mb-1.5">
              <span className="text-slate-700 font-medium">Progress</span>
              <span className="text-slate-500">
                {answeredCount} of {totalCount} answered
              </span>
            </div>
            <div className="h-2 w-full rounded-full bg-slate-100 overflow-hidden">
              <div
                className={`h-full transition-all ${
                  allAnswered ? "bg-emerald-500" : "bg-blue-500"
                }`}
                style={{ width: `${pct}%` }}
              />
            </div>
          </div>

          {!allAnswered && (
            <div className="rounded-md bg-amber-50 border border-amber-200 px-3 py-2 text-sm text-amber-800">
              <span className="font-medium">{unansweredCount}</span>{" "}
              {unansweredCount === 1 ? "question is" : "questions are"} still
              unanswered. They'll count as skipped.
            </div>
          )}
        </div>

        <div className="bg-slate-50 border-t border-slate-200 px-6 py-3 flex items-center justify-end gap-2">
          <button
            type="button"
            onClick={onClose}
            disabled={submitting}
            className="px-4 py-2 rounded-md text-sm font-medium text-slate-700 hover:bg-slate-200 disabled:opacity-50"
          >
            Cancel
          </button>
          <button
            type="button"
            onClick={onConfirm}
            disabled={submitting}
            className="px-4 py-2 rounded-md bg-green-600 hover:bg-green-700 text-white text-sm font-medium disabled:opacity-50 inline-flex items-center gap-2"
          >
            {submitting ? (
              <>
                <span className="inline-block h-3 w-3 border-2 border-white/40 border-t-white rounded-full animate-spin" />
                Submitting…
              </>
            ) : (
              "Submit quiz"
            )}
          </button>
        </div>
      </div>
    </div>
  );
}

"use client";

import Link from "next/link";
import { use, useMemo, useState } from "react";
import useSWR from "swr";
import { getPaper, listQuestions } from "@/lib/api";
import { PdfPane } from "@/components/PdfPane";
import {
  AdmissionMcqCard,
  AdmissionWrittenCard,
  HscMcqCard,
  HscWrittenCard,
} from "@/components/QuestionCards";
import {
  examTypeLabel,
  paperTitle,
  questionTypeLabel,
} from "@/lib/paperDisplay";
import { prettySubject } from "@/lib/subjects";
import type {
  AdmissionMcqQuestion,
  AdmissionWrittenQuestion,
  AnyQuestion,
  ExamPaperDetail,
  HscMcqQuestion,
  HscWrittenQuestion,
  QuestionListResponse,
} from "@/types/exam";
import RequireAuth from "@/components/RequireAuth";

// Group questions by their `subject` field. HSC written questions always have
// a fixed subject from the paper; admission papers can carry multiple.
function groupBySubject(qs: AnyQuestion[]): Map<string, AnyQuestion[]> {
  const out = new Map<string, AnyQuestion[]>();
  for (const q of qs) {
    const key = ("subject" in q && q.subject) || "unknown";
    if (!out.has(key)) out.set(key, []);
    out.get(key)!.push(q);
  }
  // Stable sort subjects alphabetically, with `unknown` last.
  return new Map(
    [...out.entries()].sort((a, b) => {
      if (a[0] === "unknown") return 1;
      if (b[0] === "unknown") return -1;
      return a[0].localeCompare(b[0]);
    }),
  );
}

export default function ReviewPage(props: {
  params: Promise<{ paperId: string }>;
}) {
  return (
    <RequireAuth adminOnly>
      <ReviewPageInner {...props} />
    </RequireAuth>
  );
}

function ReviewPageInner({
  params,
}: {
  // Next.js 15 upgraded dynamic route params to a Promise.
  params: Promise<{ paperId: string }>;
}) {
  const { paperId } = use(params);

  const paperSwr = useSWR<ExamPaperDetail>(
    paperId && `paper:${paperId}`,
    () => getPaper(paperId),
  );
  const questionsSwr = useSWR<QuestionListResponse>(
    paperId && `questions:${paperId}`,
    () => listQuestions({ paper_id: paperId, limit: 500 }),
  );

  const paper = paperSwr.data;
  const questions = questionsSwr.data?.items ?? [];
  const grouped = useMemo(() => groupBySubject(questions), [questions]);

  // On mobile, show one pane at a time (PDF or Questions). On lg+ both panes
  // appear side-by-side and this tab state is ignored.
  const [mobileTab, setMobileTab] = useState<"pdf" | "questions">("questions");

  const mutateQuestions = (updater: (prev: AnyQuestion[]) => AnyQuestion[]) => {
    questionsSwr.mutate(
      (cur) =>
        cur
          ? { total: cur.total, items: updater(cur.items) }
          : cur,
      { revalidate: false },
    );
  };

  if (paperSwr.error) {
    return (
      <div className="max-w-3xl mx-auto px-4 py-10">
        <div className="rounded-md bg-red-50 border border-red-200 p-3 text-sm text-red-700">
          {(paperSwr.error as Error).message}
        </div>
      </div>
    );
  }
  if (!paper) {
    return <div className="max-w-3xl mx-auto px-4 py-10">Loading…</div>;
  }

  const ctx = {
    examType: paper.exam_type,
    questionType: paper.question_type,
    mutate: mutateQuestions,
  };

  const renderCard = (q: AnyQuestion) => {
    if (paper.exam_type === "admission_test" && paper.question_type === "mcq") {
      return (
        <AdmissionMcqCard
          key={q.id}
          q={q as AdmissionMcqQuestion}
          ctx={ctx}
        />
      );
    }
    if (paper.exam_type === "admission_test" && paper.question_type === "written") {
      return (
        <AdmissionWrittenCard
          key={q.id}
          q={q as AdmissionWrittenQuestion}
          ctx={ctx}
        />
      );
    }
    if (paper.exam_type === "hsc_board" && paper.question_type === "mcq") {
      return <HscMcqCard key={q.id} q={q as HscMcqQuestion} ctx={ctx} />;
    }
    return <HscWrittenCard key={q.id} q={q as HscWrittenQuestion} ctx={ctx} />;
  };

  return (
    <div className="h-[calc(100vh-3.5rem)] flex flex-col">
      <div className="border-b border-slate-200 bg-white px-4 py-3">
        <div className="max-w-[1800px] mx-auto flex flex-col sm:flex-row sm:items-center sm:justify-between gap-2 sm:gap-4">
          <div className="min-w-0">
            <div className="flex items-center gap-2 text-xs text-slate-500 mb-1">
              <Link href="/admin/jobs" className="hover:underline">
                ← Jobs
              </Link>
              <span>/</span>
              <span className="truncate">{paper.source_filename}</span>
            </div>
            <h1 className="text-base sm:text-lg font-semibold truncate">
              {paperTitle(paper)}
            </h1>
          </div>
          <div className="flex items-center flex-wrap gap-2 text-xs">
            <span className="px-2 py-0.5 rounded-full bg-slate-100 text-slate-700">
              {examTypeLabel(paper.exam_type)}
            </span>
            <span className="px-2 py-0.5 rounded-full bg-slate-100 text-slate-700">
              {questionTypeLabel(paper.question_type)}
            </span>
            <span className="text-slate-500">
              {paper.question_count} questions
            </span>
          </div>
        </div>
      </div>

      <div className="lg:hidden border-b border-slate-200 bg-white px-4 flex gap-1">
        <button
          type="button"
          onClick={() => setMobileTab("pdf")}
          className={`px-3 py-2 text-sm border-b-2 -mb-px ${
            mobileTab === "pdf"
              ? "border-blue-600 text-blue-700 font-medium"
              : "border-transparent text-slate-600"
          }`}
        >
          PDF
        </button>
        <button
          type="button"
          onClick={() => setMobileTab("questions")}
          className={`px-3 py-2 text-sm border-b-2 -mb-px ${
            mobileTab === "questions"
              ? "border-blue-600 text-blue-700 font-medium"
              : "border-transparent text-slate-600"
          }`}
        >
          Questions
        </button>
      </div>

      <div className="flex-1 min-h-0 grid grid-cols-1 lg:grid-cols-2">
        <div
          className={`lg:border-r border-slate-200 h-full lg:min-h-[400px] ${
            mobileTab === "pdf" ? "block" : "hidden lg:block"
          }`}
        >
          <PdfPane paperId={paper.id} hasSourcePdf={paper.has_source_pdf} />
        </div>

        <div
          className={`h-full overflow-auto ${
            mobileTab === "questions" ? "block" : "hidden lg:block"
          }`}
        >
          <div className="max-w-3xl mx-auto p-4 space-y-8">
            {questionsSwr.isLoading && (
              <p className="text-slate-500 text-sm">Loading questions…</p>
            )}
            {questionsSwr.error && (
              <div className="rounded-md bg-red-50 border border-red-200 p-3 text-sm text-red-700">
                {(questionsSwr.error as Error).message}
              </div>
            )}
            {!questionsSwr.isLoading && questions.length === 0 && (
              <p className="text-slate-500 text-sm">
                No questions saved for this paper.
              </p>
            )}

            {[...grouped.entries()].map(([subject, qs]) => (
              <section key={subject}>
                <h2 className="text-sm font-semibold uppercase tracking-wide text-slate-500 mb-3">
                  {prettySubject(subject)} ({qs.length})
                </h2>
                <div className="space-y-4">
                  {qs.map((q) => (
                    <QuestionFrame key={q.id}>{renderCard(q)}</QuestionFrame>
                  ))}
                </div>
              </section>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

// Small wrapper that can later host per-question sidebar controls. Keeping
// it as a separate component makes the review page read-only clean.
function QuestionFrame({ children }: { children: React.ReactNode }) {
  return <div>{children}</div>;
}


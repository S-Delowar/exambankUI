"use client";

import Link from "next/link";
import { use, useState } from "react";
import useSWR from "swr";
import {
  AdminRosterEntry,
  adminListQuizAttempts,
  adminListQuizzes,
  getPublicTaxonomy,
  listQuestions,
} from "@/lib/api";
import { chapterSerialLabel } from "@/lib/chapterLabel";
import { MathText } from "@/components/MathText";
import type {
  AdmissionMcqQuestion,
  ExamType,
  HscMcqQuestion,
} from "@/types/exam";

// Narrow union for the rows on this page — the upstream listQuestions call
// pins question_type='mcq', so HSC/Admission written can't appear.
type McqQuestion = AdmissionMcqQuestion | HscMcqQuestion;

const EXAM_TYPE_LABELS: Record<string, string> = {
  admission_test: "Admission",
  hsc_board: "HSC Board",
};

function subjectLabel(subject: string): string {
  return subject
    .split("_")
    .map((s) => s.charAt(0).toUpperCase() + s.slice(1))
    .join(" ");
}

export default function AdminQuizDetailPage({
  params,
}: {
  params: Promise<{ subject: string; exam_type: string }>;
}) {
  const { subject, exam_type } = use(params);
  if (exam_type !== "admission_test" && exam_type !== "hsc_board") {
    return (
      <div className="max-w-5xl mx-auto px-4 py-10">
        <p className="text-red-700">Unknown exam type: {exam_type}</p>
      </div>
    );
  }
  return <Inner subject={subject} examType={exam_type as ExamType} />;
}

type Tab = "questions" | "submissions";

function Inner({ subject, examType }: { subject: string; examType: ExamType }) {
  const [tab, setTab] = useState<Tab>("questions");

  // Header data: pull from /admin/quizzes so we see title + counts + status
  // without an extra endpoint.
  const allQuizzes = useSWR("admin:quizzes", adminListQuizzes);
  const quiz = allQuizzes.data?.quizzes.find(
    (q) => q.subject === subject && q.exam_type === examType,
  );

  return (
    <div className="max-w-5xl mx-auto px-4 py-6 sm:py-10">
      <Link
        href="/admin/quizzes"
        className="text-blue-600 text-sm mb-4 inline-block"
      >
        ← All quizzes
      </Link>
      <div className="flex flex-wrap items-baseline gap-x-3 gap-y-2 mb-1">
        <h1 className="text-xl sm:text-2xl font-semibold">
          {subjectLabel(subject)}{" "}
          <span className="text-slate-500 text-base font-normal">
            — {EXAM_TYPE_LABELS[examType]}
          </span>
        </h1>
        {quiz ? (
          <span
            className={`inline-block px-2 py-0.5 rounded-full text-xs ${
              quiz.status === "published"
                ? "bg-green-100 text-green-800"
                : quiz.status === "archived"
                  ? "bg-amber-100 text-amber-900"
                  : "bg-slate-100 text-slate-700"
            }`}
          >
            {quiz.status}
          </span>
        ) : null}
      </div>
      <p className="text-slate-600 text-sm mb-6">
        {quiz
          ? `${quiz.total_questions} questions · ${quiz.attempts_total} attempts (${quiz.attempts_in_progress} in progress)`
          : "Loading…"}
      </p>

      <div className="border-b border-slate-200 mb-6 flex gap-6 text-sm overflow-x-auto">
        <TabButton active={tab === "questions"} onClick={() => setTab("questions")}>
          Questions
        </TabButton>
        <TabButton
          active={tab === "submissions"}
          onClick={() => setTab("submissions")}
        >
          Submissions
        </TabButton>
      </div>

      {tab === "questions" ? (
        <QuestionsTab subject={subject} examType={examType} />
      ) : (
        <SubmissionsTab subject={subject} examType={examType} />
      )}
    </div>
  );
}

function TabButton({
  active,
  onClick,
  children,
}: {
  active: boolean;
  onClick: () => void;
  children: React.ReactNode;
}) {
  return (
    <button
      onClick={onClick}
      className={`pb-2 -mb-px border-b-2 transition ${
        active
          ? "border-blue-600 text-slate-900 font-medium"
          : "border-transparent text-slate-500 hover:text-slate-900"
      }`}
    >
      {children}
    </button>
  );
}

// ---------------------------------------------------------------------------
// Questions tab
// ---------------------------------------------------------------------------

function QuestionsTab({
  subject,
  examType,
}: {
  subject: string;
  examType: ExamType;
}) {
  const data = useSWR(`admin:questions:${subject}:${examType}`, () =>
    listQuestions({
      exam_type: examType,
      question_type: "mcq",
      subject,
      limit: 500,
    }),
  );
  const taxonomy = useSWR("taxonomy:public", getPublicTaxonomy);

  if (data.error) {
    return (
      <p className="text-red-700">
        Failed to load questions: {data.error.message}
      </p>
    );
  }
  if (!data.data) {
    return <p className="text-slate-500">Loading questions…</p>;
  }

  const items = data.data.items;
  if (items.length === 0) {
    return <p className="text-slate-500">No questions in this quiz yet.</p>;
  }

  return (
    <div>
      <p className="text-xs text-slate-500 mb-3">
        Showing {items.length} questions. Click "Edit" to open the per-paper
        review page where you can change text, options, correct answer, and
        images.
      </p>
      <ul className="divide-y divide-slate-200 border border-slate-200 rounded-md">
        {items.map((q) => (
          <li key={q.id} className="px-4 py-3">
            <QuestionRow
              q={q as McqQuestion}
              examType={examType}
              subject={subject}
              taxonomy={taxonomy.data}
            />
          </li>
        ))}
      </ul>
    </div>
  );
}

function QuestionRow({
  q,
  examType,
  subject,
  taxonomy,
}: {
  q: McqQuestion;
  examType: ExamType;
  subject: string;
  taxonomy: import("@/lib/api").PublicTaxonomy | undefined;
}) {
  // Pick the source-detail string for this exam_type. Minimal fields per the
  // plan: admission → university, session, unit, question_number, chapter.
  // hsc → board_name, year, question_number, chapter.
  const sourceLine =
    examType === "admission_test"
      ? [
          (q as AdmissionMcqQuestion).university_name,
          (q as AdmissionMcqQuestion).exam_session,
          (q as AdmissionMcqQuestion).exam_unit
            ? `Unit ${(q as AdmissionMcqQuestion).exam_unit}`
            : null,
        ]
          .filter(Boolean)
          .join(" · ")
      : [
          (q as HscMcqQuestion).board_name,
          (q as HscMcqQuestion).exam_year,
        ]
          .filter(Boolean)
          .join(" · ");

  return (
    <div className="flex items-start justify-between gap-4">
      <div className="min-w-0 flex-1">
        <div className="text-xs text-slate-500 mb-1">
          Q{q.question_number}
          {sourceLine ? ` · ${sourceLine}` : ""}
          {q.chapter
            ? ` · ${chapterSerialLabel(taxonomy, subject, q.chapter)}`
            : ""}
        </div>
        <div className="text-sm text-slate-900 line-clamp-2">
          <MathText
            text={q.question_text}
            images={q.images}
            paperId={q.paper_id}
          />
        </div>
      </div>
      <Link
        href={`/admin/papers/${q.paper_id}/review`}
        className="shrink-0 text-xs px-3 py-1.5 rounded-md border border-slate-300 hover:border-blue-500"
      >
        Edit
      </Link>
    </div>
  );
}

// ---------------------------------------------------------------------------
// Submissions tab
// ---------------------------------------------------------------------------

type RosterFilter = "all" | "in_progress" | "submitted";

function SubmissionsTab({
  subject,
  examType,
}: {
  subject: string;
  examType: ExamType;
}) {
  const [filter, setFilter] = useState<RosterFilter>("all");
  const data = useSWR(
    `admin:roster:${subject}:${examType}:${filter}`,
    () =>
      adminListQuizAttempts({
        subject,
        exam_type: examType,
        status: filter,
      }),
  );

  if (data.error) {
    return (
      <p className="text-red-700">
        Failed to load submissions: {data.error.message}
      </p>
    );
  }
  if (!data.data) {
    return <p className="text-slate-500">Loading submissions…</p>;
  }

  const items = data.data.items;

  return (
    <div>
      <div className="flex items-center gap-3 text-sm mb-3">
        <label className="text-slate-600">Filter:</label>
        <select
          value={filter}
          onChange={(e) => setFilter(e.target.value as RosterFilter)}
          className="border border-slate-300 rounded px-2 py-1"
        >
          <option value="all">All</option>
          <option value="in_progress">In progress</option>
          <option value="submitted">Submitted</option>
        </select>
        <span className="text-xs text-slate-500">
          {data.data.total} total
        </span>
      </div>

      {items.length === 0 ? (
        <p className="text-slate-500 text-sm">No submissions match this filter.</p>
      ) : (
        <div className="overflow-x-auto border border-slate-200 rounded-md">
          <table className="w-full text-sm">
            <thead className="bg-slate-50 text-left text-xs uppercase tracking-wide text-slate-500">
              <tr>
                <th className="px-4 py-2">Student</th>
                <th className="px-4 py-2">Started</th>
                <th className="px-4 py-2">Submitted</th>
                <th className="px-4 py-2 text-right">Score</th>
                <th className="px-4 py-2">Status</th>
                <th className="px-4 py-2 w-1"></th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {items.map((row) => (
                <RosterRow
                  key={row.id}
                  row={row}
                  subject={subject}
                  examType={examType}
                />
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

function RosterRow({
  row,
  subject,
  examType,
}: {
  row: AdminRosterEntry;
  subject: string;
  examType: ExamType;
}) {
  const score =
    row.score_correct != null && row.score_total != null
      ? `${row.score_correct} / ${row.score_total}`
      : "—";

  const statusBadge =
    row.status === "in_progress"
      ? "bg-amber-100 text-amber-900"
      : row.status === "submitted"
        ? "bg-green-100 text-green-800"
        : "bg-slate-100 text-slate-700";

  return (
    <tr className="hover:bg-slate-50">
      <td className="px-4 py-2">
        <div className="font-medium text-slate-900">
          {row.user_display_name}
        </div>
        <div className="text-xs text-slate-500">{row.user_email}</div>
      </td>
      <td className="px-4 py-2 text-slate-700">
        {new Date(row.started_at).toLocaleString()}
      </td>
      <td className="px-4 py-2 text-slate-700">
        {row.submitted_at
          ? new Date(row.submitted_at).toLocaleString()
          : "—"}
      </td>
      <td className="px-4 py-2 text-right text-slate-700">{score}</td>
      <td className="px-4 py-2">
        <span
          className={`inline-block px-2 py-0.5 rounded-full text-xs ${statusBadge}`}
        >
          {row.status}
        </span>
      </td>
      <td className="px-4 py-2">
        <Link
          href={`/admin/quizzes/${subject}/${examType}/attempts/${row.id}`}
          className="text-xs text-blue-600 hover:underline whitespace-nowrap"
        >
          View
        </Link>
      </td>
    </tr>
  );
}

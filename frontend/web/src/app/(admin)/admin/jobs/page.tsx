"use client";

import Link from "next/link";
import { useState } from "react";
import useSWR from "swr";
import { listPapers } from "@/lib/api";
import {
  examTypeLabel,
  paperTitle,
  questionTypeLabel,
} from "@/lib/paperDisplay";
import type { ExamListResponse, ExamType, QuestionType } from "@/types/exam";
import RequireAuth from "@/components/RequireAuth";

export default function HistoryPage() {
  return (
    <RequireAuth adminOnly>
      <HistoryPageInner />
    </RequireAuth>
  );
}

function HistoryPageInner() {
  const [examType, setExamType] = useState<ExamType | "">("");
  const [questionType, setQuestionType] = useState<QuestionType | "">("");

  const key = `papers:${examType}:${questionType}`;
  const { data, error, isLoading } = useSWR<ExamListResponse>(
    key,
    () =>
      listPapers({
        exam_type: examType || undefined,
        question_type: questionType || undefined,
        limit: 100,
      }),
    { revalidateOnFocus: false },
  );

  return (
    <div className="max-w-6xl mx-auto px-4 py-6 sm:py-10">
      <div className="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-3 sm:gap-4 mb-6">
        <div>
          <h1 className="text-xl sm:text-2xl font-semibold">Extraction history</h1>
          <p className="text-slate-600 text-sm mt-1">
            Papers that have been extracted and saved to the database.
          </p>
        </div>
        <Link
          href="/admin/upload"
          className="px-4 py-2 rounded-md bg-blue-600 text-white text-sm whitespace-nowrap"
        >
          Upload new
        </Link>
      </div>

      <div className="flex flex-wrap gap-4 mb-4 text-sm">
        <select
          value={examType}
          onChange={(e) => setExamType(e.target.value as ExamType | "")}
          className="border border-slate-300 rounded-md px-2 py-1"
        >
          <option value="">All exam types</option>
          <option value="admission_test">Admission Test</option>
          <option value="hsc_board">HSC Board</option>
        </select>

        <select
          value={questionType}
          onChange={(e) =>
            setQuestionType(e.target.value as QuestionType | "")
          }
          className="border border-slate-300 rounded-md px-2 py-1"
        >
          <option value="">All question types</option>
          <option value="mcq">MCQ</option>
          <option value="written">Written</option>
        </select>
      </div>

      {isLoading && <p className="text-slate-500">Loading…</p>}
      {error && (
        <div className="rounded-md bg-red-50 border border-red-200 p-3 text-sm text-red-700">
          {error instanceof Error ? error.message : "Failed to load"}
        </div>
      )}
      {data && data.items.length === 0 && (
        <p className="text-slate-500">No papers match the current filter.</p>
      )}

      <ul className="divide-y divide-slate-200 border border-slate-200 rounded-md">
        {data?.items.map((p) => (
          <li key={p.id} className="group relative flex flex-col sm:flex-row sm:items-center p-4 hover:bg-slate-50 gap-4">
            <Link
              href={`/admin/papers/${p.id}/review`}
              className="flex-1 min-w-0"
            >
              <div className="font-medium truncate group-hover:text-blue-600 transition-colors">{paperTitle(p)}</div>
              <div className="text-xs text-slate-500 mt-1 truncate">
                {p.source_filename}
              </div>
              <div className="flex items-center gap-2 mt-2 text-xs">
                <span className="px-2 py-0.5 rounded-full bg-slate-100 text-slate-700">
                  {examTypeLabel(p.exam_type)}
                </span>
                <span className="px-2 py-0.5 rounded-full bg-slate-100 text-slate-700">
                  {questionTypeLabel(p.question_type)}
                </span>
                <span className="text-slate-500">{p.question_count} Qs</span>
              </div>
            </Link>
            
            <div className="flex shrink-0 gap-2">
              <Link
                href={`/admin/papers/${p.id}/review/answers`}
                className="px-3 py-1.5 rounded-md border border-blue-200 bg-blue-50 text-blue-700 text-xs font-medium hover:bg-blue-100 transition-colors flex items-center gap-1.5"
              >
                Review Answers
                {p.answer_mismatch_count > 0 && (
                  <span className="px-1.5 py-0.5 rounded-full bg-red-500 text-white text-[10px] font-bold">
                    {p.answer_mismatch_count}
                  </span>
                )}
              </Link>
              <Link
                href={`/admin/papers/${p.id}/review`}
                className="px-3 py-1.5 rounded-md border border-slate-200 bg-white text-slate-700 text-xs font-medium hover:bg-slate-50 transition-colors sm:hidden"
              >
                Edit Questions
              </Link>
            </div>
          </li>
        ))}
      </ul>
    </div>
  );
}

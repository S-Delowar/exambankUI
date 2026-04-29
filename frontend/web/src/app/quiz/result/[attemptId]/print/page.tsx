"use client";

import { use, useEffect } from "react";
import useSWR from "swr";
import { MathText } from "@/components/MathText";
import {
  AttemptDetail,
  QuizReviewQuestion,
  getAttempt,
  getAttemptReview,
} from "@/lib/api";

export default function PrintPage(props: {
  params: Promise<{ attemptId: string }>;
}) {
  const { attemptId } = use(props.params);
  
  const { data: attempt } = useSWR<AttemptDetail>(
    `attempt:${attemptId}`,
    () => getAttempt(attemptId),
  );
  
  const { data: review } = useSWR(
    `attempt:${attemptId}:review:all`,
    async () => {
      const all: QuizReviewQuestion[] = [];
      let page = 1;
      while (true) {
        const r = await getAttemptReview(attemptId, page, 200);
        all.push(...r.items);
        if (page * r.page_size >= r.total) break;
        page++;
      }
      return all;
    },
  );

  useEffect(() => {
    if (attempt && review) {
      setTimeout(() => window.print(), 500);
    }
  }, [attempt, review]);

  if (!attempt || !review) {
    return <div className="p-8">Loading...</div>;
  }

  const correct = attempt.score_correct ?? 0;
  const total = attempt.score_total ?? attempt.question_ids.length;
  const answered = attempt.answers.length;
  const incorrect = Math.max(0, answered - correct);
  const skipped = Math.max(0, total - answered);
  const pct = total > 0 ? Math.round((correct / total) * 100) : 0;

  return (
    <>
      <style jsx global>{`
        @media print {
          body { margin: 0; }
          .no-print { display: none !important; }
          .page-break { page-break-before: always; }
        }
        @media screen {
          .print-container { max-width: 210mm; margin: 0 auto; padding: 20px; }
        }
      `}</style>
      
      <div className="print-container">
        {/* Result Summary */}
        <div className="mb-8">
          <h1 className="text-2xl font-bold mb-4">Quiz Result</h1>
          <p className="text-sm text-gray-600 mb-6">
            Submitted: {attempt.submitted_at ? new Date(attempt.submitted_at).toLocaleString() : "—"}
          </p>
          
          <div className="border-2 border-gray-300 rounded-lg p-6 text-center mb-6">
            <div className="text-sm uppercase text-gray-500 mb-2">Your Score</div>
            <div className="text-5xl font-bold">
              {correct} <span className="text-gray-400">/ {total}</span>
            </div>
            <div className="text-xl text-gray-600 mt-2">{pct}%</div>
          </div>
          
          <div className="grid grid-cols-3 gap-4 mb-6">
            <div className="border border-green-200 bg-green-50 rounded p-4 text-center">
              <div className="text-2xl font-bold text-green-700">{correct}</div>
              <div className="text-xs uppercase text-green-600">Correct</div>
            </div>
            <div className="border border-red-200 bg-red-50 rounded p-4 text-center">
              <div className="text-2xl font-bold text-red-700">{incorrect}</div>
              <div className="text-xs uppercase text-red-600">Incorrect</div>
            </div>
            <div className="border border-gray-200 bg-gray-50 rounded p-4 text-center">
              <div className="text-2xl font-bold text-gray-700">{skipped}</div>
              <div className="text-xs uppercase text-gray-600">Skipped</div>
            </div>
          </div>
        </div>

        {/* Detailed Review */}
        <div className="page-break">
          <h2 className="text-xl font-bold mb-6">Detailed Review</h2>
          
          {review.map((q, idx) => (
            <div key={q.id} className="mb-6 border border-gray-200 rounded-lg p-4">
              <div className="font-semibold mb-3">
                Q{idx + 1}. <MathText text={q.question_text} />
              </div>
              
              <div className="space-y-2 mb-3">
                {q.options.map((opt) => {
                  const isCorrect = q.correct_answer === opt.label;
                  const isPicked = q.selected_label === opt.label;
                  const bgClass = isCorrect
                    ? "bg-green-100 border-green-300"
                    : isPicked
                    ? "bg-red-100 border-red-300"
                    : "bg-gray-50 border-gray-200";
                  
                  return (
                    <div key={opt.label} className={`border rounded p-2 ${bgClass}`}>
                      <span className="font-semibold">{opt.label}.</span>{" "}
                      <MathText text={opt.text} />
                      {isCorrect && <span className="ml-2 text-green-700 font-bold">✓ CORRECT</span>}
                      {isPicked && !isCorrect && <span className="ml-2 text-red-700 font-bold">✗ WRONG</span>}
                    </div>
                  );
                })}
              </div>
              
              {q.gemini_solution && (
                <div className="bg-blue-50 border border-blue-200 rounded p-3 mt-3">
                  <div className="text-xs font-bold uppercase text-blue-700 mb-2">
                    AI Solution
                  </div>
                  <div className="text-sm">
                    <MathText text={q.gemini_solution} />
                  </div>
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
    </>
  );
}

"use client";

import { MathText } from "./MathText";
import { AdmissionMcqQuestion, HscMcqQuestion, Option, QuestionImage } from "@/types/exam";
import { prettySubject } from "@/lib/subjects";

interface AnswerReviewCardProps {
  q: AdmissionMcqQuestion | HscMcqQuestion;
}

export function AnswerReviewCard({ q }: AnswerReviewCardProps) {
  console.log(`Q${q.question_number} data:`, { gemini_correct_answer: q.gemini_correct_answer, has_solution: !!q.gemini_solution });
  const isAdmission = "university_name" in q;
  
  // Helper to determine if an option is correct according to different sources
  const isOriginalCorrect = (label: string) => q.correct_answer === label;
  const isGeminiCorrect = (label: string) => q.gemini_correct_answer === label;
  
  // Check if there's a mismatch
  const hasMismatch = q.correct_answer && q.gemini_correct_answer && q.correct_answer !== q.gemini_correct_answer;

  return (
    <div className={`bg-white border rounded-lg shadow-sm overflow-hidden flex flex-col h-full ${
      hasMismatch ? "border-red-400 ring-2 ring-red-200" : "border-slate-200"
    }`}>
      {/* Header */}
      <div className={`px-4 py-3 border-b flex items-center justify-between ${
        hasMismatch ? "bg-red-50 border-red-200" : "border-slate-100 bg-slate-50/50"
      }`}>
        <div className="flex items-center gap-3">
          <span className="text-sm font-bold text-slate-900">Q{q.question_number}</span>
          {hasMismatch && (
            <span className="text-xs font-bold uppercase px-2 py-1 rounded bg-red-500 text-white flex items-center gap-1">
              ⚠ Mismatch
            </span>
          )}
          <div className="flex gap-2">
            {q.subject && (
              <span className="text-[10px] uppercase tracking-wider font-semibold px-1.5 py-0.5 rounded bg-blue-50 text-blue-700 border border-blue-100">
                {prettySubject(q.subject)}
              </span>
            )}
            {isAdmission ? (
              <span className="text-[10px] uppercase tracking-wider font-semibold px-1.5 py-0.5 rounded bg-purple-50 text-purple-700 border border-purple-100">
                {q.university_name} {q.exam_session}
              </span>
            ) : (
              <span className="text-[10px] uppercase tracking-wider font-semibold px-1.5 py-0.5 rounded bg-orange-50 text-orange-700 border border-orange-100">
                {(q as HscMcqQuestion).board_name} {(q as HscMcqQuestion).exam_year}
              </span>
            )}
          </div>
        </div>
      </div>

      <div className="p-4 flex-1 flex flex-col gap-6">
        {/* Question Text */}
        <div className="text-base text-slate-800 leading-relaxed font-medium">
          <MathText 
            text={q.question_text} 
            images={q.images} 
            paperId={q.paper_id} 
          />
        </div>

        {/* Options */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
          {q.options.map((opt) => {
            const originalCorrect = isOriginalCorrect(opt.label);
            const geminiCorrect = isGeminiCorrect(opt.label);
            
            let borderClass = "border-slate-200";
            let bgClass = "bg-white";
            
            if (originalCorrect && geminiCorrect) {
              borderClass = "border-emerald-500 ring-1 ring-emerald-500";
              bgClass = "bg-emerald-50/30";
            } else if (originalCorrect) {
              borderClass = "border-amber-500";
              bgClass = "bg-amber-50/30";
            } else if (geminiCorrect) {
              borderClass = "border-blue-500";
              bgClass = "bg-blue-50/30";
            }

            return (
              <div 
                key={opt.label}
                className={`relative p-3 border rounded-lg flex items-start gap-3 transition-colors ${borderClass} ${bgClass}`}
              >
                <span className={`flex-shrink-0 w-6 h-6 flex items-center justify-center rounded-full border text-xs font-bold ${
                  originalCorrect || geminiCorrect ? "bg-slate-900 text-white border-transparent" : "bg-white text-slate-500 border-slate-200"
                }`}>
                  {opt.label}
                </span>
                <div className="flex-1 text-sm text-slate-700 pt-0.5">
                  <MathText 
                    text={opt.text} 
                    images={q.images} 
                    paperId={q.paper_id} 
                  />
                </div>
                
                {/* Badges for correctness */}
                <div className="absolute top-2 right-2 flex gap-1">
                  {originalCorrect && (
                    <span className="text-[8px] font-black uppercase px-1 py-0.5 rounded bg-amber-100 text-amber-700 border border-amber-200 leading-none">
                      Source
                    </span>
                  )}
                  {geminiCorrect && (
                    <span className="text-[8px] font-black uppercase px-1 py-0.5 rounded bg-blue-100 text-blue-700 border border-blue-200 leading-none">
                      Gemini
                    </span>
                  )}
                </div>
              </div>
            );
          })}
        </div>

        {/* Comparison Summary */}
        <div className="flex flex-wrap gap-4 pt-2 text-xs border-t border-slate-100 mt-2">
           <div className="flex items-center gap-1.5">
              <span className="text-slate-500">Source Answer:</span>
              <span className={`font-bold px-1.5 py-0.5 rounded ${q.correct_answer ? "bg-amber-100 text-amber-800" : "bg-slate-100 text-slate-400"}`}>
                {q.correct_answer || "N/A"}
              </span>
           </div>
           <div className="flex items-center gap-1.5">
              <span className="text-slate-500">Gemini Answer:</span>
              <span className={`font-bold px-1.5 py-0.5 rounded ${q.gemini_correct_answer ? "bg-blue-100 text-blue-800" : "bg-slate-100 text-slate-400"}`}>
                {q.gemini_correct_answer || "N/A"}
              </span>
           </div>
           {q.correct_answer && q.gemini_correct_answer && (
             <div className="flex items-center gap-1.5">
                <span className="text-slate-500">Match:</span>
                {q.correct_answer === q.gemini_correct_answer ? (
                  <span className="text-emerald-600 font-bold flex items-center gap-0.5">
                    ✓ Yes
                  </span>
                ) : (
                  <span className="text-red-600 font-bold flex items-center gap-0.5">
                    ✗ No
                  </span>
                )}
             </div>
           )}
        </div>

        {/* Gemini Solution */}
        {q.gemini_solution && (
          <div className="mt-2 space-y-2 bg-blue-50/30 border border-blue-100 rounded-lg p-4">
            <div className="flex items-center gap-2 mb-2">
              <div className="w-1.5 h-4 bg-blue-500 rounded-full"></div>
              <h3 className="text-xs font-bold uppercase tracking-wider text-blue-900">Gemini Solution</h3>
            </div>
            <div className="text-sm text-slate-700 prose prose-slate prose-sm max-w-none">
              <MathText 
                text={q.gemini_solution} 
                images={q.images} 
                paperId={q.paper_id} 
              />
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

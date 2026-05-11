'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { extractQuestions } from '@/lib/api/workflow';
import { getJobStatus } from '@/lib/api';
import type { JobStatus } from '@/types/exam';

interface ExtractStepProps {
  workflowId: string;
}

export function ExtractStep({ workflowId }: ExtractStepProps) {
  const router = useRouter();
  const [examType, setExamType] = useState<'admission_test' | 'hsc_board'>('hsc_board');
  const [questionType, setQuestionType] = useState<'mcq' | 'written'>('mcq');
  const [subjects, setSubjects] = useState('');
  const [subjectPaper, setSubjectPaper] = useState<'1' | '2' | ''>('');
  const [extracting, setExtracting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [job, setJob] = useState<JobStatus | null>(null);

  const handleExtract = async () => {
    if (!subjects) {
      setError('Please enter subjects');
      return;
    }

    setExtracting(true);
    setError(null);

    try {
      const result = await extractQuestions(workflowId, {
        exam_type: examType,
        question_type: questionType,
        subjects,
        subject_paper: subjectPaper || undefined,
      });
      // Initialize job status for polling
      setJob({
        job_id: result.job_id,
        state: 'pending',
        progress: { page: 0, total: 0 },
        result_path: null,
        paper_id: null,
        error: null,
      });
    } catch (err: any) {
      setError(err.message || 'Extraction failed');
    } finally {
      setExtracting(false);
    }
  };

  // Poll job status every 2s until done/failed
  useEffect(() => {
    if (!job || job.state === 'done' || job.state === 'failed') return;
    const id = setInterval(async () => {
      try {
        const next = await getJobStatus(job.job_id);
        setJob(next);
      } catch (e) {
        setError(e instanceof Error ? e.message : 'Job status fetch failed');
      }
    }, 2000);
    return () => clearInterval(id);
  }, [job]);

  // Job is running — show progress
  if (job) {
    return (
      <div className="max-w-2xl mx-auto">
        <h2 className="text-2xl font-semibold mb-4">Extract Questions</h2>

        <section className="space-y-4">
          <div className="text-sm text-gray-600">
            Job: <span className="font-mono">{job.job_id.slice(0, 8)}</span>
            {' \u2014 '}
            State: <span className="font-medium">{job.state}</span>
          </div>

          {job.progress.total > 0 && (
            <div className="space-y-1">
              <div className="flex justify-between text-sm text-gray-600">
                <span>Processing pages</span>
                <span>Page {job.progress.page} / {job.progress.total}</span>
              </div>
              <div className="h-2 w-full rounded-full bg-gray-100 overflow-hidden">
                <div
                  className="h-full bg-blue-600 transition-all duration-300"
                  style={{
                    width: `${Math.min(100, (job.progress.page / job.progress.total) * 100)}%`,
                  }}
                />
              </div>
            </div>
          )}

          {job.state === 'failed' && (
            <div className="rounded-md bg-red-50 border border-red-200 p-3 text-sm text-red-700">
              {job.error || 'Job failed'}
            </div>
          )}

          {job.state === 'done' && (
            <div className="rounded-md bg-green-50 border border-green-200 p-4 space-y-3">
              <p className="text-green-800 font-medium">Extraction complete.</p>
              <div className="flex flex-wrap gap-2">
                {job.paper_id && (
                  <button
                    onClick={() => router.push(`/admin/papers/${job.paper_id}/review`)}
                    className="px-4 py-2 rounded-md bg-blue-600 text-white text-sm font-medium hover:bg-blue-700"
                  >
                    View result
                  </button>
                )}
                <button
                  onClick={() => router.push('/admin/jobs')}
                  className="px-4 py-2 rounded-md border border-gray-300 bg-white text-sm font-medium hover:bg-gray-50"
                >
                  Open History
                </button>
              </div>
            </div>
          )}

          {job.state !== 'done' && job.state !== 'failed' && (
            <p className="text-sm text-gray-500">
              Extracting questions... This may take a few minutes.
            </p>
          )}
        </section>
      </div>
    );
  }

  // Show extraction form
  return (
    <div className="max-w-2xl mx-auto">
      <h2 className="text-2xl font-semibold mb-4">Extract Questions</h2>
      <p className="text-gray-600 mb-6">
        Configure extraction parameters and start the question extraction process.
      </p>

      <div className="space-y-6">
        <div>
          <label className="block text-sm font-medium mb-2">Exam Type</label>
          <select
            value={examType}
            onChange={(e) => setExamType(e.target.value as any)}
            className="w-full px-4 py-2 border border-gray-300 rounded-lg"
          >
            <option value="hsc_board">HSC Board</option>
            <option value="admission_test">Admission Test</option>
          </select>
        </div>

        <div>
          <label className="block text-sm font-medium mb-2">Question Type</label>
          <select
            value={questionType}
            onChange={(e) => setQuestionType(e.target.value as any)}
            className="w-full px-4 py-2 border border-gray-300 rounded-lg"
          >
            <option value="mcq">MCQ</option>
            <option value="written">Written</option>
          </select>
        </div>

        <div>
          <label className="block text-sm font-medium mb-2">Subjects</label>
          <input
            type="text"
            value={subjects}
            onChange={(e) => setSubjects(e.target.value)}
            placeholder="e.g., physics,chemistry,mathematics"
            className="w-full px-4 py-2 border border-gray-300 rounded-lg"
          />
          <p className="mt-1 text-sm text-gray-500">
            Comma-separated subject keys
          </p>
        </div>

        {examType === 'hsc_board' && subjects.split(',').length === 1 && (
          <div>
            <label className="block text-sm font-medium mb-2">Subject Paper (Optional)</label>
            <select
              value={subjectPaper}
              onChange={(e) => setSubjectPaper(e.target.value as any)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg"
            >
              <option value="">Not applicable</option>
              <option value="1">Paper 1</option>
              <option value="2">Paper 2</option>
            </select>
          </div>
        )}

        {error && (
          <div className="p-4 bg-red-50 border border-red-200 rounded-lg text-red-700">
            {error}
          </div>
        )}

        <div className="flex justify-end">
          <button
            onClick={handleExtract}
            disabled={extracting || !subjects}
            className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:bg-gray-300"
          >
            {extracting ? 'Starting Extraction...' : 'Start Extraction'}
          </button>
        </div>
      </div>
    </div>
  );
}

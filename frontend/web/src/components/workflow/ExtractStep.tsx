'use client';

import { useState } from 'react';
import { extractQuestions } from '@/lib/api/workflow';

interface ExtractStepProps {
  workflowId: string;
}

export function ExtractStep({ workflowId }: ExtractStepProps) {
  const [examType, setExamType] = useState<'admission_test' | 'hsc_board'>('hsc_board');
  const [questionType, setQuestionType] = useState<'mcq' | 'written'>('mcq');
  const [subjects, setSubjects] = useState('');
  const [subjectPaper, setSubjectPaper] = useState<'1' | '2' | ''>('');
  const [extracting, setExtracting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [jobId, setJobId] = useState<string | null>(null);

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
      setJobId(result.job_id);
    } catch (err: any) {
      setError(err.message || 'Extraction failed');
    } finally {
      setExtracting(false);
    }
  };

  if (jobId) {
    return (
      <div className="max-w-2xl mx-auto text-center">
        <div className="mb-6">
          <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <span className="text-3xl">✓</span>
          </div>
          <h2 className="text-2xl font-semibold mb-2">Extraction Started!</h2>
          <p className="text-gray-600">
            Your questions are being extracted. This may take a few minutes.
          </p>
        </div>
        <div className="p-4 bg-blue-50 border border-blue-200 rounded-lg">
          <p className="text-sm text-gray-600 mb-2">Job ID:</p>
          <p className="font-mono text-sm">{jobId}</p>
        </div>
        <a
          href={`/jobs/${jobId}`}
          className="mt-6 inline-block px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
        >
          View Extraction Status
        </a>
      </div>
    );
  }

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

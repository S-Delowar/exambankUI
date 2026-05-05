'use client';

import { useState, useEffect } from 'react';
import { cleanPdf, acceptCleaned, useOriginal } from '@/lib/api/workflow';
import { PDFViewer } from './PDFViewer';

interface CleanStepProps {
  workflowId: string;
  originalPdfUrl: string;
  cleanedPdfUrl: string | null;
  onCleanComplete: (data: { cleaned_pdf_url: string }) => void;
  onAcceptCleaned: () => void;
  onUseOriginal: () => void;
  onSkip: () => void;
}

export function CleanStep({
  workflowId,
  originalPdfUrl,
  cleanedPdfUrl,
  onCleanComplete,
  onAcceptCleaned,
  onUseOriginal,
  onSkip,
}: CleanStepProps) {
  const [cleaning, setCleaning] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [accepting, setAccepting] = useState(false);

  useEffect(() => {
    if (!cleanedPdfUrl) {
      handleClean();
    }
  }, []);

  const handleClean = async () => {
    setCleaning(true);
    setError(null);

    try {
      const result = await cleanPdf(workflowId);
      onCleanComplete(result);
    } catch (err: any) {
      setError(err.message || 'Cleaning failed');
    } finally {
      setCleaning(false);
    }
  };

  const handleAccept = async () => {
    setAccepting(true);
    try {
      await acceptCleaned(workflowId);
      onAcceptCleaned();
    } catch (err: any) {
      setError(err.message || 'Failed to accept');
    } finally {
      setAccepting(false);
    }
  };

  const handleReject = async () => {
    setAccepting(true);
    try {
      await useOriginal(workflowId);
      onUseOriginal();
    } catch (err: any) {
      setError(err.message || 'Failed');
    } finally {
      setAccepting(false);
    }
  };

  return (
    <div>
      <h2 className="text-2xl font-semibold mb-4">PDF Cleaning Comparison</h2>
      <p className="text-gray-600 mb-6">
        Compare the original and cleaned PDFs side-by-side. Choose which version to use for extraction.
      </p>

      {error && (
        <div className="mb-4 p-4 bg-red-50 border border-red-200 rounded-lg text-red-700">
          {error}
        </div>
      )}

      <div className="grid grid-cols-2 gap-6 mb-6">
        <div>
          <h3 className="text-lg font-medium mb-3">Original PDF</h3>
          <PDFViewer url={originalPdfUrl} />
          <button
            onClick={handleReject}
            disabled={accepting || cleaning}
            className="mt-4 w-full px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700 disabled:bg-gray-300"
          >
            Use Original
          </button>
        </div>

        <div>
          <h3 className="text-lg font-medium mb-3">Cleaned PDF</h3>
          {cleaning ? (
            <div className="h-96 flex items-center justify-center bg-gray-100 rounded-lg">
              <div className="text-center">
                <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
                <p className="text-gray-600">Cleaning PDF...</p>
              </div>
            </div>
          ) : cleanedPdfUrl ? (
            <>
              <PDFViewer url={cleanedPdfUrl} />
              <button
                onClick={handleAccept}
                disabled={accepting}
                className="mt-4 w-full px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:bg-gray-300"
              >
                Use Cleaned
              </button>
            </>
          ) : null}
        </div>
      </div>

      <div className="flex justify-between">
        <button
          onClick={onSkip}
          className="px-6 py-3 text-gray-600 hover:text-gray-800"
        >
          Skip Cleaning
        </button>
      </div>
    </div>
  );
}

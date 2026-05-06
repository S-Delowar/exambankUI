'use client';

import { useState, useEffect } from 'react';
import { cropImages, getWorkflowStatus } from '@/lib/api/workflow';

interface CropStepProps {
  workflowId: string;
  pdfUrl: string;
  onComplete: () => void;
  onSkip: () => void;
}

export function CropStep({ workflowId, pdfUrl, onComplete, onSkip }: CropStepProps) {
  const [cropping, setCropping] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [result, setResult] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [filename, setFilename] = useState('');
  const [selectedPdf, setSelectedPdf] = useState('');

  useEffect(() => {
    const fetchWorkflowStatus = async () => {
      try {
        const status = await getWorkflowStatus(workflowId);
        setFilename(status.original_filename);
        setSelectedPdf(status.selected_pdf);
      } catch (err: any) {
        setError(err.message || 'Failed to fetch workflow status');
      } finally {
        setLoading(false);
      }
    };
    fetchWorkflowStatus();
  }, [workflowId]);

  const handleCrop = async () => {
    setCropping(true);
    setError(null);

    try {
      const paperName = filename.replace('.pdf', '');
      const data = await cropImages(workflowId, null, paperName);
      setResult(data);
      setTimeout(() => onComplete(), 1500);
    } catch (err: any) {
      setError(err.message || 'Cropping failed');
    } finally {
      setCropping(false);
    }
  };

  if (loading) {
    return (
      <div className="max-w-2xl mx-auto text-center py-8">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
        <p className="mt-4 text-gray-600">Loading workflow...</p>
      </div>
    );
  }

  return (
    <div className="max-w-2xl mx-auto">
      <h2 className="text-2xl font-semibold mb-4">Crop Images</h2>
      <p className="text-gray-600 mb-6">
        Crop annotated images from the selected PDF. The PDF should have red box annotations marking the areas to crop.
      </p>

      <div className="mb-6 p-4 bg-blue-50 border border-blue-200 rounded-lg">
        <p className="text-sm font-medium text-blue-900 mb-1">File:</p>
        <p className="text-sm text-blue-700 font-mono">{filename}</p>
        <p className="text-xs text-blue-600 mt-1">Using: {selectedPdf} version</p>
      </div>

      {error && (
        <div className="mb-4 p-4 bg-red-50 border border-red-200 rounded-lg text-red-700">
          {error}
        </div>
      )}

      {result && (
        <div className="mb-4 p-4 bg-green-50 border border-green-200 rounded-lg text-green-700">
          ✓ Successfully cropped {result.total_figures} figure(s) from {result.pages_with_figures} page(s)
        </div>
      )}

      <div className="flex justify-between">
        <button
          onClick={onSkip}
          disabled={cropping}
          className="px-6 py-3 text-gray-600 hover:text-gray-800 disabled:opacity-50"
        >
          Skip Cropping
        </button>
        <button
          onClick={handleCrop}
          disabled={cropping}
          className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:bg-gray-300"
        >
          {cropping ? 'Cropping...' : 'Crop Images'}
        </button>
      </div>
    </div>
  );
}

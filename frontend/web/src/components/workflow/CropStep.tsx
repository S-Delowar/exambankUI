'use client';

import { useState } from 'react';
import { cropImages } from '@/lib/api/workflow';

interface CropStepProps {
  workflowId: string;
  pdfUrl: string;
  onComplete: () => void;
  onSkip: () => void;
}

export function CropStep({ workflowId, pdfUrl, onComplete, onSkip }: CropStepProps) {
  const [paperName, setPaperName] = useState('');
  const [cropping, setCropping] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [result, setResult] = useState<any>(null);

  const handleCrop = async () => {
    if (!paperName) {
      setError('Please provide paper name');
      return;
    }

    setCropping(true);
    setError(null);

    try {
      const data = await cropImages(workflowId, null, paperName);
      setResult(data);
      setTimeout(() => onComplete(), 1500);
    } catch (err: any) {
      setError(err.message || 'Cropping failed');
    } finally {
      setCropping(false);
    }
  };

  return (
    <div className="max-w-2xl mx-auto">
      <h2 className="text-2xl font-semibold mb-4">Crop Images (Optional)</h2>
      <p className="text-gray-600 mb-6">
        The selected PDF has red annotations. Enter a paper name to crop the annotated images.
      </p>

      <div className="space-y-6">
        <div>
          <label className="block text-sm font-medium mb-2">Paper Name</label>
          <input
            type="text"
            value={paperName}
            onChange={(e) => setPaperName(e.target.value)}
            placeholder="e.g., Physics_2023_Dhaka_Board"
            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
          <p className="mt-1 text-sm text-gray-500">
            This name will be used to organize cropped images
          </p>
        </div>

        {error && (
          <div className="p-4 bg-red-50 border border-red-200 rounded-lg text-red-700">
            {error}
          </div>
        )}

        {result && (
          <div className="p-4 bg-green-50 border border-green-200 rounded-lg text-green-700">
            ✓ Successfully cropped {result.total_figures} figure(s) from {result.pages_with_figures} page(s)
          </div>
        )}

        <div className="flex justify-between">
          <button
            onClick={onSkip}
            className="px-6 py-3 text-gray-600 hover:text-gray-800"
          >
            Skip Cropping
          </button>
          <button
            onClick={handleCrop}
            disabled={!paperName || cropping}
            className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:bg-gray-300"
          >
            {cropping ? 'Cropping...' : 'Crop Images & Continue'}
          </button>
        </div>
      </div>
    </div>
  );
}

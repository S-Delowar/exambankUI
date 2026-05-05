'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/lib/AuthContext';
import { Stepper } from '@/components/workflow/Stepper';
import { UploadStep } from '@/components/workflow/UploadStep';
import { CleanStep } from '@/components/workflow/CleanStep';
import { CropStep } from '@/components/workflow/CropStep';
import { ExtractStep } from '@/components/workflow/ExtractStep';

import { API_BASE_URL } from '@/lib/constants';

type WorkflowStep = 'upload' | 'clean' | 'crop' | 'extract';

export default function WorkflowPage() {
  const { user, isAdmin, ready } = useAuth();
  const router = useRouter();
  const [currentStep, setCurrentStep] = useState<WorkflowStep>('upload');
  const [workflowId, setWorkflowId] = useState<string | null>(null);
  const [originalPdfUrl, setOriginalPdfUrl] = useState<string | null>(null);
  const [cleanedPdfUrl, setCleanedPdfUrl] = useState<string | null>(null);
  const [selectedPdf, setSelectedPdf] = useState<'original' | 'cleaned'>('original');

  useEffect(() => {
    if (ready && !user) {
      router.push('/login');
    } else if (ready && user && !isAdmin) {
      router.push('/');
    }
  }, [ready, user, isAdmin, router]);

  if (!ready || !user || !isAdmin) {
    return <div className="container mx-auto px-4 py-8">Loading...</div>;
  }

  const handleUploadComplete = (data: { workflow_id: string; original_pdf_url: string }) => {
    setWorkflowId(data.workflow_id);
    setOriginalPdfUrl(`${API_BASE_URL}${data.original_pdf_url}`);
    setCurrentStep('clean');
  };

  const handleCleanComplete = (data: { cleaned_pdf_url: string }) => {
    setCleanedPdfUrl(`${API_BASE_URL}${data.cleaned_pdf_url}`);
  };

  const handleAcceptCleaned = () => {
    setSelectedPdf('cleaned');
    setCurrentStep('crop');
  };

  const handleUseOriginal = () => {
    setSelectedPdf('original');
    setCurrentStep('crop');
  };

  const handleSkipClean = () => {
    setCurrentStep('crop');
  };

  const handleCropComplete = () => {
    setCurrentStep('extract');
  };

  const handleSkipCrop = () => {
    setCurrentStep('extract');
  };

  return (
    <div className="container mx-auto px-4 py-8 max-w-6xl">
      <h1 className="text-3xl font-bold mb-8">Question Extraction Workflow</h1>

      <Stepper currentStep={currentStep} />

      <div className="mt-8">
        {currentStep === 'upload' && (
          <UploadStep onComplete={handleUploadComplete} />
        )}

        {currentStep === 'clean' && workflowId && (
          <CleanStep
            workflowId={workflowId}
            originalPdfUrl={originalPdfUrl!}
            cleanedPdfUrl={cleanedPdfUrl}
            onCleanComplete={handleCleanComplete}
            onAcceptCleaned={handleAcceptCleaned}
            onUseOriginal={handleUseOriginal}
            onSkip={handleSkipClean}
          />
        )}

        {currentStep === 'crop' && workflowId && (
          <CropStep
            workflowId={workflowId}
            pdfUrl={selectedPdf === 'cleaned' ? cleanedPdfUrl! : originalPdfUrl!}
            onComplete={handleCropComplete}
            onSkip={handleSkipCrop}
          />
        )}

        {currentStep === 'extract' && workflowId && (
          <ExtractStep workflowId={workflowId} />
        )}
      </div>
    </div>
  );
}

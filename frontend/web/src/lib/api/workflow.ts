import { request } from '../api-base';

export async function uploadPdf(file: File) {
  const formData = new FormData();
  formData.append('file', file);
  
  return request<{
    workflow_id: string;
    original_pdf_url: string;
    filename: string;
    size_mb: number;
    next_step: string;
  }>('/admin/workflow/upload', {
    method: 'POST',
    body: formData,
  });
}

export async function cleanPdf(workflowId: string) {
  return request<{
    workflow_id: string;
    original_pdf_url: string;
    cleaned_pdf_url: string;
    next_step: string;
  }>(`/admin/workflow/${workflowId}/clean`, {
    method: 'POST',
  });
}

export async function acceptCleaned(workflowId: string) {
  return request<{
    workflow_id: string;
    selected_pdf: string;
    next_step: string;
  }>(`/admin/workflow/${workflowId}/accept-clean`, {
    method: 'POST',
  });
}

export async function useOriginal(workflowId: string) {
  return request<{
    workflow_id: string;
    selected_pdf: string;
    next_step: string;
  }>(`/admin/workflow/${workflowId}/use-original`, {
    method: 'POST',
  });
}

export async function cropImages(workflowId: string, file: File | null, paperName: string) {
  const formData = new FormData();
  if (file) {
    formData.append('file', file);
  }
  
  return request<{
    workflow_id: string;
    crop_folder: string;
    pages_with_figures: number;
    total_figures: number;
    pages_processed: number;
    next_step: string;
  }>(`/admin/workflow/${workflowId}/crop?paper_name=${encodeURIComponent(paperName)}`, {
    method: 'POST',
    body: formData,
  });
}

export async function extractQuestions(
  workflowId: string,
  params: {
    exam_type: string;
    question_type: string;
    subjects: string;
    subject_paper?: string;
  }
) {
  const query = new URLSearchParams(params as any).toString();
  return request<{
    workflow_id: string;
    job_id: string;
    status_url: string;
    next_step: string;
  }>(`/admin/workflow/${workflowId}/extract?${query}`, {
    method: 'POST',
  });
}

export async function getWorkflowStatus(workflowId: string) {
  return request<{
    workflow_id: string;
    current_step: string;
    status: string;
    original_filename: string;
    original_pdf_url: string;
    cleaned_pdf_url: string | null;
    selected_pdf: string;
    cleaning_applied: boolean;
    cropping_applied: boolean;
    crop_folder: string | null;
    extraction_job_id: string | null;
    paper_id: string | null;
    error_message: string | null;
    created_at: string;
    updated_at: string;
  }>(`/admin/workflow/${workflowId}`);
}

'use client';

interface PDFViewerProps {
  url: string;
}

export function PDFViewer({ url }: PDFViewerProps) {
  return (
    <div className="border border-gray-300 rounded-lg overflow-hidden bg-gray-100" style={{ height: '500px' }}>
      <embed
        src={url}
        type="application/pdf"
        className="w-full h-full"
      />
    </div>
  );
}

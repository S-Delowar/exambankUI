"use client";

// Lightweight PDF viewer that embeds the backend-served PDF via a browser's
// native `<embed>` fallback-chained with `<iframe>`. We deliberately avoid
// react-pdf / pdfjs-dist here to keep the bundle slim and avoid worker
// hydration headaches — every mainstream browser can render PDF inline.
//
// If the paper has no stored source PDF (`has_source_pdf=false`), we show a
// note instead of a broken iframe.

import { sourcePdfUrl } from "@/lib/api";

export function PdfPane({
  paperId,
  hasSourcePdf,
}: {
  paperId: string;
  hasSourcePdf: boolean;
}) {
  if (!hasSourcePdf) {
    return (
      <div className="h-full flex items-center justify-center text-sm text-slate-500 p-6 text-center">
        No source PDF was saved for this paper.
        <br />
        (Re-upload the PDF to attach it.)
      </div>
    );
  }
  const url = sourcePdfUrl(paperId);
  return (
    <object data={url} type="application/pdf" className="w-full h-full">
      <iframe src={url} className="w-full h-full border-0" title="Source PDF" />
    </object>
  );
}

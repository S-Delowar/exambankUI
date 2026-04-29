"use client";

// Modal cropper used from the review page's question modify mode. Loads any
// image source (existing PNG URL or user-uploaded blob URL), lets the user
// pan/zoom/crop with react-easy-crop, then produces a PNG Blob from the
// selected area via an offscreen canvas. The blob is handed back to the
// caller, which POSTs it to /review/questions/{id}/images/{image_id}.

import { useCallback, useState } from "react";
import Cropper, { type Area } from "react-easy-crop";

interface Props {
  src: string;
  title?: string;
  onSave: (png: Blob) => Promise<void> | void;
  onCancel: () => void;
}

export function ImageEditor({ src, title, onSave, onCancel }: Props) {
  const [crop, setCrop] = useState({ x: 0, y: 0 });
  const [zoom, setZoom] = useState(1);
  const [pixels, setPixels] = useState<Area | null>(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const onCropComplete = useCallback((_: Area, areaPixels: Area) => {
    setPixels(areaPixels);
  }, []);

  const save = async () => {
    if (!pixels) return;
    setBusy(true);
    setError(null);
    try {
      const blob = await getCroppedPngBlob(src, pixels);
      await onSave(blob);
    } catch (e) {
      setError(e instanceof Error ? e.message : "Crop failed");
      setBusy(false);
    }
  };

  return (
    <div
      className="fixed inset-0 z-50 bg-black/50 flex items-center justify-center p-2 sm:p-4"
      role="dialog"
      aria-modal="true"
    >
      <div className="bg-white rounded-md shadow-xl w-full max-w-2xl max-h-full flex flex-col">
        <div className="px-4 py-2 border-b border-slate-200 flex items-center justify-between">
          <span className="text-sm font-medium text-slate-700">
            {title || "Crop image"}
          </span>
          <button
            onClick={onCancel}
            disabled={busy}
            className="text-slate-500 hover:text-slate-900 text-sm"
            aria-label="Close"
          >
            ✕
          </button>
        </div>

        <div className="relative w-full bg-slate-900 h-[55vh] sm:h-[420px]">
          <Cropper
            image={src}
            crop={crop}
            zoom={zoom}
            aspect={undefined}
            onCropChange={setCrop}
            onZoomChange={setZoom}
            onCropComplete={onCropComplete}
            restrictPosition={false}
            objectFit="contain"
          />
        </div>

        <div className="px-4 py-3 border-t border-slate-200 flex flex-wrap items-center gap-3">
          <label className="flex items-center gap-2 text-xs text-slate-600 flex-1 min-w-[140px]">
            <span>Zoom</span>
            <input
              type="range"
              min={1}
              max={5}
              step={0.05}
              value={zoom}
              onChange={(e) => setZoom(Number(e.target.value))}
              className="flex-1"
              disabled={busy}
            />
          </label>
          {error && <span className="text-xs text-red-600">{error}</span>}
          <button
            onClick={onCancel}
            disabled={busy}
            className="text-xs px-3 py-1 rounded-md border border-slate-300"
          >
            Cancel
          </button>
          <button
            onClick={save}
            disabled={busy || !pixels}
            className="text-xs px-3 py-1 rounded-md bg-blue-600 text-white disabled:bg-slate-400"
          >
            {busy ? "Saving…" : "Save crop"}
          </button>
        </div>
      </div>
    </div>
  );
}

// Load an image URL into an HTMLImageElement without depending on the
// browser's `<img>` cache state. Fetching as a blob first sidesteps a
// Chrome/Firefox quirk where a cached response served without CORS headers
// can't later be used to construct a CORS-clean image — `<img crossOrigin>`
// would fail with "Could not load image" even though the server allows it.
// Object URLs are same-origin so the resulting canvas is never tainted.
async function loadImage(src: string): Promise<HTMLImageElement> {
  const isBlobUrl = src.startsWith("blob:") || src.startsWith("data:");
  let objectUrl: string | null = null;
  let toLoad = src;
  if (!isBlobUrl) {
    const res = await fetch(src, { cache: "no-store", credentials: "omit" });
    if (!res.ok) throw new Error(`Could not load image (HTTP ${res.status})`);
    const blob = await res.blob();
    objectUrl = URL.createObjectURL(blob);
    toLoad = objectUrl;
  }
  try {
    return await new Promise<HTMLImageElement>((resolve, reject) => {
      const img = new Image();
      img.onload = () => resolve(img);
      img.onerror = () => reject(new Error("Could not load image"));
      img.src = toLoad;
    });
  } finally {
    // Revoke after the image is decoded so toBlob can still read its bitmap.
    if (objectUrl) setTimeout(() => URL.revokeObjectURL(objectUrl!), 0);
  }
}

async function getCroppedPngBlob(src: string, area: Area): Promise<Blob> {
  const image = await loadImage(src);
  const canvas = document.createElement("canvas");
  canvas.width = Math.max(1, Math.round(area.width));
  canvas.height = Math.max(1, Math.round(area.height));
  const ctx = canvas.getContext("2d");
  if (!ctx) throw new Error("Canvas 2D context unavailable");
  ctx.drawImage(
    image,
    area.x,
    area.y,
    area.width,
    area.height,
    0,
    0,
    canvas.width,
    canvas.height,
  );
  return new Promise<Blob>((resolve, reject) => {
    canvas.toBlob(
      (b) => (b ? resolve(b) : reject(new Error("Canvas toBlob failed"))),
      "image/png",
    );
  });
}

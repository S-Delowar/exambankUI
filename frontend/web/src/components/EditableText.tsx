"use client";

import { useDeferredValue, useState } from "react";
import { MathText } from "./MathText";
import type { QuestionImage } from "@/types/exam";

/**
 * Click-to-edit wrapper around a text area. Read-mode renders via KaTeX.
 * Edit-mode is a plain textarea so the reviewer can tweak raw LaTeX.
 *
 * `onSave` returns a Promise — while it's in flight we disable the inputs
 * and show a spinner-ish label. If it throws, the error string is surfaced
 * inline and edit mode is kept open so the reviewer can retry.
 */
export function EditableText({
  value,
  onSave,
  placeholder,
  multiline = true,
  className = "",
  renderAs = "math",
  images,
  paperId,
}: {
  value: string;
  onSave: (next: string) => Promise<void>;
  placeholder?: string;
  multiline?: boolean;
  className?: string;
  renderAs?: "math" | "plain";
  images?: QuestionImage[];
  paperId?: string;
}) {
  const [editing, setEditing] = useState(false);
  const [draft, setDraft] = useState(value);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const deferredDraft = useDeferredValue(draft);

  const enter = () => {
    setDraft(value);
    setError(null);
    setEditing(true);
  };

  const cancel = () => {
    setDraft(value);
    setError(null);
    setEditing(false);
  };

  const save = async () => {
    setSaving(true);
    setError(null);
    try {
      await onSave(draft);
      setEditing(false);
    } catch (e) {
      setError(e instanceof Error ? e.message : "Save failed");
    } finally {
      setSaving(false);
    }
  };

  if (!editing) {
    return (
      <div
        onClick={enter}
        className={`cursor-text rounded px-2 py-1 -mx-2 hover:bg-slate-50 ${className}`}
        title="Click to edit"
      >
        {value ? (
          renderAs === "math" ? (
            <MathText text={value} images={images} paperId={paperId} />
          ) : (
            <span className="preserve-breaks">{value}</span>
          )
        ) : (
          <span className="italic text-slate-400">
            {placeholder || "(empty — click to edit)"}
          </span>
        )}
      </div>
    );
  }

  const Field = multiline ? "textarea" : "input";
  const showPreview = renderAs === "math" && draft.trim().length > 0;
  return (
    <div className={`space-y-2 ${className}`}>
      <Field
        value={draft}
        onChange={(e) =>
          setDraft((e.target as HTMLInputElement | HTMLTextAreaElement).value)
        }
        disabled={saving}
        rows={multiline ? Math.max(2, draft.split("\n").length) : undefined}
        className="w-full border border-slate-300 rounded-md p-2 font-mono text-sm"
      />
      {showPreview && (
        <div className="rounded-md border border-dashed border-slate-300 bg-slate-50 px-2 py-1 text-sm">
          <div className="text-[10px] uppercase tracking-wide text-slate-400 mb-0.5">
            preview
          </div>
          <MathText text={deferredDraft} images={images} paperId={paperId} />
        </div>
      )}
      {error && (
        <div className="text-xs text-red-600">{error}</div>
      )}
      <div className="flex gap-2">
        <button
          onClick={save}
          disabled={saving}
          className="px-3 py-1 rounded-md bg-blue-600 text-white text-sm disabled:bg-slate-400"
        >
          {saving ? "Saving…" : "Save"}
        </button>
        <button
          onClick={cancel}
          disabled={saving}
          className="px-3 py-1 rounded-md border border-slate-300 text-sm"
        >
          Cancel
        </button>
      </div>
    </div>
  );
}

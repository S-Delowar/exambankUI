"use client";

import { useEffect, useRef, useState } from "react";
import useSWR from "swr";
import {
  createOption,
  deleteQuestion,
  deleteQuestionImage,
  getChapterTaxonomy,
  patchOption,
  patchQuestion,
  patchSubpart,
  questionImageUrl,
  replaceQuestionImage,
} from "@/lib/api";
import { ALL_SUBJECTS, prettySubject } from "@/lib/subjects";
import type {
  AdmissionMcqQuestion,
  AdmissionWrittenQuestion,
  AnyQuestion,
  ExamType,
  HscMcqQuestion,
  HscWrittenQuestion,
  HscWrittenSubpart,
  Option,
  QuestionImage,
  QuestionType,
} from "@/types/exam";
import { MathText } from "./MathText";
import { EditableText } from "./EditableText";
import { ImageEditor } from "./ImageEditor";
import { useToast } from "./Toast";

type MutateFn = (updater: (prev: AnyQuestion[]) => AnyQuestion[]) => void;

interface CardCtx {
  examType: ExamType;
  questionType: QuestionType;
  mutate: MutateFn;
}

// True if the given text contains any `[IMAGE]` or `[IMAGE_N]` token. Used
// by the header badge + HSC written save path.
const IMAGE_TOKEN_RE = /\[IMAGE(?:_\d+)?\]/;
function textHasImage(text: string): boolean {
  return IMAGE_TOKEN_RE.test(text);
}

type MenuItem = {
  label: string;
  onClick: () => void;
  danger?: boolean;
};

// -------------------------- Header + kebab menu ----------------------------

function QuestionHeader({
  questionNumber,
  hasImage,
  menu,
  rightSlot,
}: {
  questionNumber: string;
  hasImage: boolean;
  menu?: MenuItem[];
  rightSlot?: React.ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!open) return;
    const onClick = (e: MouseEvent) => {
      if (ref.current && !ref.current.contains(e.target as Node)) {
        setOpen(false);
      }
    };
    document.addEventListener("mousedown", onClick);
    return () => document.removeEventListener("mousedown", onClick);
  }, [open]);

  return (
    <div className="flex items-center justify-between mb-3">
      <div className="flex items-center gap-2">
        <span className="text-sm font-medium text-slate-700">
          Q{questionNumber}
        </span>
        {hasImage && (
          <span className="text-xs px-1.5 py-0.5 rounded bg-amber-50 text-amber-800 border border-amber-200">
            image
          </span>
        )}
      </div>
      <div className="flex items-center gap-2">
        {rightSlot}
        {menu && menu.length > 0 && (
          <div className="relative" ref={ref}>
            <button
              onClick={() => setOpen((v) => !v)}
              className="text-slate-500 hover:text-slate-900 px-2 py-0.5 rounded-md hover:bg-slate-100"
              aria-label="Question actions"
              aria-haspopup="menu"
              aria-expanded={open}
            >
              ⋮
            </button>
            {open && (
              <div
                role="menu"
                className="absolute right-0 top-full mt-1 z-10 min-w-[8rem] bg-white border border-slate-200 rounded-md shadow-md py-1"
              >
                {menu.map((item) => (
                  <button
                    key={item.label}
                    role="menuitem"
                    onClick={() => {
                      setOpen(false);
                      item.onClick();
                    }}
                    className={`block w-full text-left text-sm px-3 py-1 hover:bg-slate-50 ${
                      item.danger ? "text-red-600" : "text-slate-700"
                    }`}
                  >
                    {item.label}
                  </button>
                ))}
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
}

function DeleteConfirmBar({
  busy,
  onConfirm,
  onCancel,
}: {
  busy: boolean;
  onConfirm: () => void;
  onCancel: () => void;
}) {
  return (
    <div className="flex items-center gap-2 mb-3 p-2 bg-red-50 border border-red-200 rounded-md">
      <span className="text-xs text-red-700 flex-1">
        Delete this question? This cannot be undone.
      </span>
      <button
        onClick={onConfirm}
        disabled={busy}
        className="text-xs px-2 py-1 rounded-md bg-red-600 text-white disabled:bg-slate-400"
      >
        {busy ? "Deleting…" : "Confirm delete"}
      </button>
      <button
        onClick={onCancel}
        disabled={busy}
        className="text-xs px-2 py-1 rounded-md border border-slate-300"
      >
        Cancel
      </button>
    </div>
  );
}

// -------------------------- Images section (modify mode only) --------------

/** Per-question image editor: thumbnail + Crop / Replace / Delete for each
 * `QuestionImage`. Mutates the SWR cache on success and bumps a per-image
 * version counter so MathText re-fetches the freshly-overwritten PNG instead
 * of serving the stale browser cache. */
function ImagesSection({
  ctx,
  questionId,
  paperId,
  images,
  imageVersions,
  bumpVersion,
}: {
  ctx: CardCtx;
  questionId: string;
  paperId: string;
  images: QuestionImage[];
  imageVersions: Record<string, number>;
  bumpVersion: (imageId: string) => void;
}) {
  const toast = useToast();
  const [editing, setEditing] = useState<{
    imageId: string;
    src: string;
  } | null>(null);
  const [confirmDelete, setConfirmDelete] = useState<string | null>(null);
  const [busyId, setBusyId] = useState<string | null>(null);

  const openCropExisting = (img: QuestionImage) => {
    if (!img.filename) return;
    setEditing({
      imageId: img.id,
      src: questionImageUrl(paperId, img.filename, imageVersions[img.id]),
    });
  };

  const openReplaceFromFile = (img: QuestionImage, file: File) => {
    setEditing({ imageId: img.id, src: URL.createObjectURL(file) });
  };

  const onSaveCrop = async (blob: Blob) => {
    if (!editing) return;
    const { imageId } = editing;
    setBusyId(imageId);
    try {
      await replaceQuestionImage({
        question_id: questionId,
        image_id: imageId,
        exam_type: ctx.examType,
        question_type: ctx.questionType,
        blob,
      });
      bumpVersion(imageId);
      toast.push("success", "Image updated");
      setEditing(null);
    } catch (e) {
      toast.push("error", e instanceof Error ? e.message : "Image update failed");
    } finally {
      setBusyId(null);
    }
  };

  const runDelete = async (imageId: string) => {
    setBusyId(imageId);
    try {
      await deleteQuestionImage({
        question_id: questionId,
        image_id: imageId,
        exam_type: ctx.examType,
        question_type: ctx.questionType,
      });
      // Strip the matching token + image from the local cache so the card
      // re-renders without a refetch. Mirrors the backend's _strip_image_token.
      const suffix = imageId.replace(/^IMAGE_/, "");
      const tokenRe =
        suffix === "IMAGE" || suffix === ""
          ? /\[IMAGE\]/g
          : new RegExp(`\\[IMAGE_${suffix}\\]`, "g");
      const stripText = (s: string | null | undefined) =>
        s == null ? s : s.replace(tokenRe, "");
      ctx.mutate((prev) =>
        prev.map((q) => {
          if (q.id !== questionId) return q;
          const next = { ...q } as AnyQuestion;
          if ("question_text" in next && next.question_text != null) {
            (next as { question_text: string }).question_text = stripText(
              next.question_text,
            ) as string;
          }
          if ("uddipak_text" in next && next.uddipak_text != null) {
            (next as { uddipak_text: string }).uddipak_text = stripText(
              next.uddipak_text,
            ) as string;
          }
          if ("options" in next && Array.isArray(next.options)) {
            (next as { options: Option[] }).options = next.options.map((o) => ({
              ...o,
              text: stripText(o.text) ?? o.text,
            }));
          }
          if ("sub_parts" in next && Array.isArray(next.sub_parts)) {
            (next as { sub_parts: HscWrittenSubpart[] }).sub_parts =
              next.sub_parts.map((sp) => ({
                ...sp,
                text: stripText(sp.text) ?? sp.text,
              }));
          }
          (next as { images?: QuestionImage[] }).images = (
            next.images || []
          ).filter((im) => im.id !== imageId);
          return next;
        }),
      );
      toast.push("success", "Image deleted");
      setConfirmDelete(null);
    } catch (e) {
      toast.push("error", e instanceof Error ? e.message : "Delete failed");
    } finally {
      setBusyId(null);
    }
  };

  if (!images.length) return null;

  return (
    <div className="space-y-2">
      <div className="text-[10px] uppercase tracking-wide text-slate-500">
        Images
      </div>
      {images.map((img) => {
        const url = img.filename
          ? questionImageUrl(paperId, img.filename, imageVersions[img.id])
          : null;
        const busy = busyId === img.id;
        return (
          <div
            key={img.id}
            className="border border-slate-200 rounded-md p-2 flex items-start gap-3 bg-white"
          >
            <div className="w-24 shrink-0">
              {url ? (
                <img
                  src={url}
                  alt={img.label || img.id}
                  className="w-24 h-24 object-contain border border-slate-200 rounded bg-slate-50"
                />
              ) : (
                <div className="w-24 h-24 border border-slate-200 rounded bg-slate-50 text-xs text-slate-400 flex items-center justify-center">
                  no file
                </div>
              )}
            </div>
            <div className="flex-1 min-w-0">
              <div className="text-xs text-slate-600 mb-1">
                <span className="font-medium text-slate-800">{img.id}</span>
                {img.label && (
                  <span className="text-slate-400"> · {img.label}</span>
                )}
                <span className="text-slate-400"> · {img.kind}</span>
              </div>
              {confirmDelete === img.id ? (
                <div className="flex items-center gap-2">
                  <span className="text-xs text-red-700">
                    Delete this image and its [{img.id}] reference?
                  </span>
                  <button
                    onClick={() => runDelete(img.id)}
                    disabled={busy}
                    className="text-xs px-2 py-1 rounded-md bg-red-600 text-white disabled:bg-slate-400"
                  >
                    {busy ? "Deleting…" : "Confirm"}
                  </button>
                  <button
                    onClick={() => setConfirmDelete(null)}
                    disabled={busy}
                    className="text-xs px-2 py-1 rounded-md border border-slate-300"
                  >
                    Cancel
                  </button>
                </div>
              ) : (
                <div className="flex items-center gap-2">
                  <button
                    onClick={() => openCropExisting(img)}
                    disabled={busy || !img.filename}
                    className="text-xs px-2 py-1 rounded-md border border-slate-300 hover:bg-slate-50"
                  >
                    Crop
                  </button>
                  <label className="text-xs px-2 py-1 rounded-md border border-slate-300 hover:bg-slate-50 cursor-pointer">
                    Replace…
                    <input
                      type="file"
                      accept="image/png,image/jpeg"
                      className="hidden"
                      disabled={busy}
                      onChange={(e) => {
                        const f = e.target.files?.[0];
                        e.target.value = "";
                        if (f) openReplaceFromFile(img, f);
                      }}
                    />
                  </label>
                  <button
                    onClick={() => setConfirmDelete(img.id)}
                    disabled={busy}
                    className="text-xs px-2 py-1 rounded-md text-red-600 hover:bg-red-50"
                  >
                    Delete
                  </button>
                </div>
              )}
            </div>
          </div>
        );
      })}
      {editing && (
        <ImageEditor
          src={editing.src}
          title={`Crop ${editing.imageId}`}
          onSave={onSaveCrop}
          onCancel={() => setEditing(null)}
        />
      )}
    </div>
  );
}

/** Hook: per-image cache-bust counters. Bump after a successful re-crop so
 * the freshly-overwritten PNG isn't served from the browser cache. */
function useImageVersions(): {
  versions: Record<string, number>;
  bump: (imageId: string) => void;
} {
  const [versions, setVersions] = useState<Record<string, number>>({});
  const bump = (imageId: string) =>
    setVersions((v) => ({ ...v, [imageId]: (v[imageId] ?? 0) + 1 }));
  return { versions, bump };
}

// -------------------------- Shared: subject picker --------------------------

function SubjectSelect({
  value,
  onChange,
  disabled,
}: {
  value: string | null;
  onChange: (next: string | null) => void;
  disabled?: boolean;
}) {
  const v = value ?? "";
  const inList = v !== "" && ALL_SUBJECTS.includes(v as never);
  return (
    <select
      value={v}
      onChange={(e) => onChange(e.target.value || null)}
      disabled={disabled}
      className="text-xs border border-slate-300 rounded-md px-1 py-0.5 bg-white"
      aria-label="Subject"
    >
      <option value="">(none)</option>
      {ALL_SUBJECTS.map((s) => (
        <option key={s} value={s}>
          {prettySubject(s)}
        </option>
      ))}
      {!inList && v !== "" && <option value={v}>{v} (unknown)</option>}
    </select>
  );
}

// Chapter taxonomy is small (~100 entries) and identical across cards; fetch
// once per session and share the cache across every Modify form.
function useChapterTaxonomy() {
  return useSWR<Record<string, string[]>>("taxonomy:chapters", getChapterTaxonomy, {
    revalidateOnFocus: false,
    revalidateIfStale: false,
  });
}

function ChapterSelect({
  subject,
  value,
  onChange,
  disabled,
}: {
  subject: string | null;
  value: string | null;
  onChange: (next: string | null) => void;
  disabled?: boolean;
}) {
  const { data, isLoading } = useChapterTaxonomy();
  const chapters = (subject && data?.[subject]) || [];
  const v = value ?? "";
  const inList = v !== "" && chapters.includes(v);

  if (!subject) {
    return (
      <span className="text-xs italic text-slate-400">
        (pick a subject first)
      </span>
    );
  }

  return (
    <select
      value={v}
      onChange={(e) => onChange(e.target.value || null)}
      disabled={disabled || isLoading}
      className="text-xs border border-slate-300 rounded-md px-1 py-0.5 bg-white max-w-[16rem]"
      aria-label="Chapter"
    >
      <option value="">(none)</option>
      {chapters.map((c) => (
        <option key={c} value={c}>
          {c}
        </option>
      ))}
      {!inList && v !== "" && <option value={v}>{v} (unknown)</option>}
    </select>
  );
}

// -------------------------- Drag-reorder (read-mode) ------------------------

function useDragReorder({
  ctx,
  questionId,
  options,
  disabled,
}: {
  ctx: CardCtx;
  questionId: string;
  options: readonly (Option & { id?: string })[];
  disabled: boolean;
}) {
  const [dragId, setDragId] = useState<string | null>(null);
  const toast = useToast();

  const reorder = async (fromId: string, toId: string) => {
    if (fromId === toId) return;
    const idOrder = options.map((o) => o.id).filter((x): x is string => Boolean(x));
    const from = idOrder.indexOf(fromId);
    const to = idOrder.indexOf(toId);
    if (from < 0 || to < 0) return;
    const nextIds = [...idOrder];
    nextIds.splice(from, 1);
    nextIds.splice(to, 0, fromId);

    ctx.mutate((prev) =>
      prev.map((q) => {
        if (q.id !== questionId || !("options" in q)) return q;
        const byId = new Map(q.options.map((o) => [o.id, o]));
        const reordered = nextIds
          .map((id) => byId.get(id))
          .filter((x): x is Option => x !== undefined);
        return { ...q, options: reordered };
      }),
    );

    try {
      await Promise.all(
        nextIds.map((id, idx) =>
          patchOption({
            option_id: id,
            exam_type: ctx.examType,
            patch: { display_order: idx },
          }),
        ),
      );
    } catch (e) {
      toast.push("error", e instanceof Error ? e.message : "Reorder failed");
    }
  };

  const handlersFor = (o: Option & { id?: string }) => {
    if (disabled || !o.id) return undefined;
    return {
      draggable: true,
      dragging: dragId === o.id,
      onDragStart: (e: React.DragEvent) => {
        if (!o.id) return;
        setDragId(o.id);
        e.dataTransfer.effectAllowed = "move";
        e.dataTransfer.setData("text/plain", o.id);
      },
      onDragOver: (e: React.DragEvent) => {
        if (dragId && dragId !== o.id) {
          e.preventDefault();
          e.dataTransfer.dropEffect = "move";
        }
      },
      onDrop: (e: React.DragEvent) => {
        e.preventDefault();
        const src = e.dataTransfer.getData("text/plain") || dragId;
        if (src && o.id) void reorder(src, o.id);
        setDragId(null);
      },
      onDragEnd: () => setDragId(null),
    };
  };

  return { handlersFor };
}

// -------------------------- Read-mode option row ---------------------------

function ReadOptionRow({
  option,
  isCorrect,
  dragHandlers,
  images,
  paperId,
  imageVersions,
}: {
  option: Option & { id?: string };
  isCorrect: boolean;
  dragHandlers?: {
    draggable: boolean;
    onDragStart: (e: React.DragEvent) => void;
    onDragOver: (e: React.DragEvent) => void;
    onDrop: (e: React.DragEvent) => void;
    onDragEnd: (e: React.DragEvent) => void;
    dragging: boolean;
  };
  images?: QuestionImage[];
  paperId?: string;
  imageVersions?: Record<string, number>;
}) {
  const borderClass = isCorrect
    ? "border-l-2 border-emerald-500 pl-2"
    : "border-l-2 border-transparent pl-2";
  return (
    <div
      className={`flex items-start gap-2 ${borderClass} ${
        dragHandlers?.dragging ? "opacity-50" : ""
      }`}
      draggable={dragHandlers?.draggable ?? false}
      onDragStart={dragHandlers?.onDragStart}
      onDragOver={dragHandlers?.onDragOver}
      onDrop={dragHandlers?.onDrop}
      onDragEnd={dragHandlers?.onDragEnd}
    >
      {dragHandlers?.draggable && (
        <span
          className="cursor-grab active:cursor-grabbing text-slate-300 hover:text-slate-500 pt-1 select-none"
          title="Drag to reorder"
          aria-label="Drag to reorder"
        >
          ⋮⋮
        </span>
      )}
      <div className="w-10 shrink-0 text-sm font-medium pt-1">
        {option.label}
      </div>
      <div className="flex-1 text-sm">
        <MathText
          text={option.text}
          images={images}
          paperId={paperId}
          imageVersions={imageVersions}
        />
      </div>
    </div>
  );
}

// -------------------------- Modify-mode shared bits -------------------------

function TextFieldWithPreview({
  label,
  value,
  onChange,
  rows,
  images,
  paperId,
  imageVersions,
}: {
  label?: string;
  value: string;
  onChange: (v: string) => void;
  rows?: number;
  images?: QuestionImage[];
  paperId?: string;
  imageVersions?: Record<string, number>;
}) {
  const autoRows = rows ?? Math.max(2, value.split("\n").length);
  const showPreview = value.trim().length > 0;
  return (
    <div className="space-y-1">
      {label && (
        <div className="text-[10px] uppercase tracking-wide text-slate-500">
          {label}
        </div>
      )}
      <textarea
        value={value}
        onChange={(e) => onChange(e.target.value)}
        rows={autoRows}
        className="w-full border border-slate-300 rounded-md p-2 font-mono text-sm"
      />
      {showPreview && (
        <div className="rounded-md border border-dashed border-slate-300 bg-slate-50 px-2 py-1 text-sm">
          <div className="text-[10px] uppercase tracking-wide text-slate-400 mb-0.5">
            preview
          </div>
          <MathText
            text={value}
            images={images}
            paperId={paperId}
            imageVersions={imageVersions}
          />
        </div>
      )}
    </div>
  );
}

function ShortTextField({
  value,
  onChange,
  placeholder,
  widthClass = "w-16",
}: {
  value: string;
  onChange: (v: string) => void;
  placeholder?: string;
  widthClass?: string;
}) {
  return (
    <input
      value={value}
      onChange={(e) => onChange(e.target.value)}
      placeholder={placeholder}
      className={`${widthClass} border border-slate-300 rounded-md px-2 py-1 text-sm font-mono`}
    />
  );
}

function ModifyFooter({
  busy,
  dirty,
  error,
  onSave,
  onCancel,
}: {
  busy: boolean;
  dirty: boolean;
  error: string | null;
  onSave: () => void;
  onCancel: () => void;
}) {
  return (
    <div className="mt-4 pt-3 border-t border-slate-200">
      {error && (
        <div className="text-xs text-red-600 mb-2">{error}</div>
      )}
      <div className="flex justify-end gap-2">
        <button
          onClick={onCancel}
          disabled={busy}
          className="text-sm px-3 py-1 rounded-md border border-slate-300 disabled:opacity-60"
        >
          Cancel
        </button>
        <button
          onClick={onSave}
          disabled={busy || !dirty}
          className="text-sm px-3 py-1 rounded-md bg-blue-600 text-white disabled:bg-slate-400"
        >
          {busy ? "Saving…" : "Save changes"}
        </button>
      </div>
    </div>
  );
}

// -------------------------- MCQ shared draft types --------------------------

// Rows with an id are existing options (we PATCH them if label/text changed).
// Rows with no id are locally-added (we POST them on save).
interface DraftOption {
  key: string; // stable react key
  id?: string;
  label: string;
  text: string;
}

interface McqDraft {
  question_text: string;
  subject: string | null;
  chapter: string | null;
  correct_answer: string | null;
  options: DraftOption[];
}

function buildMcqDraft(q: AdmissionMcqQuestion | HscMcqQuestion): McqDraft {
  return {
    question_text: q.question_text,
    subject: q.subject,
    chapter: q.chapter,
    correct_answer: q.correct_answer,
    options: q.options.map((o, i) => ({
      key: o.id ?? `existing-${i}`,
      id: o.id,
      label: o.label,
      text: o.text,
    })),
  };
}

// Fire PATCH/POST requests implied by the diff between the original question
// and the draft. Returns the updated options list (with freshly-assigned ids
// for new rows) so the caller can stamp the cache.
async function commitMcqChanges(
  ctx: CardCtx,
  original: AdmissionMcqQuestion | HscMcqQuestion,
  draft: McqDraft,
): Promise<{ options: Option[] }> {
  const qPatch: Record<string, unknown> = {};
  if (draft.question_text !== original.question_text) {
    qPatch.question_text = draft.question_text;
  }
  if ((draft.subject ?? null) !== (original.subject ?? null)) {
    qPatch.subject = draft.subject || null;
  }
  // Chapter is sent whenever it differs from the original (includes the
  // subject-swap case, where the draft reducer already cleared it).
  if ((draft.chapter ?? null) !== (original.chapter ?? null)) {
    qPatch.chapter = draft.chapter || null;
  }
  if ((draft.correct_answer ?? null) !== (original.correct_answer ?? null)) {
    qPatch.correct_answer = draft.correct_answer || null;
  }
  if (Object.keys(qPatch).length > 0) {
    await patchQuestion({
      question_id: original.id,
      exam_type: ctx.examType,
      question_type: ctx.questionType,
      patch: qPatch,
    });
  }

  const origById = new Map(original.options.filter((o) => o.id).map((o) => [o.id!, o]));
  const resultOptions: Option[] = [];
  for (const draftOpt of draft.options) {
    if (draftOpt.id) {
      const orig = origById.get(draftOpt.id);
      const patch: Record<string, unknown> = {};
      if (orig && orig.label !== draftOpt.label) patch.label = draftOpt.label;
      if (orig && orig.text !== draftOpt.text) patch.text = draftOpt.text;
      if (Object.keys(patch).length > 0) {
        await patchOption({
          option_id: draftOpt.id,
          exam_type: ctx.examType,
          patch,
        });
      }
      resultOptions.push({
        id: draftOpt.id,
        label: draftOpt.label,
        text: draftOpt.text,
      });
    } else {
      const created = (await createOption({
        question_id: original.id,
        exam_type: ctx.examType,
        label: draftOpt.label,
        text: draftOpt.text,
      })) as { id: string; label: string; text: string };
      resultOptions.push({
        id: created.id,
        label: created.label,
        text: created.text,
      });
    }
  }

  return { options: resultOptions };
}

function mcqDraftIsDirty(
  original: AdmissionMcqQuestion | HscMcqQuestion,
  draft: McqDraft,
): boolean {
  if (draft.question_text !== original.question_text) return true;
  if ((draft.subject ?? null) !== (original.subject ?? null)) return true;
  if ((draft.chapter ?? null) !== (original.chapter ?? null)) return true;
  if ((draft.correct_answer ?? null) !== (original.correct_answer ?? null)) return true;
  if (draft.options.length !== original.options.length) return true;
  for (let i = 0; i < draft.options.length; i++) {
    const d = draft.options[i];
    const o = original.options[i];
    if (!d.id) return true; // new row
    if (d.label !== o.label || d.text !== o.text) return true;
  }
  return false;
}

function validateMcqDraft(draft: McqDraft): string | null {
  if (!draft.question_text.trim()) return "Question text cannot be empty.";
  for (const o of draft.options) {
    if (!o.label.trim()) return "Every option must have a label.";
    if (!o.text.trim()) return "Every option must have text.";
  }
  if (draft.correct_answer) {
    const labels = new Set(draft.options.map((o) => o.label));
    if (!labels.has(draft.correct_answer)) {
      return `Correct answer "${draft.correct_answer}" is not one of the option labels.`;
    }
  }
  return null;
}

// -------------------------- MCQ modify form -------------------------------

function McqModifyForm({
  q,
  ctx,
  onDone,
  imageVersions,
  bumpImageVersion,
}: {
  q: AdmissionMcqQuestion | HscMcqQuestion;
  ctx: CardCtx;
  onDone: () => void;
  imageVersions: Record<string, number>;
  bumpImageVersion: (imageId: string) => void;
}) {
  const [draft, setDraft] = useState<McqDraft>(() => buildMcqDraft(q));
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const toast = useToast();

  const dirty = mcqDraftIsDirty(q, draft);
  const labels = draft.options.map((o) => o.label);

  const setOption = (key: string, patch: Partial<DraftOption>) => {
    setDraft((d) => ({
      ...d,
      options: d.options.map((o) => (o.key === key ? { ...o, ...patch } : o)),
    }));
  };

  const addOption = () => {
    setDraft((d) => ({
      ...d,
      options: [
        ...d.options,
        {
          key: `new-${Date.now()}-${d.options.length}`,
          label: "",
          text: "",
        },
      ],
    }));
  };

  const removePendingOption = (key: string) => {
    setDraft((d) => ({
      ...d,
      options: d.options.filter((o) => o.key !== key),
    }));
  };

  const save = async () => {
    const problem = validateMcqDraft(draft);
    if (problem) {
      setError(problem);
      return;
    }
    setBusy(true);
    setError(null);
    try {
      const { options } = await commitMcqChanges(ctx, q, draft);
      ctx.mutate((prev) =>
        prev.map((x) =>
          x.id === q.id
            ? ({
                ...x,
                question_text: draft.question_text,
                subject: draft.subject,
                chapter: draft.chapter,
                correct_answer: draft.correct_answer,
                options,
              } as AnyQuestion)
            : x,
        ),
      );
      toast.push("success", "Question updated");
      onDone();
    } catch (e) {
      setError(e instanceof Error ? e.message : "Save failed");
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="space-y-4">
      <TextFieldWithPreview
        label="Question"
        value={draft.question_text}
        onChange={(v) => setDraft((d) => ({ ...d, question_text: v }))}
        images={q.images}
        paperId={q.paper_id}
        imageVersions={imageVersions}
      />

      {q.images && q.images.length > 0 && (
        <ImagesSection
          ctx={ctx}
          questionId={q.id}
          paperId={q.paper_id}
          images={q.images}
          imageVersions={imageVersions}
          bumpVersion={bumpImageVersion}
        />
      )}

      <div className="space-y-2">
        <div className="text-[10px] uppercase tracking-wide text-slate-500">
          Options
        </div>
        {draft.options.map((o) => (
          <div key={o.key} className="flex items-start gap-2">
            <div className="pt-1">
              <ShortTextField
                value={o.label}
                onChange={(v) => setOption(o.key, { label: v })}
                placeholder="A"
                widthClass="w-14"
              />
            </div>
            <div className="flex-1">
              <TextFieldWithPreview
                value={o.text}
                onChange={(v) => setOption(o.key, { text: v })}
                images={q.images}
                paperId={q.paper_id}
                imageVersions={imageVersions}
              />
            </div>
            {!o.id && (
              <button
                onClick={() => removePendingOption(o.key)}
                className="text-xs text-slate-500 hover:text-red-600 pt-2"
                title="Discard this new option"
              >
                ✕
              </button>
            )}
          </div>
        ))}
        <button
          onClick={addOption}
          className="text-xs text-blue-600 hover:underline"
        >
          + Add option
        </button>
      </div>

      <div className="flex items-center gap-3 flex-wrap text-xs text-slate-700">
        <label className="flex items-center gap-1">
          <span>Subject:</span>
          <SubjectSelect
            value={draft.subject}
            onChange={(v) =>
              setDraft((d) => ({
                ...d,
                subject: v,
                // Chapters are subject-scoped. Auto-clear on subject change
                // so the picker below doesn't show a stale chapter that
                // belongs to a different subject.
                chapter: v === d.subject ? d.chapter : null,
              }))
            }
          />
        </label>
        <label className="flex items-center gap-1">
          <span>Chapter:</span>
          <ChapterSelect
            subject={draft.subject}
            value={draft.chapter}
            onChange={(v) => setDraft((d) => ({ ...d, chapter: v }))}
          />
        </label>
        <label className="flex items-center gap-1">
          <span>Correct:</span>
          <select
            value={draft.correct_answer ?? ""}
            onChange={(e) =>
              setDraft((d) => ({
                ...d,
                correct_answer: e.target.value || null,
              }))
            }
            className="text-xs border border-slate-300 rounded-md px-1 py-0.5 bg-white"
            aria-label="Correct answer"
          >
            <option value="">(none)</option>
            {labels.map((label) => (
              <option key={label} value={label}>
                {label}
              </option>
            ))}
            {draft.correct_answer && !labels.includes(draft.correct_answer) && (
              <option value={draft.correct_answer}>
                {draft.correct_answer} (custom)
              </option>
            )}
          </select>
        </label>
      </div>

      <ModifyFooter
        busy={busy}
        dirty={dirty}
        error={error}
        onSave={save}
        onCancel={onDone}
      />
    </div>
  );
}

// -------------------------- MCQ read-mode footer --------------------------

function McqReadFooter({
  q,
}: {
  q: AdmissionMcqQuestion | HscMcqQuestion;
}) {
  return (
    <div className="flex items-center gap-2 text-xs text-slate-600 flex-wrap">
      <span>Subject:</span>
      <span className="text-slate-800">
        {q.subject ? prettySubject(q.subject) : "(none)"}
      </span>
      <span className="ml-2">Correct:</span>
      {q.correct_answer ? (
        <span className="text-xs font-semibold text-emerald-700 bg-emerald-50 border border-emerald-200 rounded-md px-2 py-0.5">
          {q.correct_answer}
        </span>
      ) : (
        <span className="italic text-slate-400">(not set)</span>
      )}
      {q.chapter && (
        <span className="text-slate-400 ml-2">• {q.chapter}</span>
      )}
    </div>
  );
}

// -------------------------- Shared delete wrapper -------------------------

function useQuestionDelete(ctx: CardCtx, questionId: string) {
  const [confirming, setConfirming] = useState(false);
  const [busy, setBusy] = useState(false);
  const toast = useToast();

  const run = async () => {
    setBusy(true);
    try {
      await deleteQuestion({
        question_id: questionId,
        exam_type: ctx.examType,
        question_type: ctx.questionType,
      });
      ctx.mutate((prev) => prev.filter((q) => q.id !== questionId));
    } catch (e) {
      toast.push("error", e instanceof Error ? e.message : "Delete failed");
      setBusy(false);
    }
  };

  return {
    confirming,
    busy,
    start: () => setConfirming(true),
    cancel: () => setConfirming(false),
    run,
  };
}

// =================================================================
// MCQ cards
// =================================================================

function McqCard({
  q,
  ctx,
  hasImage,
}: {
  q: AdmissionMcqQuestion | HscMcqQuestion;
  ctx: CardCtx;
  hasImage: boolean;
}) {
  const [mode, setMode] = useState<"read" | "modify">("read");
  const { versions: imageVersions, bump: bumpImageVersion } = useImageVersions();
  const del = useQuestionDelete(ctx, q.id);
  const drag = useDragReorder({
    ctx,
    questionId: q.id,
    options: q.options,
    disabled: mode !== "read",
  });

  const menu: MenuItem[] =
    mode === "read"
      ? [
          { label: "Modify", onClick: () => setMode("modify") },
          { label: "Delete", onClick: del.start, danger: true },
        ]
      : [];

  return (
    <div
      className={`border rounded-md p-4 ${
        mode === "modify" ? "border-blue-300 bg-blue-50/30" : "border-slate-200"
      }`}
    >
      <QuestionHeader
        questionNumber={q.question_number}
        hasImage={hasImage}
        menu={menu}
        rightSlot={
          mode === "modify" ? (
            <span className="text-xs text-blue-700 font-medium">Modifying</span>
          ) : null
        }
      />

      {del.confirming && mode === "read" && (
        <DeleteConfirmBar
          busy={del.busy}
          onConfirm={del.run}
          onCancel={del.cancel}
        />
      )}

      {mode === "read" ? (
        <>
          <div className="mb-4 text-sm">
            <MathText
              text={q.question_text}
              images={q.images}
              paperId={q.paper_id}
              imageVersions={imageVersions}
            />
          </div>
          <div className="space-y-1 mb-3">
            {q.options.map((o, idx) => (
              <ReadOptionRow
                key={o.id || `${q.id}-${idx}`}
                option={o}
                isCorrect={Boolean(q.correct_answer) && o.label === q.correct_answer}
                dragHandlers={drag.handlersFor(o)}
                images={q.images}
                paperId={q.paper_id}
                imageVersions={imageVersions}
              />
            ))}
          </div>
          <McqReadFooter q={q} />
        </>
      ) : (
        <McqModifyForm
          q={q}
          ctx={ctx}
          onDone={() => setMode("read")}
          imageVersions={imageVersions}
          bumpImageVersion={bumpImageVersion}
        />
      )}
    </div>
  );
}

export function AdmissionMcqCard({
  q,
  ctx,
}: {
  q: AdmissionMcqQuestion;
  ctx: CardCtx;
}) {
  const hasImage = q.has_image || (q.images?.length ?? 0) > 0;
  return <McqCard q={q} ctx={ctx} hasImage={hasImage} />;
}

export function HscMcqCard({
  q,
  ctx,
}: {
  q: HscMcqQuestion;
  ctx: CardCtx;
}) {
  const hasImage = q.has_image || (q.images?.length ?? 0) > 0;
  return <McqCard q={q} ctx={ctx} hasImage={hasImage} />;
}

// =================================================================
// Admission Written
// =================================================================

interface AdmWrittenDraft {
  question_text: string;
  subject: string | null;
  chapter: string | null;
}

export function AdmissionWrittenCard({
  q,
  ctx,
}: {
  q: AdmissionWrittenQuestion;
  ctx: CardCtx;
}) {
  const [mode, setMode] = useState<"read" | "modify">("read");
  const { versions: imageVersions, bump: bumpImageVersion } = useImageVersions();
  const [draft, setDraft] = useState<AdmWrittenDraft>({
    question_text: q.question_text,
    subject: q.subject,
    chapter: q.chapter,
  });
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const del = useQuestionDelete(ctx, q.id);
  const toast = useToast();

  const enter = () => {
    setDraft({
      question_text: q.question_text,
      subject: q.subject,
      chapter: q.chapter,
    });
    setError(null);
    setMode("modify");
  };

  const dirty =
    draft.question_text !== q.question_text ||
    (draft.subject ?? null) !== (q.subject ?? null) ||
    (draft.chapter ?? null) !== (q.chapter ?? null);

  const save = async () => {
    if (!draft.question_text.trim()) {
      setError("Question text cannot be empty.");
      return;
    }
    setBusy(true);
    setError(null);
    try {
      const patch: Record<string, unknown> = {};
      if (draft.question_text !== q.question_text) {
        patch.question_text = draft.question_text;
      }
      if ((draft.subject ?? null) !== (q.subject ?? null)) {
        patch.subject = draft.subject || null;
      }
      if ((draft.chapter ?? null) !== (q.chapter ?? null)) {
        patch.chapter = draft.chapter || null;
      }
      if (Object.keys(patch).length > 0) {
        await patchQuestion({
          question_id: q.id,
          exam_type: ctx.examType,
          question_type: ctx.questionType,
          patch,
        });
      }
      ctx.mutate((prev) =>
        prev.map((x) =>
          x.id === q.id
            ? ({
                ...x,
                question_text: draft.question_text,
                subject: draft.subject,
                chapter: draft.chapter,
              } as AnyQuestion)
            : x,
        ),
      );
      toast.push("success", "Question updated");
      setMode("read");
    } catch (e) {
      setError(e instanceof Error ? e.message : "Save failed");
    } finally {
      setBusy(false);
    }
  };

  const menu: MenuItem[] =
    mode === "read"
      ? [
          { label: "Modify", onClick: enter },
          { label: "Delete", onClick: del.start, danger: true },
        ]
      : [];

  return (
    <div
      className={`border rounded-md p-4 ${
        mode === "modify" ? "border-blue-300 bg-blue-50/30" : "border-slate-200"
      }`}
    >
      <QuestionHeader
        questionNumber={q.question_number}
        hasImage={q.has_image || (q.images?.length ?? 0) > 0}
        menu={menu}
        rightSlot={
          mode === "modify" ? (
            <span className="text-xs text-blue-700 font-medium">Modifying</span>
          ) : null
        }
      />
      {del.confirming && mode === "read" && (
        <DeleteConfirmBar
          busy={del.busy}
          onConfirm={del.run}
          onCancel={del.cancel}
        />
      )}
      {mode === "read" ? (
        <>
          <div className="text-sm">
            <MathText
              text={q.question_text}
              images={q.images}
              paperId={q.paper_id}
              imageVersions={imageVersions}
            />
          </div>
          <div className="flex items-center gap-2 text-xs text-slate-600 mt-3 flex-wrap">
            <span>Subject:</span>
            <span className="text-slate-800">
              {q.subject ? prettySubject(q.subject) : "(none)"}
            </span>
            {q.chapter && (
              <span className="text-slate-400 ml-2">• chapter: {q.chapter}</span>
            )}
          </div>
        </>
      ) : (
        <div className="space-y-4">
          <TextFieldWithPreview
            label="Question"
            value={draft.question_text}
            onChange={(v) => setDraft((d) => ({ ...d, question_text: v }))}
            images={q.images}
            paperId={q.paper_id}
            imageVersions={imageVersions}
          />
          {q.images && q.images.length > 0 && (
            <ImagesSection
              ctx={ctx}
              questionId={q.id}
              paperId={q.paper_id}
              images={q.images}
              imageVersions={imageVersions}
              bumpVersion={bumpImageVersion}
            />
          )}
          <div className="flex items-center gap-3 text-xs text-slate-700 flex-wrap">
            <label className="flex items-center gap-1">
              <span>Subject:</span>
              <SubjectSelect
                value={draft.subject}
                onChange={(v) =>
                  setDraft((d) => ({
                    ...d,
                    subject: v,
                    chapter: v === d.subject ? d.chapter : null,
                  }))
                }
              />
            </label>
            <label className="flex items-center gap-1">
              <span>Chapter:</span>
              <ChapterSelect
                subject={draft.subject}
                value={draft.chapter}
                onChange={(v) => setDraft((d) => ({ ...d, chapter: v }))}
              />
            </label>
          </div>
          <ModifyFooter
            busy={busy}
            dirty={dirty}
            error={error}
            onSave={save}
            onCancel={() => setMode("read")}
          />
        </div>
      )}
    </div>
  );
}

// =================================================================
// HSC Written (uddipak + subparts)
// =================================================================

// Subparts keep their own per-field save flow (they're low-level and each
// row already writes through a separate endpoint). The card's Modify mode
// covers uddipak_text + subject; subparts stay inline-editable.

function SubpartRow({
  ctx,
  questionId,
  sp,
  images,
  paperId,
}: {
  ctx: CardCtx;
  questionId: string;
  sp: HscWrittenSubpart;
  images?: QuestionImage[];
  paperId?: string;
}) {
  const save = async (next: string) => {
    await patchSubpart({ subpart_id: sp.id, patch: { text: next } });
    ctx.mutate((prev) =>
      prev.map((q) =>
        q.id === questionId && "sub_parts" in q
          ? {
              ...q,
              sub_parts: q.sub_parts.map((x) =>
                x.id === sp.id ? { ...x, text: next } : x,
              ),
            }
          : q,
      ),
    );
  };
  return (
    <div className="flex items-start gap-3">
      <div className="w-16 shrink-0 text-sm">
        <span className="font-medium">({sp.label})</span>{" "}
        <span className="text-xs text-slate-500">[{sp.marks}]</span>
      </div>
      <div className="flex-1 text-sm">
        <EditableText
          value={sp.text}
          onSave={save}
          images={images}
          paperId={paperId}
        />
      </div>
    </div>
  );
}

interface HscWrittenDraft {
  uddipak_text: string;
  subject: string | null;
}

export function HscWrittenCard({
  q,
  ctx,
}: {
  q: HscWrittenQuestion;
  ctx: CardCtx;
}) {
  const [mode, setMode] = useState<"read" | "modify">("read");
  const { versions: imageVersions, bump: bumpImageVersion } = useImageVersions();
  const [draft, setDraft] = useState<HscWrittenDraft>({
    uddipak_text: q.uddipak_text,
    subject: q.subject,
  });
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const del = useQuestionDelete(ctx, q.id);
  const toast = useToast();

  const enter = () => {
    setDraft({ uddipak_text: q.uddipak_text, subject: q.subject });
    setError(null);
    setMode("modify");
  };

  const dirty =
    draft.uddipak_text !== q.uddipak_text ||
    (draft.subject ?? null) !== (q.subject ?? null);

  const save = async () => {
    setBusy(true);
    setError(null);
    try {
      const patch: Record<string, unknown> = {};
      if (draft.uddipak_text !== q.uddipak_text) {
        patch.uddipak_text = draft.uddipak_text;
        patch.uddipak_has_image = textHasImage(draft.uddipak_text);
      }
      if ((draft.subject ?? null) !== (q.subject ?? null)) {
        patch.subject = draft.subject || null;
      }
      if (Object.keys(patch).length > 0) {
        await patchQuestion({
          question_id: q.id,
          exam_type: ctx.examType,
          question_type: ctx.questionType,
          patch,
        });
      }
      ctx.mutate((prev) =>
        prev.map((x) =>
          x.id === q.id
            ? ({
                ...x,
                uddipak_text: draft.uddipak_text,
                uddipak_has_image: textHasImage(draft.uddipak_text),
                subject: draft.subject,
              } as HscWrittenQuestion)
            : x,
        ),
      );
      toast.push("success", "Question updated");
      setMode("read");
    } catch (e) {
      setError(e instanceof Error ? e.message : "Save failed");
    } finally {
      setBusy(false);
    }
  };

  const menu: MenuItem[] =
    mode === "read"
      ? [
          { label: "Modify", onClick: enter },
          { label: "Delete", onClick: del.start, danger: true },
        ]
      : [];

  return (
    <div
      className={`border rounded-md p-4 ${
        mode === "modify" ? "border-blue-300 bg-blue-50/30" : "border-slate-200"
      }`}
    >
      <QuestionHeader
        questionNumber={q.question_number}
        hasImage={q.uddipak_has_image || (q.images?.length ?? 0) > 0}
        menu={menu}
        rightSlot={
          mode === "modify" ? (
            <span className="text-xs text-blue-700 font-medium">Modifying</span>
          ) : null
        }
      />
      {del.confirming && mode === "read" && (
        <DeleteConfirmBar
          busy={del.busy}
          onConfirm={del.run}
          onCancel={del.cancel}
        />
      )}

      {mode === "read" ? (
        <>
          <div className="mb-4">
            <div className="text-xs font-medium text-slate-500 mb-1">Uddipak</div>
            <div className="text-sm">
              <MathText
                text={q.uddipak_text}
                images={q.images}
                paperId={q.paper_id}
                imageVersions={imageVersions}
              />
            </div>
          </div>
          <div className="space-y-2">
            {q.sub_parts.map((sp) => (
              <SubpartRow
                key={sp.id}
                ctx={ctx}
                questionId={q.id}
                sp={sp}
                images={q.images}
                paperId={q.paper_id}
              />
            ))}
          </div>
          <div className="flex items-center gap-2 text-xs text-slate-600 mt-3 flex-wrap">
            <span>Subject:</span>
            <span className="text-slate-800">
              {q.subject ? prettySubject(q.subject) : "(none)"}
            </span>
          </div>
        </>
      ) : (
        <div className="space-y-4">
          <TextFieldWithPreview
            label="Uddipak"
            value={draft.uddipak_text}
            onChange={(v) => setDraft((d) => ({ ...d, uddipak_text: v }))}
            images={q.images}
            paperId={q.paper_id}
            imageVersions={imageVersions}
          />
          {q.images && q.images.length > 0 && (
            <ImagesSection
              ctx={ctx}
              questionId={q.id}
              paperId={q.paper_id}
              images={q.images}
              imageVersions={imageVersions}
              bumpVersion={bumpImageVersion}
            />
          )}
          <div className="space-y-2">
            <div className="text-[10px] uppercase tracking-wide text-slate-500">
              Subparts (edit inline below after saving)
            </div>
            {q.sub_parts.map((sp) => (
              <div key={sp.id} className="flex items-start gap-3 opacity-70">
                <div className="w-16 shrink-0 text-sm">
                  <span className="font-medium">({sp.label})</span>{" "}
                  <span className="text-xs text-slate-500">[{sp.marks}]</span>
                </div>
                <div className="flex-1 text-sm">
                  <MathText
                    text={sp.text}
                    images={q.images}
                    paperId={q.paper_id}
                    imageVersions={imageVersions}
                  />
                </div>
              </div>
            ))}
          </div>
          <div className="flex items-center gap-3 text-xs text-slate-700 flex-wrap">
            <label className="flex items-center gap-1">
              <span>Subject:</span>
              <SubjectSelect
                value={draft.subject}
                onChange={(v) => setDraft((d) => ({ ...d, subject: v }))}
              />
            </label>
          </div>
          <ModifyFooter
            busy={busy}
            dirty={dirty}
            error={error}
            onSave={save}
            onCancel={() => setMode("read")}
          />
        </div>
      )}
    </div>
  );
}

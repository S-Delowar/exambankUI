"use client";

// Render mixed text that contains `$...$` inline math and `$$...$$` display
// math. Everything outside the delimiters is plain text (Bangla Unicode
// preserved). Everything inside is handed to KaTeX.
//
// Optional: if `images` + `paperId` are provided, `[IMAGE_N]` tokens in the
// plain-text portions are replaced by `<img>` tags pointing at
// `/exams/{paper_id}/images/{filename}`. Tokens without a matching image
// (or when images/paperId are missing) fall back to the "[image]" badge.
//
// Matches the rendering contract in the backend prompts so what the reviewer
// sees here is what the mobile app will render.

import { Fragment, useMemo } from "react";
import katex from "katex";
// mhchem extension — loaded for its side-effect of registering \ce{} with
// KaTeX. Must be imported after katex itself.
import "katex/contrib/mhchem";
import { questionImageUrl } from "@/lib/api";
import type { QuestionImage } from "@/types/exam";

type Segment =
  | { kind: "text"; value: string }
  | { kind: "math"; value: string; display: boolean };

/** Split a string into text / inline-math / display-math segments. */
function tokenize(input: string): Segment[] {
  const segments: Segment[] = [];
  let i = 0;
  while (i < input.length) {
    // Skip escaped dollar.
    if (input[i] === "\\" && input[i + 1] === "$") {
      segments.push({ kind: "text", value: "$" });
      i += 2;
      continue;
    }
    if (input[i] === "$") {
      // Display math?
      const isDisplay = input[i + 1] === "$";
      const open = isDisplay ? "$$" : "$";
      const start = i + open.length;
      // Find matching close that isn't escaped.
      let j = start;
      while (j < input.length) {
        if (input[j] === "\\" && input[j + 1] === "$") {
          j += 2;
          continue;
        }
        if (isDisplay && input[j] === "$" && input[j + 1] === "$") break;
        if (!isDisplay && input[j] === "$") break;
        j++;
      }
      if (j >= input.length) {
        // Unterminated — fall back to literal text.
        segments.push({ kind: "text", value: input.slice(i) });
        break;
      }
      segments.push({
        kind: "math",
        value: input.slice(start, j),
        display: isDisplay,
      });
      i = j + open.length;
      continue;
    }
    // Plain text run.
    let k = i;
    while (k < input.length && input[k] !== "$") {
      if (input[k] === "\\" && input[k + 1] === "$") {
        k += 2;
        continue;
      }
      k++;
    }
    segments.push({ kind: "text", value: input.slice(i, k) });
    i = k;
  }
  return segments;
}

function renderMath(tex: string, display: boolean): string {
  try {
    return katex.renderToString(tex, {
      throwOnError: false,
      displayMode: display,
      strict: "ignore",
    });
  } catch (e) {
    return `<span class="text-red-600">[math error]</span>`;
  }
}

const IMAGE_TOKEN_RE = /\[IMAGE(?:_(\d+))?\]/g;

function escapeHtml(s: string): string {
  return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
}

/** Split a text run on `[IMAGE]` / `[IMAGE_N]` tokens and return React nodes.
 * Tokens with a matching `QuestionImage.filename` become `<img>` tags; the
 * rest fall back to a small placeholder badge (so the reviewer still sees
 * that an image is expected). */
function renderTextRun(
  run: string,
  images: QuestionImage[] | undefined,
  paperId: string | undefined,
  keyPrefix: string,
  imageVersions: Record<string, number> | undefined,
  imageClassName: string,
): React.ReactNode[] {
  const nodes: React.ReactNode[] = [];
  let last = 0;
  let nth = 0;
  IMAGE_TOKEN_RE.lastIndex = 0;
  let match: RegExpExecArray | null;
  while ((match = IMAGE_TOKEN_RE.exec(run)) !== null) {
    if (match.index > last) {
      nodes.push(
        <span
          key={`${keyPrefix}-t-${nth}`}
          dangerouslySetInnerHTML={{ __html: escapeHtml(run.slice(last, match.index)) }}
        />,
      );
    }
    const suffix = match[1];
    const id = suffix ? `IMAGE_${suffix}` : null;
    const img =
      id && images ? images.find((im) => im.id === id) : undefined;
    if (img && img.filename && paperId) {
      const version = imageVersions?.[img.id];
      nodes.push(
        <img
          key={`${keyPrefix}-img-${nth}`}
          src={questionImageUrl(paperId, img.filename, version)}
          alt={img.label || img.id}
          loading="lazy"
          className={imageClassName}
        />,
      );
    } else {
      nodes.push(
        <span
          key={`${keyPrefix}-ph-${nth}`}
          className="inline-block text-xs px-1.5 py-0.5 rounded bg-amber-50 text-amber-800 border border-amber-200 align-middle mx-0.5"
        >
          image
        </span>,
      );
    }
    last = match.index + match[0].length;
    nth++;
  }
  if (last < run.length) {
    nodes.push(
      <span
        key={`${keyPrefix}-t-${nth}`}
        dangerouslySetInnerHTML={{ __html: escapeHtml(run.slice(last)) }}
      />,
    );
  }
  return nodes;
}

const DEFAULT_IMAGE_CLASS =
  "inline-block max-w-xs max-h-48 h-auto my-1 border border-slate-200 rounded";

export function MathText({
  text,
  className = "",
  images,
  paperId,
  imageVersions,
  imageClassName = DEFAULT_IMAGE_CLASS,
}: {
  text: string;
  className?: string;
  images?: QuestionImage[];
  paperId?: string;
  /** Per-image cache-bust counters keyed by image id (e.g. `IMAGE_1`).
   * Bump after a successful re-crop / replace so the freshly-overwritten
   * PNG isn't served from the browser cache. */
  imageVersions?: Record<string, number>;
  /** Override the className applied to each image expanded from `[IMAGE_N]`
   * tokens. Use when the call site needs uniform sizing (e.g. option rows
   * where each option's image must share a fixed height). */
  imageClassName?: string;
}) {
  const nodes = useMemo(() => {
    const segments = tokenize(text);
    return segments.map((s, idx) => {
      if (s.kind === "math") {
        // KaTeX HTML is trusted; image tokens can't appear inside $...$.
        return (
          <span
            key={`m-${idx}`}
            dangerouslySetInnerHTML={{ __html: renderMath(s.value, s.display) }}
          />
        );
      }
      return (
        <Fragment key={`t-${idx}`}>
          {renderTextRun(
            s.value,
            images,
            paperId,
            `t-${idx}`,
            imageVersions,
            imageClassName,
          )}
        </Fragment>
      );
    });
  }, [text, images, paperId, imageVersions, imageClassName]);

  return <span className={`preserve-breaks ${className}`}>{nodes}</span>;
}

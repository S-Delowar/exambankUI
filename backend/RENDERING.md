# Rendering contract

This document pins down the formatting conventions the backend emits inside `question_text` and `options[].text`, so the Next.js web app and the Flutter app render everything identically.

## 1. Math

- **Inline math**: `$...$`
- **Display math**: `$$...$$`
- Standard LaTeX commands only: `\frac`, `\sqrt`, `\int`, `\sum`, `\lim`, `\vec`, `\hat`, `\log`, trig functions, Greek letters, `\leq`, `\geq`, `\neq`, `\approx`, `\cdot`, `\times`, etc.
- Subscripts/superscripts always inside math mode: `$v_0$`, `$x^2$`.
- Units inside math: `$9.8\,\text{m/s}^2$`. Plain units in prose ("5 kg") are fine outside math.
- Plain numbers in prose stay plain — never wrap `"2019"` or `"5 students"` in `$...$`.
- Escape a literal dollar sign as `\$`.
- Never use `\(...\)`, `\[...\]`, `\begin{equation}`, or HTML entities.

## 2. Chemistry

Use the mhchem package — wrap with `\ce{...}` inside math mode.

| Thing | LaTeX |
|---|---|
| Formula | `$\ce{H2O}$` |
| Equation | `$\ce{2H2 + O2 -> 2H2O}$` |
| Ion | `$\ce{SO4^{2-}}$` |
| Isotope | `$\ce{^{14}_{6}C}$` |

## 3. Bangla + mixed text

Bangla Unicode is preserved exactly as printed, **outside** math. Never place Bangla words inside `$...$` — the math engine will treat them as variable names.

```
"যদি $x^2 + 2x + 1 = 0$ হয়, তবে $x$ এর মান কত?"
```

## 4. Web rendering (Next.js)

Use **KaTeX** with the `mhchem` extension.

```bash
npm i katex react-katex
```

```tsx
// katex.config.ts (or wherever you init)
import "katex/dist/katex.min.css";
import "katex/dist/contrib/mhchem.js"; // registers \ce globally
```

Render with a Markdown/LaTeX component of your choice (e.g. `react-markdown` + `remark-math` + `rehype-katex`) or `react-katex` directly. `$...$` → inline, `$$...$$` → block.

## 5. Flutter rendering

Use [`flutter_math_fork`](https://pub.dev/packages/flutter_math_fork) — it supports both standard LaTeX and `\ce{...}`.

```yaml
dependencies:
  flutter_math_fork: ^0.7.2
```

For mixed prose + math, split the string on `$...$` / `$$...$$` and render the delimited pieces with `Math.tex(...)` and the rest as `Text(...)`. There are helpers on pub.dev (`flutter_tex`, `katex_flutter`) if you prefer a drop-in Markdown widget, but `flutter_math_fork` gives tighter control and matches KaTeX output.

## 6. Subject field

`subject` is a free-form lowercase snake_case string. Canonical values the extractor prefers:

- `physics`
- `chemistry`
- `biology`
- `mathematics`
- `bangla`
- `english`

Other values (e.g. `ict`, `general_knowledge`) are possible. Frontends should treat the field as opaque and map to display labels client-side.

## 7. Quick sanity examples

```json
{
  "question_text": "যদি $f(x) = x^2 + 3x + 2$ হয়, তবে $f(-1)$ এর মান—",
  "options": [
    {"label": "A", "text": "$0$"},
    {"label": "B", "text": "$1$"},
    {"label": "C", "text": "$-1$"},
    {"label": "D", "text": "$2$"}
  ],
  "correct_answer": "A",
  "subject": "mathematics"
}
```

```json
{
  "question_text": "Which is the balanced equation for the combustion of hydrogen?",
  "options": [
    {"label": "A", "text": "$\\ce{H2 + O2 -> H2O}$"},
    {"label": "B", "text": "$\\ce{2H2 + O2 -> 2H2O}$"},
    {"label": "C", "text": "$\\ce{H2 + 2O2 -> 2H2O}$"},
    {"label": "D", "text": "$\\ce{H2 + O -> H2O}$"}
  ],
  "correct_answer": "B",
  "subject": "chemistry"
}
```

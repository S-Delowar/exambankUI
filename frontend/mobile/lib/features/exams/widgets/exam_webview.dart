import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/models/question.dart';

/// Renders the full list of [Question]s inside a **single** WebView using
/// KaTeX (with the mhchem extension) for all math, including `\ce{…}`
/// chemistry notation that `flutter_math_fork` could not handle.
///
/// Architecture note: one WebView for all questions is intentional.
/// Having N WebViews inside a ListView is extremely heavy on memory and
/// frame-rate; a single scrollable WebView is the standard approach used
/// by content-heavy education apps.
class ExamWebView extends StatefulWidget {
  final List<Question> questions;

  const ExamWebView({super.key, required this.questions});

  @override
  State<ExamWebView> createState() => _ExamWebViewState();
}

class _ExamWebViewState extends State<ExamWebView> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          if (mounted) setState(() => _loading = false);
        },
        // Block external navigations (e.g. accidental link taps).
        onNavigationRequest: (req) => req.url.startsWith('data:') ||
                req.url.startsWith('about:') ||
                req.url.startsWith('https://cdn.jsdelivr.net')
            ? NavigationDecision.navigate
            : NavigationDecision.prevent,
      ))
      ..loadHtmlString(_buildFullHtml(widget.questions));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_loading)
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  // ── HTML generation ────────────────────────────────────────────────────────

  static const List<String> _subjectOrder = [
    'physics',
    'chemistry',
    'mathematics',
    'biology',
  ];

  static int _compareQuestionNumber(String a, String b) {
    final ai = int.tryParse(a.replaceAll(RegExp(r'[^0-9]'), ''));
    final bi = int.tryParse(b.replaceAll(RegExp(r'[^0-9]'), ''));
    if (ai != null && bi != null && ai != bi) return ai.compareTo(bi);
    return a.compareTo(b);
  }

  static int _subjectRank(String? subject) {
    if (subject == null) return _subjectOrder.length + 1;
    final idx = _subjectOrder.indexOf(subject.toLowerCase());
    return idx == -1 ? _subjectOrder.length : idx;
  }

  static String _buildFullHtml(List<Question> questions) {
    final sorted = [...questions]..sort((a, b) {
        final ra = _subjectRank(a.subject);
        final rb = _subjectRank(b.subject);
        if (ra != rb) return ra.compareTo(rb);
        final sa = (a.subject ?? '').toLowerCase();
        final sb = (b.subject ?? '').toLowerCase();
        if (sa != sb) return sa.compareTo(sb);
        return _compareQuestionNumber(a.questionNumber, b.questionNumber);
      });

    final body = StringBuffer();
    String? lastSubjectKey;
    String? lastChapter;
    for (final q in sorted) {
      final subjectKey = (q.subject ?? '').toLowerCase();
      if (subjectKey != lastSubjectKey) {
        body.write(_subjectHeader(q.subject));
        lastSubjectKey = subjectKey;
        lastChapter = null;
      }
      final chapter = q.chapter?.trim();
      if (chapter != null && chapter.isNotEmpty && chapter != lastChapter) {
        body.write(_chapterHeader(chapter));
        lastChapter = chapter;
      }
      body.write(_questionCard(q));
    }

    return '''<!DOCTYPE html>
<html lang="bn">
<head>
  <meta charset="UTF-8">
  <meta name="viewport"
        content="width=device-width, initial-scale=1.0, user-scalable=no">

  <!-- KaTeX core CSS -->
  <link rel="stylesheet"
        href="https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/katex.min.css"
        crossorigin="anonymous">

  <!-- KaTeX JS core — must load before mhchem & auto-render -->
  <script defer
    src="https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/katex.min.js"
    crossorigin="anonymous"></script>

  <!-- mhchem extension — adds \\ce{} support for chemistry equations -->
  <script defer
    src="https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/contrib/mhchem.min.js"
    crossorigin="anonymous"></script>

  <!-- auto-render — scans the DOM and renders all \$…\$ and \$\$…\$\$ -->
  <script defer
    src="https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/contrib/auto-render.min.js"
    crossorigin="anonymous"
    onload="renderMathInElement(document.body, {
      delimiters: [
        {left: '\$\$', right: '\$\$', display: true},
        {left: '\$',   right: '\$',   display: false}
      ],
      throwOnError: false
    });"></script>

  <style>
    *, *::before, *::after {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }

    body {
      font-family: system-ui, -apple-system, 'Segoe UI', sans-serif;
      background: #f2f4f7;
      padding: 16px;
      color: #1a1a1a;
      /* Prevent iOS font inflation */
      -webkit-text-size-adjust: 100%;
    }

    /* ── Question card ─────────────────────────────────────────────────── */
    .card {
      background: #ffffff;
      border-radius: 12px;
      padding: 16px;
      margin-bottom: 20px;
      box-shadow: 0 1px 4px rgba(0,0,0,0.09);
    }

    .q-header {
      display: flex;
      align-items: flex-start;
      gap: 10px;
      margin-bottom: 14px;
    }

    .q-num {
      background: #e8eaf6;
      color: #3949ab;
      font-weight: 700;
      font-size: 13px;
      padding: 3px 8px;
      border-radius: 6px;
      white-space: nowrap;
      flex-shrink: 0;
      margin-top: 2px;
    }

    .q-text {
      font-size: 16px;
      line-height: 1.65;
    }

    /* ── Option rows ────────────────────────────────────────────────────── */
    .option {
      display: flex;
      align-items: flex-start;
      gap: 10px;
      padding: 10px 12px;
      border: 1px solid #e0e0e0;
      border-radius: 8px;
      margin-bottom: 8px;
    }

    .option.correct {
      background: rgba(76, 175, 80, 0.10);
      border: 1.5px solid #4caf50;
    }

    .opt-label {
      width: 28px;
      height: 28px;
      border-radius: 50%;
      background: #eeeeee;
      display: flex;
      align-items: center;
      justify-content: center;
      font-weight: 700;
      font-size: 13px;
      color: #333;
      flex-shrink: 0;
    }

    .option.correct .opt-label {
      background: #4caf50;
      color: #ffffff;
    }

    .opt-text {
      font-size: 15px;
      line-height: 1.55;
      flex: 1;
      min-width: 0;
      word-break: break-word;
    }

    .opt-check {
      color: #4caf50;
      font-size: 18px;
      font-weight: bold;
      flex-shrink: 0;
      padding-left: 4px;
      align-self: center;
    }

    /* ── Correct-answer badge ───────────────────────────────────────────── */
    .correct-badge {
      display: flex;
      align-items: center;
      gap: 6px;
      color: #2e7d32;
      font-weight: 600;
      font-size: 14px;
      margin-top: 10px;
    }

    .correct-badge svg { flex-shrink: 0; }

    /* ── Subject header ────────────────────────────────────────────────── */
    .subject-header {
      font-size: 20px;
      font-weight: 800;
      color: #ffffff;
      background: linear-gradient(135deg, #3949ab, #5c6bc0);
      padding: 14px 18px;
      border-radius: 10px;
      margin: 8px 0 16px;
      letter-spacing: 0.3px;
      text-transform: uppercase;
      box-shadow: 0 2px 6px rgba(57, 73, 171, 0.25);
    }

    /* ── Chapter header ────────────────────────────────────────────────── */
    .chapter-header {
      font-size: 15px;
      font-weight: 700;
      color: #3949ab;
      background: #e8eaf6;
      border-left: 4px solid #3949ab;
      padding: 8px 12px;
      border-radius: 6px;
      margin-bottom: 12px;
    }

    /* ── KaTeX size normalisation ───────────────────────────────────────── */
    /* Keep rendered math the same size as surrounding prose */
    .katex        { font-size: 1em !important; }
    .katex-display { margin: 0.35em 0; }
  </style>
</head>
<body>
${body.toString()}
</body>
</html>''';
  }

  static String _subjectHeader(String? subject) {
    final label = (subject == null || subject.isEmpty)
        ? 'Unknown'
        : subject
            .split('_')
            .map((s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1))
            .join(' ');
    return '  <div class="subject-header">${_esc(label)}</div>\n';
  }

  static String _chapterHeader(String chapter) =>
      '  <div class="chapter-header">${_esc(chapter)}</div>\n';

  static String _questionCard(Question q) {
    final optionRows = q.options.map((o) {
      final isCorrect = q.correctAnswer != null &&
          o.label.trim().toLowerCase() ==
              q.correctAnswer!.trim().toLowerCase();

      final checkMark =
          isCorrect ? '<span class="opt-check">&#10003;</span>' : '';

      return '''    <div class="option${isCorrect ? ' correct' : ''}">
      <div class="opt-label">${_esc(o.label)}</div>
      <div class="opt-text">${_esc(o.text)}</div>
      $checkMark
    </div>''';
    }).join('\n');

    final badge = q.correctAnswer != null
        ? '''    <div class="correct-badge">
      <!-- Filled check-circle icon (inline SVG — no network request) -->
      <svg width="16" height="16" viewBox="0 0 24 24" fill="#4caf50">
        <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10
                 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5
                 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>
      </svg>
      Correct answer: ${_esc(q.correctAnswer!)}
    </div>'''
        : '';

    return '''  <div class="card">
    <div class="q-header">
      <span class="q-num">${_esc(q.questionNumber)}</span>
      <span class="q-text">${_esc(q.questionText)}</span>
    </div>
$optionRows
$badge
  </div>

''';
  }

  /// Minimal HTML escaping for text-node content that contains LaTeX.
  ///
  /// **Why this is safe for KaTeX:** KaTeX's `auto-render` reads each
  /// element's `textContent` (already decoded by the browser's HTML parser),
  /// not the raw HTML. So `&lt;`, `&gt;`, `&amp;` are decoded back to
  /// `<`, `>`, `&` *before* KaTeX processes them — the LaTeX is intact.
  ///
  /// This means `\ce{Cl2(g) + 2NaOH(aq) -> ...}` stored as
  /// `\ce{Cl2(g) + 2NaOH(aq) -&gt; ...}` in the HTML will render
  /// correctly because the browser hands KaTeX `->`, not `&gt;`.
  static String _esc(String s) => s
      .replaceAll('&', '&amp;') // must be first
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
}

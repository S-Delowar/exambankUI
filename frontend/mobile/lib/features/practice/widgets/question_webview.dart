import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Renders a single question stem with KaTeX + mhchem in a small WebView.
/// Reports its content height back to Flutter so the parent can size the box.
class QuestionWebView extends StatefulWidget {
  final String text;
  final double minHeight;

  const QuestionWebView({
    super.key,
    required this.text,
    this.minHeight = 48,
  });

  @override
  State<QuestionWebView> createState() => _QuestionWebViewState();
}

class _QuestionWebViewState extends State<QuestionWebView> {
  late final WebViewController _controller;
  double _height = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel(
        'HeightChannel',
        onMessageReceived: (m) {
          final h = double.tryParse(m.message);
          if (h != null && mounted) {
            setState(() => _height = h);
          }
        },
      )
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (req) => req.url.startsWith('data:') ||
                req.url.startsWith('about:') ||
                req.url.startsWith('https://cdn.jsdelivr.net')
            ? NavigationDecision.navigate
            : NavigationDecision.prevent,
      ))
      ..loadHtmlString(_buildHtml(widget.text));
  }

  @override
  void didUpdateWidget(covariant QuestionWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _height = 0;
      _controller.loadHtmlString(_buildHtml(widget.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = _height == 0 ? widget.minHeight : _height;
    return SizedBox(
      height: h,
      child: WebViewWidget(controller: _controller),
    );
  }

  String _buildHtml(String text) {
    final esc = text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
    return '''<!DOCTYPE html>
<html><head><meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/katex.min.css">
<script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/katex.min.js"></script>
<script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/contrib/mhchem.min.js"></script>
<script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/contrib/auto-render.min.js"
  onload="renderMathInElement(document.body,{delimiters:[{left:'\$\$',right:'\$\$',display:true},{left:'\$',right:'\$',display:false}],throwOnError:false});setTimeout(reportHeight,60);"></script>
<style>
  body { margin: 0; padding: 4px 0; font-family: system-ui, sans-serif; font-size: 16px; line-height: 1.6; color: #1a1a1a; background: transparent; -webkit-text-size-adjust: 100%; }
  .katex { font-size: 1em !important; }
</style>
<script>
  function reportHeight() {
    var h = document.body.scrollHeight;
    if (window.HeightChannel) HeightChannel.postMessage(String(h));
  }
  window.addEventListener('load', function(){ setTimeout(reportHeight, 120); });
</script>
</head>
<body>$esc</body></html>''';
  }
}

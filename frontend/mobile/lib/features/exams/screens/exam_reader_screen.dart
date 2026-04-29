import 'package:flutter/material.dart';

import '../../../core/models/question.dart';
import '../widgets/exam_webview.dart';

class ExamReaderScreen extends StatelessWidget {
  final List<Question> questions;
  const ExamReaderScreen({super.key, required this.questions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reader')),
      body: ExamWebView(questions: questions),
    );
  }
}

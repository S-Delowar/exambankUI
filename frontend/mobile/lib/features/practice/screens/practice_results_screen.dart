import 'package:flutter/material.dart';

import '../../../core/models/attempt.dart';
import '../../../core/theme/subject_colors.dart';
import '../../../core/widgets/progress_ring.dart';

class PracticeResultsScreen extends StatelessWidget {
  final AttemptResult result;

  const PracticeResultsScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final accuracy = result.scoreTotal == 0
        ? 0.0
        : result.scoreCorrect / result.scoreTotal;
    final elapsed = Duration(seconds: result.elapsedSec);
    final elapsedLabel =
        '${elapsed.inMinutes}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context)
              .popUntil((route) => route.isFirst),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: ProgressRing(
              value: accuracy,
              size: 160,
              stroke: 14,
              centerLabel: '${result.scoreCorrect}/${result.scoreTotal}',
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              '${(accuracy * 100).round()}% accuracy',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'Time: $elapsedLabel',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 28),
          if (result.bySubject.isNotEmpty) ...[
            Text('By subject',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...result.bySubject.map(_subjectRow),
            const SizedBox(height: 20),
          ],
          if (result.byChapter.isNotEmpty) ...[
            Text('By chapter',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...result.byChapter.map(_chapterRow),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton(
            onPressed: () => Navigator.of(context)
                .popUntil((route) => route.isFirst),
            child: const Text('Done'),
          ),
        ),
      ),
    );
  }

  Widget _subjectRow(SubjectStat s) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: SubjectColors.of(s.subject),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(SubjectColors.prettyLabel(s.subject))),
            Text('${s.correct}/${s.attempted} · ${(s.accuracy * 100).round()}%'),
          ],
        ),
      );

  Widget _chapterRow(ChapterStat c) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${SubjectColors.prettyLabel(c.subject)} — ${SubjectColors.prettyLabel(c.chapter)}',
                style: const TextStyle(fontSize: 13),
              ),
            ),
            Text(
              '${c.correct}/${c.attempted}',
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      );
}

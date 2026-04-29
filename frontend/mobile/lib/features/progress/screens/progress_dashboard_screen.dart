import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/attempt.dart';
import '../../../core/theme/subject_colors.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/progress_ring.dart';
import '../providers/progress_provider.dart';

class ProgressDashboardScreen extends StatefulWidget {
  const ProgressDashboardScreen({super.key});

  @override
  State<ProgressDashboardScreen> createState() => _State();
}

class _State extends State<ProgressDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProgressProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: RefreshIndicator(
        onRefresh: () => p.load(force: true),
        child: _body(p),
      ),
    );
  }

  Widget _body(ProgressProvider p) {
    if (p.loading && p.summary == null) return const LoadingView();
    if (p.error != null && p.summary == null) {
      return ErrorView(error: p.error, onRetry: () => p.load(force: true));
    }
    final s = p.summary;
    if (s == null) {
      return const EmptyView(
        icon: Icons.insights_outlined,
        title: 'No progress yet',
        message: 'Start a practice or drill to see your stats.',
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            ProgressRing(
              value: s.overallAccuracy,
              size: 120,
              stroke: 11,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _stat('Streak', '${s.streakDays} day${s.streakDays == 1 ? "" : "s"}'),
                  const SizedBox(height: 6),
                  _stat('Attempts', '${s.totalAttempts}'),
                  const SizedBox(height: 6),
                  _stat(
                    'Weekly accuracy',
                    '${(s.weeklyAccuracy * 100).round()}%',
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (s.bySubject.isNotEmpty) ...[
          Text('By subject', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...s.bySubject.map(_subjectBar),
          const SizedBox(height: 20),
        ],
        if (s.byChapter.isNotEmpty) ...[
          Text('By chapter', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...s.byChapter.map(_chapterRow),
        ],
      ],
    );
  }

  Widget _stat(String label, String value) => Row(
        children: [
          Text('$label:',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
          const SizedBox(width: 6),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 15)),
        ],
      );

  Widget _subjectBar(SubjectStat s) {
    final color = SubjectColors.of(s.subject);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(SubjectColors.prettyLabel(s.subject),
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('${(s.accuracy * 100).round()}%'),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: s.accuracy.clamp(0, 1),
              valueColor: AlwaysStoppedAnimation(color),
              backgroundColor: color.withValues(alpha: 0.15),
              minHeight: 8,
            ),
          ),
          Text(
            '${s.correct}/${s.attempted}',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

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
            Text('${c.correct}/${c.attempted}',
                style: const TextStyle(fontSize: 13)),
          ],
        ),
      );
}

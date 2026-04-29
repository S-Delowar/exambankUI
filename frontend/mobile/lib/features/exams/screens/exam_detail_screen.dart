import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api/api_client.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/subject_chip.dart';
import '../../practice/screens/practice_session_screen.dart';
import '../providers/exam_detail_provider.dart';
import '../repository/exam_repository.dart';
import 'exam_reader_screen.dart';

class ExamDetailScreen extends StatelessWidget {
  final String paperId;
  const ExamDetailScreen({super.key, required this.paperId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => ExamDetailProvider(
        ctx.read<ExamRepository>(),
        ctx.read<ApiClient>(),
        paperId: paperId,
      )..load(),
      child: const _DetailBody(),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ExamDetailProvider>();
    if (p.loading && p.paper == null) {
      return const Scaffold(body: LoadingView());
    }
    if (p.error != null && p.paper == null) {
      return Scaffold(
        appBar: AppBar(),
        body: ErrorView(error: p.error, onRetry: p.load),
      );
    }
    final paper = p.paper;
    if (paper == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Not found')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(paper.universityName ?? 'Exam')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            paper.displayTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(paper.displaySubtitle,
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          if (paper.chapterCounts != null &&
              paper.chapterCounts!.isNotEmpty) ...[
            Text('Chapters',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: paper.chapterCounts!.entries
                  .map((e) => Chip(
                        avatar: SubjectChip(subject: null),
                        label: Text('${e.key} · ${e.value}'),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
          ],
          FilledButton.icon(
            onPressed: p.questions.isEmpty
                ? null
                : () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ExamReaderScreen(questions: p.questions),
                      ),
                    ),
            icon: const Icon(Icons.menu_book_outlined),
            label: const Text('Read through'),
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: p.questions.isEmpty
                ? null
                : () => _pickPracticeMode(context, paperId: paper.id),
            icon: const Icon(Icons.quiz_outlined),
            label: const Text('Practice'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPracticeMode(BuildContext context,
      {required String paperId}) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('Untimed'),
              subtitle: const Text('Practice at your own pace'),
              onTap: () => Navigator.of(ctx).pop('untimed'),
            ),
            ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: const Text('Timed'),
              subtitle: const Text('60 minutes, auto-submit'),
              onTap: () => Navigator.of(ctx).pop('timed'),
            ),
          ],
        ),
      ),
    );
    if (choice == null || !context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PracticeSessionScreen(
          kind: 'exam',
          paperId: paperId,
          mode: choice,
          durationSec: choice == 'timed' ? 3600 : null,
        ),
      ),
    );
  }
}

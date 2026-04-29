import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api/api_client.dart';
import '../../../core/models/question.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/timer_pill.dart';
import '../../exams/repository/exam_repository.dart';
import '../providers/practice_session_provider.dart';
import '../repository/practice_repository.dart';
import '../widgets/question_card.dart';
import 'practice_results_screen.dart';

class PracticeSessionScreen extends StatelessWidget {
  final String kind; // 'exam' or 'drill'
  final String mode; // 'timed' or 'untimed'
  final String? paperId;
  final String? drillSubject;
  final String? drillChapter;
  final int? drillCount;
  final int? durationSec;
  final List<Question>? preloadedQuestions;

  const PracticeSessionScreen({
    super.key,
    required this.kind,
    required this.mode,
    this.paperId,
    this.drillSubject,
    this.drillChapter,
    this.drillCount,
    this.durationSec,
    this.preloadedQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => PracticeSessionProvider(
        ctx.read<PracticeRepository>(),
        ctx.read<ExamRepository>(),
        ctx.read<ApiClient>(),
      )..start(
          kind: kind,
          mode: mode,
          paperId: paperId,
          drillSubject: drillSubject,
          drillChapter: drillChapter,
          drillCount: drillCount,
          durationSec: durationSec,
          preloadedQuestions: preloadedQuestions,
        ),
      child: const _SessionBody(),
    );
  }
}

class _SessionBody extends StatelessWidget {
  const _SessionBody();

  @override
  Widget build(BuildContext context) {
    final s = context.watch<PracticeSessionProvider>();

    if (s.status == SessionStatus.loading) {
      return const Scaffold(body: LoadingView(label: 'Preparing session…'));
    }
    if (s.status == SessionStatus.error) {
      return Scaffold(
        appBar: AppBar(),
        body: ErrorView(error: s.error),
      );
    }
    if (s.status == SessionStatus.completed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => PracticeResultsScreen(result: s.result!),
          ),
        );
      });
      return const Scaffold(body: LoadingView());
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Leave practice?'),
            content: const Text(
              'Your progress will be lost if you leave before submitting.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Stay'),
              ),
              FilledButton.tonal(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Leave'),
              ),
            ],
          ),
        );
        if (leave == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Q ${s.currentIndex + 1}/${s.total}'),
          actions: [
            if (s.remaining != null) ...[
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Center(child: TimerPill(remaining: s.remaining!)),
              ),
            ],
          ],
        ),
        body: Column(
          children: [
            LinearProgressIndicator(
              value: (s.currentIndex + 1) / s.total,
              minHeight: 3,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: const QuestionCard(),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Row(
                  children: [
                    FilledButton.tonal(
                      onPressed: s.isFirst ? null : s.previous,
                      child: const Text('Previous'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: s.isLast
                          ? FilledButton(
                              onPressed: () => _confirmSubmit(context, s),
                              child: Text('Submit (${s.answeredCount}/${s.total})'),
                            )
                          : FilledButton(
                              onPressed: s.next,
                              child: const Text('Next'),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmSubmit(
      BuildContext context, PracticeSessionProvider s) async {
    final skipped = s.total - s.answeredCount;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit?'),
        content: Text(
          skipped == 0
              ? 'Submit your answers and see your results?'
              : '$skipped question${skipped == 1 ? "" : "s"} not answered. Submit anyway?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await s.submit();
    }
  }
}

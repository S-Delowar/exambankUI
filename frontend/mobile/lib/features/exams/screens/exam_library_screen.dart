import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api/api_client.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../providers/exam_list_provider.dart';
import '../repository/exam_repository.dart';
import '../widgets/exam_card.dart';
import 'exam_detail_screen.dart';

class ExamLibraryScreen extends StatelessWidget {
  const ExamLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => ExamListProvider(
        ctx.read<ExamRepository>(),
        ctx.read<ApiClient>(),
      )..load(),
      child: const _LibraryBody(),
    );
  }
}

class _LibraryBody extends StatelessWidget {
  const _LibraryBody();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ExamListProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Exam library')),
      body: RefreshIndicator(
        onRefresh: () => p.load(forceRefresh: true),
        child: _content(context, p),
      ),
    );
  }

  Widget _content(BuildContext context, ExamListProvider p) {
    if (p.loading && p.papers.isEmpty) {
      return const LoadingView(label: 'Loading exams…');
    }
    if (p.error != null && p.papers.isEmpty) {
      return ErrorView(
        error: p.error,
        onRetry: () => p.load(forceRefresh: true),
      );
    }
    if (p.papers.isEmpty) {
      return const EmptyView(
        icon: Icons.library_books_outlined,
        title: 'No exams yet',
        message: 'Papers will appear here once imported.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: p.papers.length,
      itemBuilder: (_, i) {
        final paper = p.papers[i];
        return ExamCard(
          paper: paper,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ExamDetailScreen(paperId: paper.id),
            ),
          ),
        );
      },
    );
  }
}

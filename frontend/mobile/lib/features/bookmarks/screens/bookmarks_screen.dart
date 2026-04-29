import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/subject_chip.dart';
import '../providers/bookmark_provider.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookmarkProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bm = context.watch<BookmarkProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: RefreshIndicator(
        onRefresh: bm.load,
        child: _content(bm),
      ),
    );
  }

  Widget _content(BookmarkProvider bm) {
    if (bm.loading && bm.all.isEmpty) return const LoadingView();
    if (bm.error != null && bm.all.isEmpty) {
      return ErrorView(error: bm.error, onRetry: bm.load);
    }
    if (bm.all.isEmpty) {
      return const EmptyView(
        icon: Icons.bookmark_border,
        title: 'No bookmarks yet',
        message: 'Tap the bookmark icon on any question to save it.',
      );
    }
    return ListView.separated(
      itemCount: bm.all.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final b = bm.all[i];
        return Dismissible(
          key: ValueKey(b.questionId),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Theme.of(context).colorScheme.errorContainer,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete_outline),
          ),
          onDismissed: (_) => bm.toggle(b.questionId),
          child: ListTile(
            leading: SubjectChip(subject: b.question.subject),
            title: Text(
              b.question.questionText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text('Q ${b.question.questionNumber}'),
          ),
        );
      },
    );
  }
}

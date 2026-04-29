import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/subject_chip.dart';
import '../../bookmarks/providers/bookmark_provider.dart';
import '../providers/practice_session_provider.dart';
import 'option_tile.dart';
import 'question_webview.dart';
import 'solution_sheet.dart';

class QuestionCard extends StatelessWidget {
  const QuestionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<PracticeSessionProvider>();
    final bm = context.watch<BookmarkProvider>();
    final q = s.current;
    final selected = s.selectedLabel(q.id);
    final revealed = s.revealed(q.id);
    final correct = s.correctFor(q.id);
    final isBookmarked = bm.isBookmarked(q.id);

    OptionState stateFor(String label) {
      if (!revealed) {
        return (selected == label) ? OptionState.selected : OptionState.idle;
      }
      final isCorrect = correct != null &&
          label.trim().toLowerCase() == correct.trim().toLowerCase();
      if (label == selected) {
        return isCorrect ? OptionState.revealedCorrect : OptionState.revealedWrong;
      }
      return isCorrect ? OptionState.revealedCorrect : OptionState.revealedOther;
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    q.questionNumber,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SubjectChip(subject: q.subject),
                const Spacer(),
                IconButton(
                  onPressed: () => bm.toggle(q.id),
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            QuestionWebView(text: q.questionText),
            const SizedBox(height: 12),
            ...q.options.map(
              (o) => OptionTile(
                label: o.label,
                text: o.text,
                state: stateFor(o.label),
                onTap: revealed ? null : () => s.selectOption(o.label),
              ),
            ),
            if (revealed) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (correct != null)
                    Text(
                      'Correct answer: $correct',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const Spacer(),
                  TextButton.icon(
                    icon: const Icon(Icons.lightbulb_outline),
                    label: const Text('Solution'),
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      showDragHandle: true,
                      isScrollControlled: true,
                      builder: (_) => SolutionSheet(
                        solution: q.solution,
                        solutionStatus: q.solutionStatus,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

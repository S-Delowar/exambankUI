import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/subject_colors.dart';
import '../../../core/utils/chapter_taxonomy.dart';
import '../../../core/widgets/error_view.dart';
import '../../practice/screens/practice_session_screen.dart';
import '../providers/drill_provider.dart';

class DrillSelectorScreen extends StatefulWidget {
  const DrillSelectorScreen({super.key});

  @override
  State<DrillSelectorScreen> createState() => _DrillSelectorScreenState();
}

class _DrillSelectorScreenState extends State<DrillSelectorScreen> {
  ChapterTaxonomy? _taxonomy;
  Object? _loadErr;

  @override
  void initState() {
    super.initState();
    ChapterTaxonomy.load().then((t) {
      if (mounted) setState(() => _taxonomy = t);
    }).catchError((e) {
      if (mounted) setState(() => _loadErr = e);
    });
  }

  @override
  Widget build(BuildContext context) {
    final d = context.watch<DrillProvider>();

    if (_loadErr != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Topic drill')),
        body: ErrorView(message: 'Could not load chapters: $_loadErr'),
      );
    }
    final t = _taxonomy;
    if (t == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Topic drill')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final chapters = d.subject == null ? const <String>[] : t.chaptersOf(d.subject!);

    return Scaffold(
      appBar: AppBar(title: const Text('Topic drill')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Subject', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: t.subjects.map((s) {
              final selected = d.subject == s;
              return ChoiceChip(
                label: Text(SubjectColors.prettyLabel(s)),
                selected: selected,
                onSelected: (_) => d.setSubject(selected ? null : s),
                avatar: CircleAvatar(
                  backgroundColor: SubjectColors.of(s),
                  radius: 6,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          if (d.subject != null) ...[
            Text('Chapter', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...chapters.map((c) {
              return RadioListTile<String>(
                value: c,
                groupValue: d.chapter,
                title: Text(SubjectColors.prettyLabel(c)),
                onChanged: (v) => d.setChapter(v),
                contentPadding: EdgeInsets.zero,
                dense: true,
              );
            }),
            const SizedBox(height: 20),
            Text('Number of questions',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [10, 20, 50].map((n) {
                return ChoiceChip(
                  label: Text('$n'),
                  selected: d.count == n,
                  onSelected: (_) => d.setCount(n),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: (d.subject == null ||
                      d.chapter == null ||
                      d.loading)
                  ? null
                  : () async {
                      final qs = await d.fetch();
                      if (!context.mounted || qs == null || qs.isEmpty) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PracticeSessionScreen(
                            kind: 'drill',
                            mode: 'untimed',
                            drillSubject: d.subject!,
                            drillChapter: d.chapter!,
                            drillCount: d.count,
                            preloadedQuestions: qs,
                          ),
                        ),
                      );
                    },
              icon: d.loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow),
              label: const Text('Start drill'),
            ),
            if (d.error != null) ...[
              const SizedBox(height: 12),
              Text(
                d.error!.message,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

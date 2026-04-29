import 'attempt.dart';

class ProgressSummary {
  final int streakDays;
  final int totalAttempts;
  final int totalQuestions;
  final int totalCorrect;
  final double weeklyAccuracy;
  final List<SubjectStat> bySubject;
  final List<ChapterStat> byChapter;

  const ProgressSummary({
    required this.streakDays,
    required this.totalAttempts,
    required this.totalQuestions,
    required this.totalCorrect,
    required this.weeklyAccuracy,
    required this.bySubject,
    required this.byChapter,
  });

  double get overallAccuracy =>
      totalQuestions == 0 ? 0.0 : totalCorrect / totalQuestions;

  factory ProgressSummary.fromJson(Map<String, dynamic> j) => ProgressSummary(
        streakDays: (j['streak_days'] as num).toInt(),
        totalAttempts: (j['total_attempts'] as num).toInt(),
        totalQuestions: (j['total_questions'] as num).toInt(),
        totalCorrect: (j['total_correct'] as num).toInt(),
        weeklyAccuracy: (j['weekly_accuracy'] as num).toDouble(),
        bySubject: ((j['by_subject'] as List?) ?? const [])
            .map((e) => SubjectStat.fromJson(e as Map<String, dynamic>))
            .toList(),
        byChapter: ((j['by_chapter'] as List?) ?? const [])
            .map((e) => ChapterStat.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

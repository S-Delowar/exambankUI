class Attempt {
  final String id;
  final String kind; // 'exam' | 'drill'
  final String mode; // 'timed' | 'untimed'
  final String? paperId;
  final String? drillSubject;
  final String? drillChapter;
  final String status; // 'in_progress' | 'submitted' | 'abandoned'
  final DateTime startedAt;
  final DateTime? submittedAt;
  final int? scoreCorrect;
  final int? scoreTotal;
  final List<String> questionIds;

  const Attempt({
    required this.id,
    required this.kind,
    required this.mode,
    required this.status,
    required this.startedAt,
    this.paperId,
    this.drillSubject,
    this.drillChapter,
    this.submittedAt,
    this.scoreCorrect,
    this.scoreTotal,
    this.questionIds = const [],
  });

  factory Attempt.fromJson(Map<String, dynamic> j) => Attempt(
        id: j['id'] as String,
        kind: j['kind'] as String,
        mode: j['mode'] as String,
        paperId: j['paper_id'] as String?,
        drillSubject: j['drill_subject'] as String?,
        drillChapter: j['drill_chapter'] as String?,
        status: j['status'] as String,
        startedAt: DateTime.parse(j['started_at'] as String),
        submittedAt: j['submitted_at'] == null
            ? null
            : DateTime.parse(j['submitted_at'] as String),
        scoreCorrect: (j['score_correct'] as num?)?.toInt(),
        scoreTotal: (j['score_total'] as num?)?.toInt(),
        questionIds: ((j['question_ids'] as List?) ?? const [])
            .map((e) => e as String)
            .toList(),
      );
}

class AttemptAnswerRecord {
  final String questionId;
  final String selectedLabel;
  final bool isCorrect;
  final DateTime answeredAt;

  const AttemptAnswerRecord({
    required this.questionId,
    required this.selectedLabel,
    required this.isCorrect,
    required this.answeredAt,
  });

  factory AttemptAnswerRecord.fromJson(Map<String, dynamic> j) =>
      AttemptAnswerRecord(
        questionId: j['question_id'] as String,
        selectedLabel: j['selected_label'] as String,
        isCorrect: j['is_correct'] as bool,
        answeredAt: DateTime.parse(j['answered_at'] as String),
      );
}

class SubjectStat {
  final String subject;
  final int attempted;
  final int correct;
  final double accuracy;

  const SubjectStat({
    required this.subject,
    required this.attempted,
    required this.correct,
    required this.accuracy,
  });

  factory SubjectStat.fromJson(Map<String, dynamic> j) => SubjectStat(
        subject: j['subject'] as String,
        attempted: (j['attempted'] as num).toInt(),
        correct: (j['correct'] as num).toInt(),
        accuracy: (j['accuracy'] as num).toDouble(),
      );
}

class ChapterStat {
  final String subject;
  final String chapter;
  final int attempted;
  final int correct;
  final double accuracy;

  const ChapterStat({
    required this.subject,
    required this.chapter,
    required this.attempted,
    required this.correct,
    required this.accuracy,
  });

  factory ChapterStat.fromJson(Map<String, dynamic> j) => ChapterStat(
        subject: j['subject'] as String,
        chapter: j['chapter'] as String,
        attempted: (j['attempted'] as num).toInt(),
        correct: (j['correct'] as num).toInt(),
        accuracy: (j['accuracy'] as num).toDouble(),
      );
}

class AttemptResult {
  final String id;
  final int scoreCorrect;
  final int scoreTotal;
  final int elapsedSec;
  final List<SubjectStat> bySubject;
  final List<ChapterStat> byChapter;

  const AttemptResult({
    required this.id,
    required this.scoreCorrect,
    required this.scoreTotal,
    required this.elapsedSec,
    required this.bySubject,
    required this.byChapter,
  });

  factory AttemptResult.fromJson(Map<String, dynamic> j) {
    final breakdown = (j['breakdown'] as Map<String, dynamic>);
    return AttemptResult(
      id: j['id'] as String,
      scoreCorrect: (j['score_correct'] as num).toInt(),
      scoreTotal: (j['score_total'] as num).toInt(),
      elapsedSec: (j['elapsed_sec'] as num).toInt(),
      bySubject: ((breakdown['by_subject'] as List?) ?? const [])
          .map((e) => SubjectStat.fromJson(e as Map<String, dynamic>))
          .toList(),
      byChapter: ((breakdown['by_chapter'] as List?) ?? const [])
          .map((e) => ChapterStat.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

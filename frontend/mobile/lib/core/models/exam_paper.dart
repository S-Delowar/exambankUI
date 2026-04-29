class ExamPaper {
  final String id;
  final String sourceFilename;
  final String? universityName;
  final String? examSession;
  final String? examUnit;
  final int pageCount;
  final int questionCount;
  final Map<String, int>? chapterCounts;

  const ExamPaper({
    required this.id,
    required this.sourceFilename,
    required this.pageCount,
    required this.questionCount,
    this.universityName,
    this.examSession,
    this.examUnit,
    this.chapterCounts,
  });

  factory ExamPaper.fromJson(Map<String, dynamic> j) => ExamPaper(
        id: j['id'] as String,
        sourceFilename: j['source_filename'] as String,
        universityName: j['university_name'] as String?,
        examSession: j['exam_session'] as String?,
        examUnit: j['exam_unit'] as String?,
        pageCount: (j['page_count'] as num).toInt(),
        questionCount: (j['question_count'] as num).toInt(),
        chapterCounts: (j['chapter_counts'] as Map?)
            ?.map((k, v) => MapEntry(k as String, (v as num).toInt())),
      );

  String get displayTitle =>
      '${universityName ?? "Unknown"} • ${examSession ?? "—"}';

  String get displaySubtitle =>
      'Unit ${examUnit ?? "?"} • $questionCount questions';
}

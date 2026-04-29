import 'question.dart';

class Bookmark {
  final String questionId;
  final DateTime createdAt;
  final Question question;

  const Bookmark({
    required this.questionId,
    required this.createdAt,
    required this.question,
  });

  factory Bookmark.fromJson(Map<String, dynamic> j) => Bookmark(
        questionId: j['question_id'] as String,
        createdAt: DateTime.parse(j['created_at'] as String),
        question: Question.fromJson(j['question'] as Map<String, dynamic>),
      );
}

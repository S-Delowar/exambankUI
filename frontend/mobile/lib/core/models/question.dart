class QuestionOption {
  final String label;
  final String text;

  const QuestionOption({required this.label, required this.text});

  factory QuestionOption.fromJson(Map<String, dynamic> j) => QuestionOption(
        label: j['label'] as String,
        text: j['text'] as String,
      );

  Map<String, dynamic> toJson() => {'label': label, 'text': text};
}

class Question {
  final String id;
  final String paperId;
  final String questionNumber;
  final String questionText;
  final String? subject;
  final String? chapter;
  final String? correctAnswer;
  final String? solution;
  final String solutionStatus;
  final bool hasImage;
  final List<QuestionOption> options;

  const Question({
    required this.id,
    required this.paperId,
    required this.questionNumber,
    required this.questionText,
    required this.options,
    this.subject,
    this.chapter,
    this.correctAnswer,
    this.solution,
    this.solutionStatus = 'pending',
    this.hasImage = false,
  });

  factory Question.fromJson(Map<String, dynamic> j) => Question(
        id: j['id'] as String,
        paperId: j['paper_id'] as String,
        questionNumber: j['question_number'] as String,
        questionText: j['question_text'] as String,
        subject: j['subject'] as String?,
        chapter: j['chapter'] as String?,
        correctAnswer: j['correct_answer'] as String?,
        solution: j['solution'] as String?,
        solutionStatus: j['solution_status'] as String? ?? 'pending',
        hasImage: j['has_image'] as bool? ?? false,
        options: ((j['options'] as List?) ?? const [])
            .map((o) => QuestionOption.fromJson(o as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'paper_id': paperId,
        'question_number': questionNumber,
        'question_text': questionText,
        'subject': subject,
        'chapter': chapter,
        'correct_answer': correctAnswer,
        'solution': solution,
        'solution_status': solutionStatus,
        'has_image': hasImage,
        'options': options.map((o) => o.toJson()).toList(),
      };
}

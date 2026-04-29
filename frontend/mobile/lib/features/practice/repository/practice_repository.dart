import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../../../core/models/attempt.dart';
import '../../../core/models/question.dart';

class PracticeStartResponse {
  final String attemptId;
  final List<String> questionIds;
  final DateTime startedAt;
  const PracticeStartResponse({
    required this.attemptId,
    required this.questionIds,
    required this.startedAt,
  });
}

class AnswerResponse {
  final bool isCorrect;
  final String? correctAnswer;
  const AnswerResponse({required this.isCorrect, this.correctAnswer});
}

class PracticeRepository {
  final ApiClient _api;
  PracticeRepository(this._api);

  Future<PracticeStartResponse> start({
    required String kind,
    required String mode,
    String? paperId,
    String? drillSubject,
    String? drillChapter,
    int? drillCount,
    int? durationSec,
  }) async {
    final body = <String, dynamic>{
      'kind': kind,
      'mode': mode,
      'paper_id': ?paperId,
      'duration_sec': ?durationSec,
    };
    if (drillSubject != null && drillChapter != null && drillCount != null) {
      body['drill'] = {
        'subject': drillSubject,
        'chapter': drillChapter,
        'count': drillCount,
      };
    }
    final resp = await _api.dio.post(Endpoints.attempts, data: body);
    final data = resp.data as Map<String, dynamic>;
    return PracticeStartResponse(
      attemptId: data['id'] as String,
      questionIds: ((data['question_ids'] as List?) ?? const [])
          .map((e) => e as String)
          .toList(),
      startedAt: DateTime.parse(data['started_at'] as String),
    );
  }

  Future<AnswerResponse> recordAnswer({
    required String attemptId,
    required String questionId,
    required String selectedLabel,
  }) async {
    final resp = await _api.dio.post(
      '${Endpoints.attempts}/$attemptId/answer',
      data: {'question_id': questionId, 'selected_label': selectedLabel},
    );
    final data = resp.data as Map<String, dynamic>;
    return AnswerResponse(
      isCorrect: data['is_correct'] as bool,
      correctAnswer: data['correct_answer'] as String?,
    );
  }

  Future<AttemptResult> submit(String attemptId) async {
    final resp = await _api.dio
        .post('${Endpoints.attempts}/$attemptId/submit', data: {});
    return AttemptResult.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<Question> getQuestion(String id) async {
    final resp = await _api.dio.get('${Endpoints.questions}/$id');
    return Question.fromJson(resp.data as Map<String, dynamic>);
  }
}

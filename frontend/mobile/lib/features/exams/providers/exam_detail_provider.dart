import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/models/api_result.dart';
import '../../../core/models/exam_paper.dart';
import '../../../core/models/question.dart';
import '../repository/exam_repository.dart';

class ExamDetailProvider extends ChangeNotifier {
  final ExamRepository _repo;
  final ApiClient _api;
  final String paperId;

  ExamDetailProvider(this._repo, this._api, {required this.paperId});

  ExamPaper? _paper;
  List<Question> _questions = const [];
  bool _loading = false;
  ApiError? _error;

  ExamPaper? get paper => _paper;
  List<Question> get questions => _questions;
  bool get loading => _loading;
  ApiError? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repo.getPaper(paperId),
        _repo.getQuestionsForPaper(paperId),
      ]);
      _paper = results[0] as ExamPaper?;
      _questions = results[1] as List<Question>;
    } catch (e) {
      _error = _api.mapError(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}

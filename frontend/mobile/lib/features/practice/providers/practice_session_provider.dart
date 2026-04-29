import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/models/api_result.dart';
import '../../../core/models/attempt.dart';
import '../../../core/models/question.dart';
import '../../exams/repository/exam_repository.dart';
import '../repository/practice_repository.dart';

enum SessionStatus { loading, inProgress, submitting, completed, error }

class PracticeSessionProvider extends ChangeNotifier {
  final PracticeRepository _repo;
  final ExamRepository _examRepo;
  final ApiClient _api;

  PracticeSessionProvider(this._repo, this._examRepo, this._api);

  String? _attemptId;
  List<Question> _questions = const [];
  int _currentIndex = 0;
  final Map<String, String> _selected = {};
  final Map<String, bool> _revealed = {};
  final Map<String, String> _correctByQ = {};

  Duration? _remaining;
  Timer? _timer;
  SessionStatus _status = SessionStatus.loading;
  AttemptResult? _result;
  ApiError? _error;

  SessionStatus get status => _status;
  List<Question> get questions => _questions;
  int get currentIndex => _currentIndex;
  Question get current => _questions[_currentIndex];
  Duration? get remaining => _remaining;
  AttemptResult? get result => _result;
  ApiError? get error => _error;

  String? selectedLabel(String qid) => _selected[qid];
  bool revealed(String qid) => _revealed[qid] ?? false;
  String? correctFor(String qid) => _correctByQ[qid] ?? current.correctAnswer;

  int get answeredCount => _selected.length;
  int get total => _questions.length;
  bool get isFirst => _currentIndex == 0;
  bool get isLast => _currentIndex >= _questions.length - 1;

  Future<void> start({
    required String kind,
    required String mode,
    String? paperId,
    String? drillSubject,
    String? drillChapter,
    int? drillCount,
    int? durationSec,
    List<Question>? preloadedQuestions,
  }) async {
    _status = SessionStatus.loading;
    notifyListeners();
    try {
      final started = await _repo.start(
        kind: kind,
        mode: mode,
        paperId: paperId,
        drillSubject: drillSubject,
        drillChapter: drillChapter,
        drillCount: drillCount,
        durationSec: durationSec,
      );
      _attemptId = started.attemptId;

      if (preloadedQuestions != null && preloadedQuestions.isNotEmpty) {
        final byId = {for (final q in preloadedQuestions) q.id: q};
        _questions = [
          for (final id in started.questionIds)
            if (byId.containsKey(id)) byId[id]! else await _repo.getQuestion(id),
        ];
      } else if (paperId != null) {
        final all = await _examRepo.getQuestionsForPaper(paperId);
        final byId = {for (final q in all) q.id: q};
        _questions = [
          for (final id in started.questionIds)
            if (byId.containsKey(id)) byId[id]! else await _repo.getQuestion(id),
        ];
      } else {
        _questions = [
          for (final id in started.questionIds) await _repo.getQuestion(id),
        ];
      }

      if (mode == 'timed' && durationSec != null) {
        _remaining = Duration(seconds: durationSec);
        _timer = Timer.periodic(const Duration(seconds: 1), _tick);
      }
      _status = SessionStatus.inProgress;
    } catch (e) {
      _error = _api.mapError(e);
      _status = SessionStatus.error;
    }
    notifyListeners();
  }

  void _tick(Timer _) {
    final r = _remaining;
    if (r == null) return;
    if (r.inSeconds <= 1) {
      _remaining = Duration.zero;
      _timer?.cancel();
      notifyListeners();
      submit();
      return;
    }
    _remaining = Duration(seconds: r.inSeconds - 1);
    notifyListeners();
  }

  Future<void> selectOption(String label) async {
    if (_status != SessionStatus.inProgress) return;
    final q = current;
    _selected[q.id] = label;
    _revealed[q.id] = true;
    try {
      final resp = await _repo.recordAnswer(
        attemptId: _attemptId!,
        questionId: q.id,
        selectedLabel: label,
      );
      if (resp.correctAnswer != null) {
        _correctByQ[q.id] = resp.correctAnswer!;
      }
    } catch (_) {
      // Swallow errors — offline queue can be added later (M6).
    }
    notifyListeners();
  }

  void next() {
    if (!isLast) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void previous() {
    if (!isFirst) {
      _currentIndex--;
      notifyListeners();
    }
  }

  void goTo(int i) {
    if (i < 0 || i >= _questions.length) return;
    _currentIndex = i;
    notifyListeners();
  }

  Future<void> submit() async {
    if (_status == SessionStatus.submitting ||
        _status == SessionStatus.completed) {
      return;
    }
    _status = SessionStatus.submitting;
    _timer?.cancel();
    notifyListeners();
    try {
      _result = await _repo.submit(_attemptId!);
      _status = SessionStatus.completed;
    } catch (e) {
      _error = _api.mapError(e);
      _status = SessionStatus.error;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

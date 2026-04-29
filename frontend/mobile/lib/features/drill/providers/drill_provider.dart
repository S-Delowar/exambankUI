import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../../../core/models/api_result.dart';
import '../../../core/models/question.dart';

class DrillProvider extends ChangeNotifier {
  final ApiClient _api;
  DrillProvider(this._api);

  String? _subject;
  String? _chapter;
  int _count = 10;
  bool _loading = false;
  ApiError? _error;
  List<Question>? _fetched;

  String? get subject => _subject;
  String? get chapter => _chapter;
  int get count => _count;
  bool get loading => _loading;
  ApiError? get error => _error;
  List<Question>? get fetched => _fetched;

  void setSubject(String? s) {
    _subject = s;
    _chapter = null;
    notifyListeners();
  }

  void setChapter(String? c) {
    _chapter = c;
    notifyListeners();
  }

  void setCount(int n) {
    _count = n;
    notifyListeners();
  }

  Future<List<Question>?> fetch() async {
    if (_subject == null || _chapter == null) return null;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final resp = await _api.dio.get(
        Endpoints.drill,
        queryParameters: {
          'subject': _subject,
          'chapter': _chapter,
          'count': _count,
        },
      );
      _fetched = ((resp.data['items'] as List?) ?? const [])
          .map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList();
      return _fetched;
    } catch (e) {
      _error = _api.mapError(e);
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}

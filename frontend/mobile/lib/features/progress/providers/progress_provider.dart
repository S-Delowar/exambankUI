import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/models/api_result.dart';
import '../../../core/models/progress_summary.dart';
import '../repository/progress_repository.dart';

class ProgressProvider extends ChangeNotifier {
  final ProgressRepository _repo;
  final ApiClient _api;

  ProgressProvider(this._repo, this._api);

  ProgressSummary? _summary;
  DateTime? _fetchedAt;
  bool _loading = false;
  ApiError? _error;

  ProgressSummary? get summary => _summary;
  bool get loading => _loading;
  ApiError? get error => _error;

  static const _ttl = Duration(minutes: 5);

  bool get isFresh =>
      _fetchedAt != null && DateTime.now().difference(_fetchedAt!) < _ttl;

  Future<void> load({bool force = false}) async {
    if (!force && isFresh && _summary != null) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _summary = await _repo.getSummary();
      _fetchedAt = DateTime.now();
    } catch (e) {
      _error = _api.mapError(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void invalidate() {
    _fetchedAt = null;
  }

  void reset() {
    _summary = null;
    _fetchedAt = null;
    notifyListeners();
  }
}

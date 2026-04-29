import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/models/api_result.dart';
import '../../../core/models/exam_paper.dart';
import '../repository/exam_repository.dart';

class ExamListProvider extends ChangeNotifier {
  final ExamRepository _repo;
  final ApiClient _api;

  ExamListProvider(this._repo, this._api);

  List<ExamPaper> _papers = const [];
  ExamFilters _filters = const ExamFilters();
  bool _loading = false;
  ApiError? _error;

  List<ExamPaper> get papers => _papers;
  ExamFilters get filters => _filters;
  bool get loading => _loading;
  ApiError? get error => _error;

  Future<void> load({ExamFilters? filters, bool forceRefresh = false}) async {
    if (filters != null) _filters = filters;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _papers = await _repo.listPapers(
        filters: _filters,
        forceRefresh: forceRefresh,
      );
    } catch (e) {
      _error = _api.mapError(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> applyFilters(ExamFilters f) async {
    _filters = f;
    await load();
  }
}

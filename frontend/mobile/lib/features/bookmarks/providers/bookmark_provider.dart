import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/models/api_result.dart';
import '../../../core/models/bookmark.dart';
import '../repository/bookmark_repository.dart';

class BookmarkProvider extends ChangeNotifier {
  final BookmarkRepository _repo;
  final ApiClient _api;

  BookmarkProvider(this._repo, this._api);

  final Map<String, Bookmark> _byQ = {};
  bool _loading = false;
  ApiError? _error;

  List<Bookmark> get all => _byQ.values.toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  bool get loading => _loading;
  ApiError? get error => _error;

  bool isBookmarked(String qid) => _byQ.containsKey(qid);

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final items = await _repo.list();
      _byQ
        ..clear()
        ..addEntries(items.map((b) => MapEntry(b.questionId, b)));
    } catch (e) {
      _error = _api.mapError(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> toggle(String questionId) async {
    final had = _byQ.containsKey(questionId);
    try {
      if (had) {
        _byQ.remove(questionId);
        notifyListeners();
        await _repo.remove(questionId);
      } else {
        await _repo.add(questionId);
        await load();
      }
    } catch (_) {
      // Revert optimistic change on failure.
      await load();
    }
  }

  void reset() {
    _byQ.clear();
    notifyListeners();
  }
}

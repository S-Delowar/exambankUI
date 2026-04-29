import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../../../core/models/bookmark.dart';

class BookmarkRepository {
  final ApiClient _api;
  BookmarkRepository(this._api);

  Future<List<Bookmark>> list({int limit = 100, int offset = 0}) async {
    final resp = await _api.dio.get(
      Endpoints.bookmarks,
      queryParameters: {'limit': limit, 'offset': offset},
    );
    return ((resp.data['items'] as List?) ?? const [])
        .map((e) => Bookmark.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> add(String questionId) async {
    await _api.dio.post(Endpoints.bookmarks, data: {'question_id': questionId});
  }

  Future<void> remove(String questionId) async {
    await _api.dio.delete('${Endpoints.bookmarks}/$questionId');
  }
}

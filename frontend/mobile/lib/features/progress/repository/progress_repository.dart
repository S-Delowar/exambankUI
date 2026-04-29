import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../../../core/models/progress_summary.dart';

class ProgressRepository {
  final ApiClient _api;
  ProgressRepository(this._api);

  Future<ProgressSummary> getSummary() async {
    final resp = await _api.dio.get(Endpoints.progressSummary);
    return ProgressSummary.fromJson(resp.data as Map<String, dynamic>);
  }
}

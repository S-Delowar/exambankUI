import '../models/api_result.dart';

class ApiException implements Exception {
  final ApiError error;
  ApiException(this.error);

  @override
  String toString() => 'ApiException(${error.kind}: ${error.message})';
}

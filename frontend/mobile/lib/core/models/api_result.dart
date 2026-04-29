/// Sealed Result type for API calls.
sealed class ApiResult<T> {
  const ApiResult();
}

class Ok<T> extends ApiResult<T> {
  final T value;
  const Ok(this.value);
}

class Err<T> extends ApiResult<T> {
  final ApiError error;
  const Err(this.error);
}

enum ApiErrorKind { offline, unauthorized, notFound, conflict, server, unknown }

class ApiError {
  final ApiErrorKind kind;
  final String message;
  final int? statusCode;

  const ApiError({
    required this.kind,
    required this.message,
    this.statusCode,
  });

  bool get isOffline => kind == ApiErrorKind.offline;
  bool get isAuth => kind == ApiErrorKind.unauthorized;
}
